import Foundation

enum GoalState {
    case active, completed, notMet
}

struct DayItem: Identifiable {
    let date: Date
    let number: Int
    let letter: String
    let status: DayStatus?
    let isToday: Bool
    /// النص اللي يقرأه VoiceOver، مثل "Thursday, 19 November 2026, Learned, Today"
    /// عشان حالة اليوم ما تكون معروفة باللون بس
    let accessibilityLabel: String
    var id: Date { date }
}

struct MonthSection: Identifiable {
    let id: Date
    let title: String
    let blanks: Int
    let days: [DayItem]
}
