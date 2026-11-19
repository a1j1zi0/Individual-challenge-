import Foundation
import Observation

/// ViewModel الشاشة الرئيسية.
/// القواعد نفسها في `LearningRules` والحفظ في `ProgressStore`، وهنا بس نربطهم بالواجهة.
/// يستخدم @Observable (الطريقة الحديثة) بدل ObservableObject و Combine
@Observable
final class ActivityViewModel {
    private(set) var progress: LearningProgress?

    /// "الحين" اللي تعتمد عليه كل الحسابات. يتحدّث في refresh()
    /// (لما يرجع التطبيق، أو يتغيّر اليوم، أو تتغيّر ساعة الجهاز) عشان الواجهة تتحدّث معه
    private(set) var now: Date
    private var uptime: UInt64

    @ObservationIgnored private let rules: LearningRules
    @ObservationIgnored private let store: ProgressStore
    @ObservationIgnored private let clock: () -> Date
    @ObservationIgnored private let uptimeClock: () -> UInt64

    /// كل الاعتماديات قابلة للتبديل عشان الاختبارات تتحكم بالوقت والتخزين
    init(
        store: ProgressStore = ProgressStore(),
        rules: LearningRules = LearningRules(),
        clock: @escaping () -> Date = Date.init,
        // العدّاد الداخلي بالنانوثانية: يمشي حتى والجهاز نايم، وما يتأثر بتغيير الساعة
        uptimeClock: @escaping () -> UInt64 = { clock_gettime_nsec_np(CLOCK_MONOTONIC) }
    ) {
        self.store = store
        self.rules = rules
        self.clock = clock
        self.uptimeClock = uptimeClock
        self.now = clock()
        self.uptime = uptimeClock()
        self.progress = store.load()
    }

    private var calendar: Calendar { rules.calendar }

    // MARK: - Read-only state
    var hasGoal: Bool { progress != nil }
    var duration: GoalDuration { progress?.goal.duration ?? .week }
    var maxFreezes: Int { duration.maxFreezes }

    var todayStatus: DayStatus? { status(for: now) }
    var isLearnedToday: Bool { todayStatus == .learned }

    func status(for date: Date) -> DayStatus? {
        progress?.days[calendar.startOfDay(for: date)]
    }

    // MARK: - Streak & freezes
    var currentStreak: Int {
        guard let progress else { return 0 }
        return rules.currentStreak(progress, now: now)
    }

    var freezesUsed: Int {
        guard let progress else { return 0 }
        return rules.freezesUsed(progress)
    }

    var freezesLeft: Int {
        guard let progress else { return 0 }
        return rules.freezesLeft(progress)
    }

    var isClockValid: Bool {
        guard let progress else { return true }
        return rules.isClockValid(progress, now: now, uptime: uptime)
    }

    /// حسب المتطلبات: الأزرار تتعطّل إذا اليوم مسجّل (Learned أو Freeze)،
    /// أو إذا الساعة متغيّرة يدوياً
    var canLog: Bool { isClockValid && todayStatus == nil }
    var canFreeze: Bool { canLog && freezesLeft > 0 }

    /// "Freezed for a day" إذا جمّد اليوم أو خلصت التجميدات (حالة No Freezes available في التصميم)
    var freezeTitle: LocalizedStringResource {
        todayStatus == .freezed || freezesLeft == 0 ? "Freezed for a day" : "Freeze for a day"
    }

    // MARK: - Goal state
    var goalState: GoalState {
        guard let progress else { return .active }
        return rules.goalState(progress, now: now)
    }

    /// true إذا الهدف مكتمل أو ما تحقق (يعني مو شغّال)
    var isGoalFinished: Bool { goalState != .active }

    // MARK: - Display data
    var weekdayHeaders: [String] { DateText.weekdayHeaders }
    var todayTitle: String { DateText.title(now) }

    var weekDays: [DayItem] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else { return [] }
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: interval.start).map(item(for:))
        }
    }

    var months: [MonthSection] {
        guard let progress else { return [] }
        let first = min(progress.days.keys.min() ?? now, progress.goal.startDate)
        guard var cursor = calendar.dateInterval(of: .month, for: first)?.start else { return [] }
        var result: [MonthSection] = []
        while cursor <= now {
            result.append(makeMonth(startingAt: cursor))
            guard let next = calendar.date(byAdding: .month, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    // MARK: - Actions
    func setGoal(_ goal: LearningGoal) {
        refresh()
        progress = rules.settingGoal(goal, previous: progress, now: now)
        store.save(progress)
    }

    func logLearned() {
        refresh()
        guard canLog else { return }
        record(.learned)
    }

    func freezeToday() {
        refresh()
        guard canFreeze else { return }
        record(.freezed)
    }

    /// يحدّث "الحين" والعدّاد الداخلي، فتتحدّث الواجهة تلقائياً
    func refresh() {
        now = clock()
        uptime = uptimeClock()
    }

    private func record(_ status: DayStatus) {
        guard let progress else { return }
        self.progress = rules.recording(status, in: progress, now: now, uptime: uptime)
        store.save(self.progress)
    }

    // MARK: - Helpers
    private func item(for date: Date) -> DayItem {
        let status = status(for: date)
        let isToday = calendar.isDate(date, inSameDayAs: now)
        var spoken = [DateText.spoken(date)]
        switch status {
        case .learned: spoken.append(String(localized: "Learned"))
        case .freezed: spoken.append(String(localized: "Freezed"))
        case nil: break
        }
        if isToday { spoken.append(String(localized: "Today")) }

        return DayItem(
            date: calendar.startOfDay(for: date),
            number: calendar.component(.day, from: date),
            letter: DateText.weekdayLetter(date),
            status: status,
            isToday: isToday,
            accessibilityLabel: spoken.joined(separator: ", ")
        )
    }

    private func makeMonth(startingAt start: Date) -> MonthSection {
        let count = calendar.range(of: .day, in: .month, for: start)?.count ?? 30
        let blanks = calendar.component(.weekday, from: start) - 1
        let days = (0..<count).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: start).map(item(for:))
        }
        return MonthSection(id: start, title: DateText.month(start), blanks: blanks, days: days)
    }
}
