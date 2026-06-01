import SwiftUI
import UI

struct OnboardingView: View {
  @ObservedObject var viewModel: AppViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      OnboardingProgressView(
        currentIndex: viewModel.onboardingStep,
        count: viewModel.onboardingPages.count
      )

      Spacer(minLength: 24)

      OnboardingPageView(page: viewModel.onboardingPages[viewModel.onboardingStep])

      Spacer(minLength: 24)

      VStack(spacing: 12) {
        UIButton(viewModel.isLastOnboardingStep ? "Continue" : "Next") {
          viewModel.nextOnboardingStep()
        }

        HStack(spacing: 12) {
          if viewModel.canGoBackInOnboarding {
            Button("Back") {
              viewModel.previousOnboardingStep()
            }
          }

          Spacer()

          Button("Skip") {
            viewModel.finishOnboarding()
          }
        }
        .font(.subheadline.weight(.medium))
      }
    }
    .padding(24)
  }
}

#Preview {
  OnboardingView(viewModel: AppViewModel(store: AppSessionStore(defaults: .standard)))
}
