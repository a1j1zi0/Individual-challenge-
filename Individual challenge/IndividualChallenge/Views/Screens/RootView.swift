import SwiftUI

struct RootView: View {
    @Environment(ActivityViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            if viewModel.hasGoal {
                ActivityView()
            } else {
                OnboardingView()
            }
        }
    }
}
