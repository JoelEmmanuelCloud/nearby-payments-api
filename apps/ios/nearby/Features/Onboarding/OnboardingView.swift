import SwiftUI
import UI

struct OnboardingView: View {
  @StateObject private var viewModel = OnboardingViewModel()
  let onFinished: () -> Void

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
        UIButton(viewModel.isLastStep ? "Continue" : "Next") {
          viewModel.nextStep(onFinished: onFinished)
        }

        HStack(spacing: 12) {
          if viewModel.canGoBack {
            Button("Back") {
              viewModel.previousStep()
            }
          }

          Spacer()

          Button("Skip") {
            onFinished()
          }
        }
        .font(.subheadline.weight(.medium))
      }
    }
    .padding(24)
  }
}

#Preview {
  OnboardingView(onFinished: {})
}
