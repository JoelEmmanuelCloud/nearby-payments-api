package com.variance.nearby.core

import android.content.Context
import androidx.biometric.BiometricManager
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.variance.nearby.auth.GoogleAuthManager
import com.variance.nearby.auth.SessionManager
import com.variance.nearby.biometrics.BiometricGateController
import com.variance.nearby.gateway.APIGateway
import com.variance.nearby.hsm.HardwareSecurityModule
import com.variance.nearby.hsm.StrongBoxHSM
import com.variance.nearby.leansui.api.SuiNetwork
import com.variance.nearby.leansui.api.SuiNetworkKind
import com.variance.nearby.services.zk.ZkLoginService
import com.variance.nearby.storage.PreferencesProvider
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.swift.swiftkit.core.ClosableSwiftArena
import org.swift.swiftkit.core.SwiftArena

/**
 * Central coordinator for the Android application state, routing, and user session lifecycles.
 *
 * `AppViewModel` manages navigation routes, coordinates the initialization of core services
 * (such as the API gateway, session manager, and hardware security module), and monitors
 * user authentication status. It is backed by Android Jetpack Lifecycle `ViewModel`.
 *
 * @param context The application context.
 */
class AppViewModel(
    context: Context,
) : ViewModel() {
    private val appContext = context.applicationContext

    /** The active navigation route in the application UI. */
    var route by mutableStateOf(AppRoute.ONBOARDING)
        private set

    /** The display name of the currently authenticated user. */
    var userName by mutableStateOf("Nearby user")
        private set

    /** An optional status or error message shown at the root layout level. */
    var statusMessage by mutableStateOf<String?>(null)
        private set

    /** Indicates whether an active network sign-in operation is currently in progress. */
    var isSigningIn by mutableStateOf(false)
        private set

    /** Confined JNI memory arena for JNI/Swift lifecycle coordination. */
    val swiftArena: ClosableSwiftArena = SwiftArena.ofConfined()
    private val preferencesProvider = PreferencesProvider(appContext)

    /**
     * Bridges hardware signing to the Compose biometric prompt. Bound to the launcher at the
     * composition root (`BiometricGateHost`). Only exercised at signing time, never at login/nonce.
     */
    val biometricGate = BiometricGateController(viewModelScope)

    /** The StrongBox-backed Hardware Security Module used for device signing key generation. */
    val hsm: HardwareSecurityModule =
        StrongBoxHSM(appContext, biometricGate)
    private val sessionStore = AppSessionStore(preferencesProvider, swiftArena)

    /** The Sui network this app targets (epoch lookups, proofs, transactions). */
    private val suiNetwork: SuiNetwork = when (AppConstants.SUI_NETWORK) {
        SuiNetworkKind.Discriminator.MAINNET -> SuiNetwork.getMainnet(swiftArena)
        SuiNetworkKind.Discriminator.DEVNET -> SuiNetwork.getDevnet(swiftArena)
        SuiNetworkKind.Discriminator.TESTNET -> SuiNetwork.getTestnet(swiftArena)
    }

    /** The network client gateway coordinating API requests. */
    val gateway: APIGateway = APIGateway.init(
        AppConstants.BASE_URL,
        AppConstants.API_VERSION,
        swiftArena,
    )

    /** Core session manager coordinating token validation, storage, and persistence. */
    val sessionManager: SessionManager = SessionManager.init(
        preferencesProvider,
        hsm,
        gateway,
        swiftArena,
    )

    /** Service managing the full zkLogin lifecycle (nonce, proof, persistence, JIT signer). */
    val zkLoginService = ZkLoginService(swiftArena, hsm, suiNetwork, sessionManager, viewModelScope)

    private val googleAuthManager: GoogleAuthManager = GoogleAuthManager(
        context = appContext,
        scope = viewModelScope,
        gateway = gateway,
        serverClientId = AppConstants.GOOGLE_SERVER_CLIENT_ID,
        sessionManager = sessionManager,
        swiftArena = swiftArena,
    )

    init {
        userName = sessionStore.userName()

        if (!sessionStore.didCompleteOnboarding()) {
            route = AppRoute.ONBOARDING
        } else {
            routeAfterDeviceSecurityCheck()
        }
    }

    /** Concludes onboarding steps, persists the completion flag, and transitions the app route. */
    fun finishOnboarding() {
        sessionStore.completeOnboarding()
        routeAfterDeviceSecurityCheck()
    }

    /** Re-evaluates biometric permissions when the app moves back to the foreground while on the device security screen. */
    fun refreshDeviceSecurityGate() {
        if (route == AppRoute.DEVICE_SECURITY) {
            routeAfterDeviceSecurityCheck()
        }
    }

    /** Handles sign-in events by saving the username and navigating to the home route. */
    fun handleSignInSuccess(name: String) {
        userName = name
        sessionStore.saveUserName(name)
        route = AppRoute.HOME

        // Warm up the zkLogin signer in the background so the multi-second proof is ready before
        // the user attempts to sign. Fire-and-forget; failures are non-fatal here.
        viewModelScope.launch {
            try {
                zkLoginService.warmUpSigner()
            } catch (_: Exception) {
            }
        }
    }

    /** Performs a sign-out by revoking backend session tokens, clearing local data, and resetting navigation routes. */
    fun signOut() {
        isSigningIn = true
        statusMessage = "Signing out..."

        googleAuthManager.signOut(
            onComplete = {
                sessionStore.clearUserName()
                userName = sessionStore.userName()
                isSigningIn = false
                statusMessage = null
                zkLoginService.clearPending()
                routeAfterDeviceSecurityCheck()
            },
            onError = { error ->
                isSigningIn = false
                statusMessage = "Sign out failed: ${error.localizedMessage}"
            },
        )
    }

    /** Handles browser-based redirect callbacks to complete native Apple OAuth sign-in. */
    fun handleAppleRedirect(code: String, state: String) {
        isSigningIn = true
        statusMessage = "Completing Apple Sign-In..."

        googleAuthManager.handleWebRedirect(
            code = code,
            state = state,
            onSuccess = { name ->
                isSigningIn = false
                statusMessage = null
                handleSignInSuccess(name)
            },
            onError = { error ->
                isSigningIn = false
                statusMessage = "Apple Sign-In failed: ${error.localizedMessage}"
            },
        )
    }

    /** Validates the stored authentication state and routes the user to either Home or Login. */
    private fun checkStoredSession() {
        route = AppRoute.LOADING
        viewModelScope.launch(Dispatchers.IO) {
            val loggedIn =
                try {
                    sessionManager.isLoggedIn
                } catch (_: Exception) {
                    false
                }

            withContext(Dispatchers.Main) {
                if (loggedIn) {
                    route = AppRoute.HOME
                } else {
                    sessionStore.clearUserName()
                    userName = sessionStore.userName()
                    route = AppRoute.LOGIN
                }
            }
        }
    }

    /** Verifies that system-level device protection is enabled before checking authentication state. */
    private fun routeAfterDeviceSecurityCheck() {
        if (canUseStrongBiometric()) {
            checkStoredSession()
        } else {
            route = AppRoute.DEVICE_SECURITY
        }
    }

    /** Evaluates local authentication policies to verify if strong hardware biometrics are configured. */
    private fun canUseStrongBiometric(): Boolean = BiometricManager.from(appContext).canAuthenticate(
        BiometricManager.Authenticators.BIOMETRIC_STRONG,
    ) == BiometricManager.BIOMETRIC_SUCCESS

    override fun onCleared() {
        super.onCleared()
        biometricGate.cancelPending("Biometric authentication cancelled because the app session ended.")
        swiftArena.close()
    }
}
