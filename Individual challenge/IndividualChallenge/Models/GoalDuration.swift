import Foundation

enum GoalDuration: String, Codable, CaseIterable {
    case week, month, year

    /// LocalizedStringResource عشان Week / Month / Year تنضاف للـ String Catalog وتنترجم
    var title: LocalizedStringResource {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }

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
