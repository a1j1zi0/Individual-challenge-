import SwiftUI
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var topic = ""
    @Published var duration: GoalDuration = .week

    private var cleanTopic: String {
        topic.trimmingCharacters(in: .whitespaces)
    }

    var canStart: Bool { !cleanTopic.isEmpty }

    func makeGoal() -> LearningGoal? {
        guard canStart else { return nil }
        return LearningGoal(topic: cleanTopic, duration: duration, startDate: Date())
    }
}
