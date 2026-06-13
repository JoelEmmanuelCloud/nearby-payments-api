package com.variance.nearby.screens.auth

import android.content.Context
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.variance.nearby.auth.GoogleAuthManager
import com.variance.nearby.auth.SessionManager
import com.variance.nearby.core.AppConstants
import com.variance.nearby.gateway.APIGateway
import com.variance.nearby.services.zk.ZkLoginService
import com.variance.nearby.ui.ToastController
import com.variance.nearby.ui.ToastTone
import kotlinx.coroutines.launch
import org.swift.swiftkit.core.SwiftArena

/**
 * UI state controller coordinating Google and Apple OAuth processes on Android.
 *
 * `LoginViewModel` prepares secure ephemeral keys and nonces for zkLogin, configures OAuth requests,
 * and reports active sign-in status messages to the Compose view.
 *
 * @param context The application context.
 * @param gateway API Client gateway.
 * @param sessionManager Session storage and token coordinator.
 * @param zkLoginService zkLogin ephemeral credentials service.
 * @param swiftArena Confined JNI memory arena.
 */
class LoginViewModel(
    context: Context,
    private val gateway: APIGateway,
    private val sessionManager: SessionManager,
    private val zkLoginService: ZkLoginService,
    private val toastController: ToastController,
    private val swiftArena: SwiftArena,
) : ViewModel() {
    private val appContext = context.applicationContext

    private val googleAuthManager = GoogleAuthManager(
        context = appContext,
        scope = viewModelScope,
        gateway = gateway,
        serverClientId = AppConstants.GOOGLE_SERVER_CLIENT_ID,
        sessionManager = sessionManager,
        swiftArena = swiftArena,
    )

    /** Indicates whether an active network sign-in operation is currently in progress. */
    var isSigningIn by mutableStateOf(false)
        private set

    /** Indicates if the cryptography layer has prepared a nonce and is ready for sign-in. */
    val isReadyToSignIn by derivedStateOf {
        zkLoginService.pendingZKEphemeral != null
    }

    /** Triggers the generation of an ephemeral key and nonce asynchronously. */
    fun prepareZkNonce() {
        isSigningIn = true
        viewModelScope.launch {
            try {
                zkLoginService.prepareNonce()
            } catch (_: Exception) {
                toastController.show("Could not prepare sign-in", ToastTone.WARNING)
            } finally {
                isSigningIn = false
            }
        }
    }

    /**
     * Initiates native Google Sign-In and completes the session.
     *
     * @param onSuccess Callback invoked with the username upon successful login.
     */
    fun signInWithGoogle(onSuccess: (String) -> Unit) {
        isSigningIn = true
        viewModelScope.launch {
            val nonce = try {
                zkLoginService.pendingZKEphemeral?.nonce ?: zkLoginService.prepareNonce()
            } catch (_: Exception) {
                isSigningIn = false
                toastController.show("Could not start sign-in", ToastTone.WARNING)
                return@launch
            }

            googleAuthManager.signInWithGoogle(
                nonce = nonce,
                onSuccess = { name ->
                    isSigningIn = false
                    onSuccess(name)
                },
                onError = { _ ->
                    isSigningIn = false
                    toastController.show("Google Sign-In failed", ToastTone.DANGER)
                },
            )
        }
    }

    /**
     * Initiates Apple Sign-In by launching a browser custom tab redirecting to OAuth.
     *
     * @param launchCustomTabs Callback to launch browser custom tab with authorization URL.
     * @param onSuccess Callback invoked with the user name upon successful login.
     */
    fun signInWithApple(launchCustomTabs: (String) -> Unit, onSuccess: (String) -> Unit) {
        isSigningIn = true
        viewModelScope.launch {
            val nonce = try {
                zkLoginService.pendingZKEphemeral?.nonce ?: zkLoginService.prepareNonce()
            } catch (_: Exception) {
                isSigningIn = false
                toastController.show("Could not start sign-in", ToastTone.WARNING)
                return@launch
            }

            googleAuthManager.signInWithApple(
                nonce = nonce,
                launchCustomTabs = { url ->
                    isSigningIn = false
                    toastController.show("Please log in in the browser...", ToastTone.NEUTRAL)
                    launchCustomTabs(url)
                },
                onError = { _ ->
                    isSigningIn = false
                    toastController.show("Apple Sign-In failed", ToastTone.DANGER)
                },
            )
        }
    }

    /**
     * Completes web-based Apple Sign-In after custom tab redirects back to app schema.
     *
     * @param code Redirect OAuth authorization code.
     * @param state Redirect verification state parameter.
     * @param onSuccess Callback invoked with the user name upon successful login.
     */
    fun handleAppleRedirect(code: String, state: String, onSuccess: (String) -> Unit) {
        isSigningIn = true

        googleAuthManager.handleWebRedirect(
            code = code,
            state = state,
            onSuccess = { name ->
                isSigningIn = false
                onSuccess(name)
            },
            onError = { _ ->
                isSigningIn = false
                toastController.show("Apple Sign-In failed", ToastTone.DANGER)
            },
        )
    }
}
