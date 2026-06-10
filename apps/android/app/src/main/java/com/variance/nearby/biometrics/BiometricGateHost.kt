package com.variance.nearby.biometrics

import androidx.biometric.AuthenticationResult
import androidx.biometric.AuthenticationResultCallback
import androidx.biometric.compose.rememberAuthenticationLauncher
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember

/**
 * Binds [BiometricGateController] to the Compose biometric launcher. Registered once at the
 * composition root so hardware signing (which runs headless on a background thread) can present a
 * prompt regardless of the current screen.
 */
@Composable
fun BiometricGateHost(
    controller: BiometricGateController,
) {
    val callback =
        remember(controller) {
            object : AuthenticationResultCallback {
                override fun onAuthResult(result: AuthenticationResult) = controller.onResult(result)

                // Non-terminal: a single rejected attempt. The prompt stays open for retry.
                override fun onAuthAttemptFailed() = Unit
            }
        }
    val launcher = rememberAuthenticationLauncher(callback)

    // runCatching keeps the collector alive if launch/cancel throws; the gate's timeout still
    // resolves the blocked signer in that case.
    LaunchedEffect(controller, launcher) {
        controller.launchRequests.collect { request -> runCatching { launcher.launch(request) } }
    }
    LaunchedEffect(controller, launcher) {
        controller.cancelRequests.collect { runCatching { launcher.cancel() } }
    }
}
