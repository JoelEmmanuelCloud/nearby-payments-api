package com.variance.nearby.biometrics

import androidx.biometric.AuthenticationRequest
import androidx.biometric.AuthenticationResult
import androidx.biometric.BiometricPrompt
import com.variance.nearby.hsm.BiometricGate
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.launch
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeoutException
import java.util.concurrent.atomic.AtomicReference

/**
 * Bridges [com.variance.nearby.hsm.StrongBoxHSM]'s background, blocking [BiometricGate.authenticate]
 * to the Compose `rememberAuthenticationLauncher`.
 *
 * Owned by [AppViewModel]; bound to the launcher at the composition root (see `BiometricGateHost`).
 * It is the single owner of a signing prompt's lifecycle: launch → result → timeout → cancel.
 *
 * State here is unavoidable — the launcher delivers results to one callback, so the pending request
 * must be parked between launch and result. It is kept lock-free and confined: a single
 * [AtomicReference] slot (CAS to claim, self-clearing on terminal completion).
 *
 * Flow:
 *  1. `StrongBoxHSM.sign` (background thread) calls [authenticate] and blocks on the returned future.
 *  2. The request is emitted on [launchRequests]; the UI collector presents the prompt.
 *  3. Either the user resolves it (→ [onResult]) or [PROMPT_TIMEOUT_MS] elapses, which abandons the
 *     action *and* emits on [cancelRequests] so the UI dismisses the on-screen prompt.
 */
class BiometricGateController(
    private val scope: CoroutineScope,
) : BiometricGate {
    private class Session(
        val future: CompletableFuture<BiometricPrompt.CryptoObject>,
        val timeoutJob: Job,
    )

    private val launchEvents = MutableSharedFlow<AuthenticationRequest>(extraBufferCapacity = 1)

    /** Authentication requests to present on the UI thread. Collected at the composition root. */
    val launchRequests: SharedFlow<AuthenticationRequest> = launchEvents

    private val cancelEvents = MutableSharedFlow<Unit>(extraBufferCapacity = 1)

    /** Signals the UI to dismiss the current prompt (on timeout). Collected at the composition root. */
    val cancelRequests: SharedFlow<Unit> = cancelEvents

    /** null = idle, non-null = a prompt is in flight. */
    private val inFlight = AtomicReference<Session?>(null)

    override fun authenticate(crypto: BiometricPrompt.CryptoObject): CompletableFuture<BiometricPrompt.CryptoObject> {
        val future = CompletableFuture<BiometricPrompt.CryptoObject>()

        // Backstop: after the timeout, abandon the action and tell the UI to dismiss the prompt.
        // `completeExceptionally` returns false if the user already resolved it, so we only cancel
        // the prompt when the timeout actually won the race.
        val timeoutJob =
            scope.launch {
                delay(PROMPT_TIMEOUT_MS)
                val timedOut =
                    future.completeExceptionally(
                        TimeoutException("Biometric authentication timed out after ${PROMPT_TIMEOUT_MS / 1000}s."),
                    )
                if (timedOut) cancelEvents.tryEmit(Unit)
            }

        val session = Session(future, timeoutJob)
        if (!inFlight.compareAndSet(null, session)) {
            timeoutJob.cancel()
            future.completeExceptionally(
                IllegalStateException("A biometric authentication is already in progress."),
            )
            return future
        }
        future.whenComplete { _, _ ->
            inFlight.compareAndSet(session, null)
            timeoutJob.cancel()
        }

        val request =
            AuthenticationRequest.Biometric
                .Builder(
                    "Authorize signature",
                    // Per-op, crypto-bound keys cannot use a device-credential fallback, so the
                    // fallback acts as the cancel affordance and resolves to CustomFallbackSelected.
                    AuthenticationRequest.Biometric.Fallback.CustomOption("Cancel"),
                ).setSubtitle("Confirm to sign with your secure key")
                // Class3 + cryptoObject = crypto-bound STRONG biometric, matching the key policy.
                .setMinStrength(AuthenticationRequest.Biometric.Strength.Class3(crypto))
                .setIsConfirmationRequired(false)
                .build()

        launchEvents.tryEmit(request)
        return future
    }

    /** Called on the main thread from the launcher's [androidx.biometric.AuthenticationResultCallback]. */
    fun onResult(result: AuthenticationResult) {
        val session = inFlight.get() ?: return
        when (result) {
            is AuthenticationResult.Success -> {
                val crypto = result.crypto
                if (crypto != null) {
                    session.future.complete(crypto)
                } else {
                    session.future.completeExceptionally(
                        IllegalStateException("Authentication succeeded without a crypto object."),
                    )
                }
            }

            is AuthenticationResult.Error ->
                session.future.completeExceptionally(
                    Exception("Biometric error ${result.errorCode}: ${result.errString}"),
                )

            is AuthenticationResult.CustomFallbackSelected ->
                session.future.completeExceptionally(Exception("Authentication cancelled."))
        }
    }

    fun cancelPending(reason: String = "Biometric authentication cancelled.") {
        val session = inFlight.getAndSet(null) ?: return
        session.timeoutJob.cancel()
        session.future.completeExceptionally(Exception(reason))
        cancelEvents.tryEmit(Unit)
    }

    private companion object {
        /** Abandon a prompt the user has neither completed nor cancelled within this window. */
        const val PROMPT_TIMEOUT_MS = 60_000L
    }
}
