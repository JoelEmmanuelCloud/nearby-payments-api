package com.variance.nearby.screens.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.variance.nearby.ui.MutedText
import com.variance.nearby.ui.Title
import com.variance.nearby.ui.UIButton

@Composable
fun OnboardingScreen(
    onFinished: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: OnboardingViewModel = remember { OnboardingViewModel() },
) {
    OnboardingContent(
        currentStep = viewModel.onboardingStep,
        pages = viewModel.onboardingPages,
        onNext = { viewModel.nextStep(onFinished) },
        onBack = { viewModel.previousStep() },
        onSkip = onFinished,
        canGoBack = viewModel.canGoBack,
        isLastStep = viewModel.isLastStep,
        modifier = modifier,
    )
}

@Composable
fun OnboardingContent(
    currentStep: Int,
    pages: List<OnboardingPage>,
    onNext: () -> Unit,
    onBack: () -> Unit,
    onSkip: () -> Unit,
    canGoBack: Boolean,
    isLastStep: Boolean,
    modifier: Modifier = Modifier,
) {
    val page = pages[currentStep]

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .padding(24.dp),
        verticalArrangement = Arrangement.SpaceBetween,
    ) {
        // Onboarding Progress View (Capsules)
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            pages.forEachIndexed { index, _ ->
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .height(4.dp)
                        .background(
                            color = if (index <= currentStep) {
                                MaterialTheme.colorScheme.primary
                            } else {
                                MaterialTheme.colorScheme.onSurface.copy(alpha = 0.12f)
                            },
                            shape = RoundedCornerShape(2.dp),
                        ),
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Page content
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f),
            verticalArrangement = Arrangement.Center,
        ) {
            Title(value = page.title)
            Spacer(modifier = Modifier.height(14.dp))
            MutedText(value = page.message)
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Bottom Actions
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            UIButton(
                title = if (isLastStep) "Continue" else "Next",
                onClick = onNext,
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                if (canGoBack) {
                    TextButton(
                        onClick = onBack,
                        contentPadding = PaddingValues(0.dp),
                    ) {
                        Text(
                            text = "Back",
                            style = MaterialTheme.typography.bodyMedium.copy(
                                color = MaterialTheme.colorScheme.primary,
                            ),
                        )
                    }
                } else {
                    Spacer(modifier = Modifier.width(1.dp))
                }

                TextButton(
                    onClick = onSkip,
                    contentPadding = PaddingValues(0.dp),
                ) {
                    Text(
                        text = "Skip",
                        style = MaterialTheme.typography.bodyMedium.copy(
                            color = MaterialTheme.colorScheme.primary,
                        ),
                    )
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun OnboardingScreenPreview() {
    OnboardingContent(
        currentStep = 0,
        pages = listOf(
            OnboardingPage(
                title = "Keep nearby access simple",
                message = "Use one account flow for wallets, device trust, and session recovery.",
            ),
            OnboardingPage(
                title = "Sign in with device protection",
                message = "Nearby prepares secure storage and hardware-backed checks before sensitive actions.",
            ),
        ),
        onNext = {},
        onBack = {},
        onSkip = {},
        canGoBack = false,
        isLastStep = false,
    )
}
