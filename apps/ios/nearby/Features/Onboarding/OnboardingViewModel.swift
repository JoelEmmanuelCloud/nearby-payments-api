import Combine
import Foundation

/// UI state controller for the multi-step application onboarding flow on iOS.
///
/// `OnboardingViewModel` manages pagination steps, page contents, and boundaries
/// (such as determining if a back navigation is valid or if the user is on the final screen).
@MainActor
final class OnboardingViewModel: ObservableObject {
  /// The index of the current onboarding step.
  @Published private(set) var onboardingStep = 0

  /// Static list of onboarding pages describing the application features.
  let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
      title: "Keep nearby access simple",
      message: "Use one account flow for wallets, device trust, and session recovery."
    ),
    OnboardingPage(
      title: "Sign in with device protection",
      message: "Nearby prepares secure storage and hardware-backed checks before sensitive actions."
    ),
    OnboardingPage(
      title: "Continue across platforms",
      message:
        "The same account foundation will power iOS and Android without changing your workflow."
    ),
  ]

  /// Default constructor initialization.
  init() {}

  /// Evaluates whether the user can navigate to a previous onboarding step.
  var canGoBack: Bool {
    onboardingStep > 0
  }

  /// Evaluates whether the user has reached the final onboarding step.
  var isLastStep: Bool {
    onboardingStep == onboardingPages.count - 1
  }

  /// Decrements the current step to navigate back, if possible.
  func previousStep() {
    guard onboardingStep > 0 else { return }
    onboardingStep -= 1
  }

  /// Increments the onboarding step or triggers a completion callback if on the last slide.
  ///
  /// - Parameter onFinished: Invoked when the user clicks 'Next/Continue' on the final onboarding slide.
  func nextStep(onFinished: () -> Void) {
    if isLastStep {
      onFinished()
    } else {
      onboardingStep += 1
    }
  }
}
