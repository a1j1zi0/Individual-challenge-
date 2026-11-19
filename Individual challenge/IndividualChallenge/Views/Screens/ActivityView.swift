import SwiftUI

struct ActivityView: View {
    @EnvironmentObject private var viewModel: ActivityViewModel
    @State private var showGoalEditor = false
    // Bug fix: الـ ViewModel حق شاشة الهدف صار ينحفظ هنا بدل ما ينخلق داخل الشاشة نفسها.
    // قبل كان SwiftUI يعيد بناء الشاشة أول مرة يطلع التنبيه، فينخلق ViewModel جديد
    // ويرجع كل شي لحالته الأولى (المدة ترجع Week، والتنبيه ما يطلع)
    @State private var goalEditor: LearningGoalViewModel?

    // يجهّز ViewModel جديد لشاشة الهدف ويفتحها
    private func openGoalEditor() {
        guard let goal = viewModel.progress?.goal else { return }
        goalEditor = LearningGoalViewModel(goal: goal, isGoalFinished: viewModel.isGoalFinished)
        showGoalEditor = true
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.todayTitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            WeekStripView(days: viewModel.weekDays)

            HStack(spacing: 12) {
                StatCard(icon: "flame.fill", color: .appOrange, count: viewModel.currentStreak, label: "Learned")
                StatCard(icon: "snowflake", color: .appBlue, count: viewModel.freezesUsed, label: "Freezed")
            }

            Spacer()
            content
            Spacer()
        }
        .padding()
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Activity")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink {
                    CalendarView()
                } label: {
                    Image(systemName: "calendar")
                }
                Button {
                    openGoalEditor()
                } label: {
                    Image(systemName: "target")
                }
            }
        }
        // أيقونات التولبار بيضاء مثل التصميم (عشان ما تاخذ لون الـ AccentColor البرتقالي)
        .tint(.white)
        .navigationDestination(isPresented: $showGoalEditor) {
            if let goalEditor {
                LearningGoalView(viewModel: goalEditor)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.goalState {
        case .active:
            VStack(spacing: 24) {
                LogButton(isLogged: viewModel.isLearnedToday) { viewModel.logLearned() }
                    // الدائرة تتعطّل إذا الساعة متغيّرة يدوياً
                    .disabled(!viewModel.isClockValid)
                VStack(spacing: 8) {
                    FreezeButton(title: viewModel.freezeTitle, isEnabled: viewModel.canFreeze) {
                        viewModel.freezeToday()
                    }
                    Text("\(viewModel.freezesUsed) out of \(viewModel.maxFreezes) Freezes used")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    // رسالة تطلع بس إذا اكتشفنا إن الساعة تغيّرت يدوياً
                    if !viewModel.isClockValid {
                        Text("Your device time was changed. Set it to automatic to keep logging.")
                            .font(.caption)
                            .foregroundStyle(Color.appOrange)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        case .completed:
            GoalResultView(isCompleted: true) { openGoalEditor() }
        case .notMet:
            GoalResultView(isCompleted: false) { openGoalEditor() }
        }
    }
}
