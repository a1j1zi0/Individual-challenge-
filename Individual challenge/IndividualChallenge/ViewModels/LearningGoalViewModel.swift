import Foundation
import Observation

/// ViewModel شاشة Learning Goal (تحديث الهدف أو اختيار هدف جديد بعد انتهاء القديم)
@Observable
final class LearningGoalViewModel {
    var topic: String
    var duration: GoalDuration
    var showAlert = false

    @ObservationIgnored private let original: LearningGoal
    /// true إذا الهدف السابق انتهى (مكتمل أو ما تحقق) — Task 3
    @ObservationIgnored private let isGoalFinished: Bool

    init(goal: LearningGoal, isGoalFinished: Bool = false) {
        original = goal
        self.isGoalFinished = isGoalFinished
        topic = goal.topic
        duration = goal.duration
    }

    private var cleanTopic: String { topic.trimmingCharacters(in: .whitespacesAndNewlines) }

    var hasChanges: Bool { cleanTopic != original.topic || duration != original.duration }

    /// إذا الهدف انتهى، يقدر المستخدم يختار نفس الهدف مرة ثانية (new/same task).
    /// وإذا الهدف شغّال، لازم يغيّر شي عشان يتفعّل زر الحفظ
    var canConfirm: Bool { !cleanTopic.isEmpty && (hasChanges || isGoalFinished) }

    /// تنبيه "your streak will start over" يطلع بس لما يغيّر هدف شغّال (Task 4).
    /// أما بعد انتهاء الهدف فما فيه streak يضيع، فيحفظ على طول
    var requiresConfirmation: Bool { !isGoalFinished }

    func makeGoal(now: Date = Date()) -> LearningGoal {
        LearningGoal(topic: cleanTopic, duration: duration, startDate: now)
    }
}
