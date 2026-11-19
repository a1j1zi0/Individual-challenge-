
import SwiftUI
import Combine

final class ActivityViewModel: ObservableObject {
    @Published private(set) var progress: LearningProgress?

    private let storageKey = "learningProgress"
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        return calendar
    }()

    init() {
        load()
    }

    // MARK: - Read-only state
    var hasGoal: Bool { progress != nil }
    var duration: GoalDuration { progress?.goal.duration ?? .week }
    var maxFreezes: Int { duration.maxFreezes }

    var todayStatus: DayStatus? { status(for: Date()) }
    var isLearnedToday: Bool { todayStatus == .learned }

    func status(for date: Date) -> DayStatus? {
        progress?.days[calendar.startOfDay(for: date)]
    }

    // MARK: - Streak
    // الـ streak ينكسر في حالتين بس:
    // 1. مرّت أكثر من 32 ساعة بدون Learned وبدون Freeze
    // 2. تحديث الهدف (setGoal يرجّع streakStart للحظة التحديث)
    private let streakWindow: TimeInterval = 32 * 3600

    // true إذا مرّت أكثر من 32 ساعة على آخر Learned أو Freeze
    private func isStreakBroken(at date: Date) -> Bool {
        guard let last = progress?.lastActionDate else { return false }
        return date.timeIntervalSince(last) > streakWindow
    }

    // Bug fix: كان الكود يكسر الـ streak إذا فات يوم تقويمي واحد بدون تسجيل،
    // حتى لو ما مرّت 32 ساعة (مثلاً سجّل الاثنين 11 بالليل وفتح الأربعاء 1 الفجر = 26 ساعة).
    // الحين الـ streak = عدد أيام Learned من بداية الـ streak، وينكسر بس بقاعدة الـ 32 ساعة
    var currentStreak: Int {
        guard let progress, !isStreakBroken(at: Date()) else { return 0 }
        return progress.days.filter { $0.value == .learned && $0.key >= progress.streakStart }.count
    }

    // MARK: - Freezes
    var freezesUsed: Int {
        guard let progress,
              let interval = periodInterval else { return 0 }
        return progress.days.filter { $0.value == .freezed && interval.contains($0.key) }.count
    }

    var freezesLeft: Int { max(maxFreezes - freezesUsed, 0) }
    var canFreeze: Bool { isClockValid && todayStatus == nil && freezesLeft > 0 }

    // MARK: - Clock tampering
    // المشكلة: لو المستخدم قدّم ساعة الجهاز يدوياً يقدر يسجّل أيام ما تعلّم فيها،
    // ولو رجّعها يقدر يسجّل نفس اليوم مرتين.
    // الحل: نقارن ساعة الجهاز (تتغيّر يدوياً) مع العدّاد الداخلي للجهاز (ما يتغيّر يدوياً).

    // العدّاد الداخلي بالنانوثانية: يمشي حتى والجهاز نايم، وما يتأثر بتغيير الساعة.
    // يرجع صفر بس لما الجهاز يطفي ويشتغل (restart)
    private var uptimeNow: UInt64 { clock_gettime_nsec_np(CLOCK_MONOTONIC) }

    // نسمح بفرق 5 دقايق عشان تزامن الساعة التلقائي مع الشبكة ما يعتبر تلاعب
    private let clockTolerance: TimeInterval = 5 * 60

    // false إذا اكتشفنا إن الساعة تغيّرت يدوياً بعد آخر تسجيل
    var isClockValid: Bool {
        guard let lastDate = progress?.lastActionDate else { return true }
        let now = Date()

        // 1. الساعة رجعت ورا: الوقت الحالي قبل آخر تسجيل = أكيد تلاعب
        if now < lastDate.addingTimeInterval(-clockTolerance) { return false }

        // 2. الساعة تقدّمت: نقارن الوقت اللي مر حسب ساعة الجهاز مع الوقت اللي مر حسب العدّاد الداخلي.
        //    لو نفس الجلسة (الجهاز ما سوّى restart) لازم يكونون متساويين تقريباً
        if let lastUptime = progress?.lastActionUptime, uptimeNow >= lastUptime {
            let wallElapsed = now.timeIntervalSince(lastDate)
            let realElapsed = TimeInterval(uptimeNow - lastUptime) / 1_000_000_000
            if abs(wallElapsed - realElapsed) > clockTolerance { return false }
        }
        return true
    }
    // "Freezed for a day" إذا جمّد اليوم أو خلصت التجميدات (حالة No Freezes available في التصميم)
    var freezeTitle: String {
        todayStatus == .freezed || freezesLeft == 0 ? "Freezed for a day" : "Freeze for a day"
    }

    // Bug fix: كانت التجميدات تنحسب حسب أسبوع/شهر/سنة التقويم، فتتصفّر يوم الأحد أو أول الشهر
    // حتى لو الهدف لسا شغّال. الحين تنحسب من يوم بداية الهدف لين نهاية مدته
    private var periodInterval: DateInterval? {
        guard let progress else { return nil }
        let start = calendar.startOfDay(for: progress.goal.startDate)
        guard let end = calendar.date(byAdding: .day, value: duration.lengthInDays, to: start) else { return nil }
        return DateInterval(start: start, end: end)
    }

    // MARK: - Goal state
    var goalState: GoalState {
        guard let progress else { return .active }
        let start = calendar.startOfDay(for: progress.goal.startDate)
        let needed = progress.goal.duration.lengthInDays
        // Bug fix: كانت أيام التجميد ما تنحسب، فلو جمّد المستخدم يوم واحد يستحيل يكمل الهدف.
        // الحين اليوم المتعلّم واليوم المتجمّد كلهم يحسبون من أيام الهدف
        let coveredDays = progress.days.filter { $0.key >= start }.count
        if coveredDays >= needed { return .completed }
        if let end = calendar.date(byAdding: .day, value: needed, to: start), Date() >= end {
            return .notMet
        }
        return .active
    }

    // true إذا الهدف مكتمل أو ما تحقق (يعني مو شغّال)
    var isGoalFinished: Bool { goalState != .active }

    // MARK: - Display data
    // عناوين أيام الأسبوع فوق كل شهر في التقويم: SUN MON TUE ...
    var weekdayHeaders: [String] {
        calendar.shortWeekdaySymbols.map { $0.uppercased() }
    }

    var todayTitle: String { format(Date(), "EEEE, d MMMM") }

    var weekDays: [DayItem] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: interval.start).map { self.item(for: $0) }
        }
    }

    var months: [MonthSection] {
        guard let progress else { return [] }
        let first = min(progress.days.keys.min() ?? Date(), progress.goal.startDate)
        guard var cursor = calendar.dateInterval(of: .month, for: first)?.start else { return [] }
        var result: [MonthSection] = []
        while cursor <= Date() {
            result.append(makeMonth(startingAt: cursor))
            guard let next = calendar.date(byAdding: .month, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    // MARK: - Actions
    func setGoal(_ goal: LearningGoal) {
        progress = LearningProgress(
            goal: goal,
            days: progress?.days ?? [:],
            // Bug fix: أول هدف (من الـ Onboarding) يبدأ الـ streak من بداية اليوم،
            // عشان تسجيل اليوم ينحسب (الأيام محفوظة بوقت منتصف الليل).
            // تحديث الهدف يصفّر الـ streak: نبدأ العد من لحظة التحديث نفسها،
            // عشان أي يوم مسجّل قبل التحديث ما ينحسب في الـ streak الجديد
            streakStart: progress == nil ? calendar.startOfDay(for: Date()) : Date(),
            // نحتفظ بوقت آخر تسجيل عشان فحص تغيير الساعة يظل شغّال بعد تحديث الهدف
            lastActionDate: progress?.lastActionDate,
            lastActionUptime: progress?.lastActionUptime
        )
        save()
    }

    func logLearned() {
        // ما نسجّل إذا الساعة متغيّرة يدوياً
        guard progress != nil, isClockValid, !isLearnedToday else { return }
        record(.learned)
    }

    func freezeToday() {
        guard progress != nil, canFreeze else { return }
        record(.freezed)
    }

    // يسجّل حالة اليوم (Learned أو Freeze) ويحدّث وقت آخر تسجيل
    private func record(_ status: DayStatus) {
        guard var current = progress else { return }
        let now = Date()
        let today = calendar.startOfDay(for: now)
        // إذا الـ streak انكسر (أكثر من 32 ساعة)، يبدأ streak جديد من اليوم
        if isStreakBroken(at: now) {
            current.streakStart = today
        }
        current.days[today] = status
        current.lastActionDate = now
        current.lastActionUptime = uptimeNow   // نحفظ العدّاد الداخلي مع الوقت عشان نقارنهم بعدين
        progress = current
        save()
    }

    func refresh() {
        objectWillChange.send()
    }

    // MARK: - Helpers
    private func item(for date: Date) -> DayItem {
        DayItem(
            date: calendar.startOfDay(for: date),
            number: calendar.component(.day, from: date),
            letter: format(date, "EEEEE"),
            status: status(for: date),
            isToday: calendar.isDateInToday(date)
        )
    }

    private func makeMonth(startingAt start: Date) -> MonthSection {
        let count = calendar.range(of: .day, in: .month, for: start)?.count ?? 30
        let blanks = calendar.component(.weekday, from: start) - 1
        let days = (0..<count).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: start).map { self.item(for: $0) }
        }
        return MonthSection(id: start, title: format(start, "MMMM yyyy"), blanks: blanks, days: days)
    }

    private func format(_ date: Date, _ pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = pattern
        return formatter.string(from: date)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode(LearningProgress.self, from: data) else { return }
        progress = saved
    }
}
