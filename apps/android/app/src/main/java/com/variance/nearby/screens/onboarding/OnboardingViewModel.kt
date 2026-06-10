package com.variance.nearby.screens.onboarding

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel

/**
 * UI state controller for the multi-step application onboarding flow on Android.
 *
 * `OnboardingViewModel` manages pagination steps, page contents, and boundaries.
 */
class OnboardingViewModel : ViewModel() {
    /** The index of the current onboarding step. */
    var onboardingStep by mutableIntStateOf(0)
        private set

    /** Static list of onboarding pages describing the application features. */
    val onboardingPages = listOf(
        OnboardingPage(
            title = "Keep nearby access simple",
            message = "Use one account flow for wallets, device trust, and session recovery.",
        ),
        OnboardingPage(
            title = "Sign in with device protection",
            message = "Nearby prepares secure storage and hardware-backed checks before sensitive actions.",
        ),
        OnboardingPage(
            title = "Continue across platforms",
            message = "The same account foundation will power iOS and Android without changing your workflow.",
        ),
    )

    /** Evaluates whether the user can navigate to a previous onboarding step. */
    val canGoBack: Boolean
        get() = onboardingStep > 0

    /** Evaluates whether the user has reached the final onboarding step. */
    val isLastStep: Boolean
        get() = onboardingStep == onboardingPages.size - 1

    /** Decrements the current step to navigate back, if possible. */
    fun previousStep() {
        if (onboardingStep > 0) {
            onboardingStep--
        }
    }

    /**
     * Increments the onboarding step or triggers a completion callback if on the last slide.
     *
     * @param onFinished Invoked when the user clicks 'Next/Continue' on the final onboarding slide.
     */
    fun nextStep(onFinished: () -> Unit) {
        if (isLastStep) {
            onFinished()
        } else {
            onboardingStep++
        }
    }
}
