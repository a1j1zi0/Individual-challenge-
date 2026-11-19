import SwiftUI

struct LearningGoalView: View {
    @Environment(ActivityViewModel.self) private var activity
    // الـ ViewModel يجي جاهز من شاشة Activity (هي اللي تملكه)، عشان ما يتصفّر لو انعادت بناء الشاشة.
    // @Bindable عشان نقدر نربط الحقول فيه ($viewModel.topic)
    @Bindable var viewModel: LearningGoalViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            GoalForm(topic: $viewModel.topic, duration: $viewModel.duration)
            Spacer()
        }
        .padding()
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Learning Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    // هدف شغّال: نطلع التنبيه أول. هدف منتهي: نحفظ ونرجع على طول
                    if viewModel.requiresConfirmation {
                        setAlert(true)
                    } else {
                        activity.setGoal(viewModel.makeGoal())
                        dismiss()
                    }
                } label: {
                    Image(systemName: "checkmark")
                }
                // VoiceOver يقرأ "Save" بدل "Selected"
                .accessibilityLabel("Save")
                // دائرة برتقالية ممتلية (Liquid Glass) بدل علامة ✓ بس، مثل التصميم
                .buttonStyle(.glassProminent)
                .tint(Color.appOrange)
                .disabled(!viewModel.canConfirm)
            }
        }
        // تنبيه خاص (UpdateGoalAlert) بدل .alert الجاهز عشان زر Update يطلع برتقالي ممتلي مثل التصميم.
        // نعرضه بـ fullScreenCover بخلفية شفافة عشان يغطي الشاشة كاملة مع شريط العنوان
        .fullScreenCover(isPresented: $viewModel.showAlert) {
            UpdateGoalAlert(
                onDismiss: { setAlert(false) },
                onUpdate: {
                    activity.setGoal(viewModel.makeGoal())
                    setAlert(false)
                    dismiss()
                }
            )
            .presentationBackground(.clear)
        }
    }

    // يفتح أو يقفل التنبيه بدون حركة الطلوع من تحت حقت fullScreenCover
    private func setAlert(_ isShown: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { viewModel.showAlert = isShown }
    }
}
