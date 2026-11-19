import Foundation

struct LearningGoal: Codable {
    var topic: String
    var duration: GoalDuration
    var startDate: Date
}
