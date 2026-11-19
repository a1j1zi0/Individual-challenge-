import Foundation

struct LearningProgress: Codable {
    var goal: LearningGoal
    var days: [Date: DayStatus] = [:]
    var streakStart: Date
    var lastActionDate: Date?
    // وقت الجهاز الداخلي (uptime) لحظة آخر تسجيل — ما يتأثر لو المستخدم غيّر الساعة يدوياً
    // Optional عشان البيانات القديمة المحفوظة تنقرأ عادي بدون ما تخرب
    var lastActionUptime: UInt64?
}
