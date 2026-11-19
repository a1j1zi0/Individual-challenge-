import SwiftUI

struct RootView: View {
    @EnvironmentObject private var viewModel: ActivityViewModel

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
