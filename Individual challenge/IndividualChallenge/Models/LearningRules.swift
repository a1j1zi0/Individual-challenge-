import Foundation

/// كل قواعد التطبيق (الـ streak، التجميدات، حالة الهدف، فحص الساعة) كدوال نقية:
/// تاخذ البيانات والوقت وترجع النتيجة بدون ما تعتمد على الساعة الحقيقية أو التخزين.
/// هذا يخلي القواعد سهلة الاختبار (Unit Tests) ويصغّر الـ ViewModel.
struct LearningRules {
    var calendar: Calendar

    /// الـ streak ينكسر إذا مرّت أكثر من 32 ساعة بدون Learned وبدون Freeze
    static let streakWindow: TimeInterval = 32 * 3600

    /// فرق مسموح (5 دقايق) عشان تزامن الساعة التلقائي مع الشبكة ما يعتبر تلاعب
    static let clockTolerance: TimeInterval = 5 * 60

    /// تقويم ميلادي يبدأ الأسبوع فيه يوم الأحد (مثل التصميم)
    static var defaultCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        return calendar
    }

    init(calendar: Calendar = LearningRules.defaultCalendar) {
        self.calendar = calendar
    }

    // MARK: - Streak

    /// true إذا مرّت أكثر من 32 ساعة على آخر Learned أو Freeze
    func isStreakBroken(_ progress: LearningProgress, now: Date) -> Bool {
        guard let last = progress.lastActionDate else { return false }
        return now.timeIntervalSince(last) > Self.streakWindow
    }

    /// عدد أيام Learned من بداية الـ streak. يرجع صفر إذا انكسر الـ streak
    func currentStreak(_ progress: LearningProgress, now: Date) -> Int {
        guard !isStreakBroken(progress, now: now) else { return 0 }
        return progress.days.filter { $0.value == .learned && $0.key >= progress.streakStart }.count
    }

    // MARK: - Goal period & freezes

    /// فترة الهدف: من يوم البداية لين نهاية مدته (7 / 30 / 365 يوم)
    func goalInterval(_ progress: LearningProgress) -> DateInterval? {
        let start = calendar.startOfDay(for: progress.goal.startDate)
        guard let end = calendar.date(byAdding: .day, value: progress.goal.duration.lengthInDays, to: start) else {
            return nil
        }
        return DateInterval(start: start, end: end)
    }

    /// عدد التجميدات المستخدمة داخل فترة الهدف الحالي
    func freezesUsed(_ progress: LearningProgress) -> Int {
        guard let interval = goalInterval(progress) else { return 0 }
        return progress.days.filter { $0.value == .freezed && interval.contains($0.key) }.count
    }

    func freezesLeft(_ progress: LearningProgress) -> Int {
        max(progress.goal.duration.maxFreezes - freezesUsed(progress), 0)
    }

    // MARK: - Goal state

    /// مكتمل: الأيام المتعلّمة + المتجمّدة غطّت مدة الهدف.
    /// ما تحقق: خلصت المدة وما اكتمل. غير كذا: شغّال
    func goalState(_ progress: LearningProgress, now: Date) -> GoalState {
        let start = calendar.startOfDay(for: progress.goal.startDate)
        let needed = progress.goal.duration.lengthInDays
        let coveredDays = progress.days.filter { $0.key >= start }.count
        if coveredDays >= needed { return .completed }
        if let end = calendar.date(byAdding: .day, value: needed, to: start), now >= end {
            return .notMet
        }
        return .active
    }

    // MARK: - Clock tampering

    /// false إذا الساعة تغيّرت يدوياً بعد آخر تسجيل.
    /// نقارن ساعة الجهاز (تتغيّر يدوياً) مع العدّاد الداخلي `uptime` (ما يتغيّر يدوياً، ويرجع صفر بعد restart)
    func isClockValid(_ progress: LearningProgress, now: Date, uptime: UInt64) -> Bool {
        guard let lastDate = progress.lastActionDate else { return true }

        // 1. الساعة رجعت ورا: الوقت الحالي قبل آخر تسجيل
        if now < lastDate.addingTimeInterval(-Self.clockTolerance) { return false }

        // 2. الساعة تقدّمت: في نفس الجلسة (بدون restart) لازم الوقت اللي مر حسب الساعة
        //    يساوي تقريباً الوقت اللي مر حسب العدّاد الداخلي
        if let lastUptime = progress.lastActionUptime, uptime >= lastUptime {
            let wallElapsed = now.timeIntervalSince(lastDate)
            let realElapsed = TimeInterval(uptime - lastUptime) / 1_000_000_000
            if abs(wallElapsed - realElapsed) > Self.clockTolerance { return false }
        }
        return true
    }

    // MARK: - Mutations (ترجع نسخة جديدة بدل ما تعدّل)

    /// يسجّل حالة اليوم. إذا الـ streak انكسر يبدأ streak جديد من اليوم
    func recording(_ status: DayStatus, in progress: LearningProgress, now: Date, uptime: UInt64) -> LearningProgress {
        var updated = progress
        let today = calendar.startOfDay(for: now)
        if isStreakBroken(progress, now: now) {
            updated.streakStart = today
        }
        updated.days[today] = status
        updated.lastActionDate = now
        updated.lastActionUptime = uptime
        return updated
    }

    /// يحط هدف جديد.
    /// أول هدف: الـ streak يبدأ من بداية اليوم (عشان تسجيل اليوم ينحسب).
    /// تحديث هدف: الـ streak يتصفّر من لحظة التحديث (أي يوم قبلها ما ينحسب).
    /// نحتفظ بالأيام ووقت آخر تسجيل عشان التقويم وفحص الساعة يظلون شغّالين
    func settingGoal(_ goal: LearningGoal, previous: LearningProgress?, now: Date) -> LearningProgress {
        LearningProgress(
            goal: goal,
            days: previous?.days ?? [:],
            streakStart: previous == nil ? calendar.startOfDay(for: now) : now,
            lastActionDate: previous?.lastActionDate,
            lastActionUptime: previous?.lastActionUptime
        )
    }
}
