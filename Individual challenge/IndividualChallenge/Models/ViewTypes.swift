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
    var id: Date { date }
}

struct MonthSection: Identifiable {
    let id: Date
    let title: String
    let blanks: Int
    let days: [DayItem]
}
