import Foundation
import Observation

/// ViewModel شاشة الـ Onboarding (أول هدف)
@Observable
final class OnboardingViewModel {
    var topic = ""
    var duration: GoalDuration = .week

    private var cleanTopic: String {
        topic.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// الموضوع نص حر بأي لغة، والشرط الوحيد إنه ما يكون فاضي
    var canStart: Bool { !cleanTopic.isEmpty }

    func makeGoal(now: Date = Date()) -> LearningGoal? {
        guard canStart else { return nil }
        return LearningGoal(topic: cleanTopic, duration: duration, startDate: now)
    }
}
