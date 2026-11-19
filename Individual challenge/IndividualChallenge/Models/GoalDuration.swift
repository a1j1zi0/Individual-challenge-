import Foundation

enum GoalDuration: String, Codable, CaseIterable {
    case week, month, year

    var title: String { rawValue.capitalized }

    var maxFreezes: Int {
        switch self {
        case .week: return 2
        case .month: return 8
        case .year: return 96
        }
    }

    var lengthInDays: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}
