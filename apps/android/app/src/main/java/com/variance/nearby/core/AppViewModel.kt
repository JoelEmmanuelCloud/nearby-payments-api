package com.variance.nearby.core

import android.content.Context
import androidx.biometric.BiometricManager
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.variance.nearby.auth.GoogleAuthManager
import com.variance.nearby.auth.SessionError
import com.variance.nearby.auth.SessionManager
import com.variance.nearby.biometrics.BiometricGateController
import com.variance.nearby.gateway.APIGateway
import com.variance.nearby.hsm.HardwareSecurityModule
import com.variance.nearby.hsm.StrongBoxHSM
import com.variance.nearby.identity.IdentityManager
import com.variance.nearby.leansui.api.GraphQLSuiProvider
import com.variance.nearby.leansui.api.SuiNetwork
import com.variance.nearby.leansui.api.SuiNetworkKind
import com.variance.nearby.services.zk.ZkLoginService
import com.variance.nearby.storage.PreferencesProvider
import com.variance.nearby.ui.ToastController
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.future.await
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
    val sessionStore = AppSessionStore(preferencesProvider, swiftArena)

    /** App-wide transient-message bus, rendered by the root composable. */
    val toastController = ToastController()

    /** The current user's id (for keying the app-side profile cache), or "" if no session. */
    val currentUserId: String
        get() = try {
            val opt = sessionManager.getCurrentSession(swiftArena)
            if (opt.isPresent) opt.get().userId else ""
        } catch (_: Exception) {
            ""
        }

    /** The current zkLogin Sui address (for the on-chain balance query), or null if no session. */
    val currentSuiAddress: String?
        get() = try {
            val opt = sessionManager.getCurrentSession(swiftArena)
            if (opt.isPresent) opt.get().suiAddress.orElse(null) else null
        } catch (_: Exception) {
            null
        }

    /** The Sui network this app targets (epoch lookups, proofs, transactions, balance). */
    val suiNetwork: SuiNetwork = when (AppConstants.SUI_NETWORK) {
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

    val identityManager: IdentityManager = IdentityManager.init(
        gateway,
        GraphQLSuiProvider.init(suiNetwork, swiftArena),
        sessionManager,
        swiftArena,
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

    /** Handles sign-in events by saving the username and navigating to the home route or profile setup. */
    fun handleSignInSuccess(name: String) {
        userName = name
        sessionStore.saveUserName(name)

        // `suiAddress` is now derived synchronously by the zkLogin layer, so route on completed-setup.
        route = if (sessionStore.didCompleteProfileSetup()) AppRoute.HOME else AppRoute.PROFILE_SETUP

        // Single writer of Sui properties (derive + persist the stable address), then record it with
        // the backend (idempotent) and warm up the signer. A forced session wipe routes to login.
        viewModelScope.launch {
            try {
                zkLoginService.commitSessionIdentity()
                identityManager.rebind().await()
                zkLoginService.warmUpSigner()
            } catch (_: Exception) {
                // Transient / non-session failure → best-effort, no-op (signer simply not cached yet).
            }
        }
    }

    /** Marks first-run profile setup complete and returns to Home. Called when the setup flow finishes. */
    fun finishProfileSetup() {
        sessionStore.completeProfileSetup()
        route = AppRoute.HOME
    }

    /** Performs a sign-out by revoking backend session tokens, clearing local data, and resetting navigation routes. */
    fun signOut() {
        isSigningIn = true
        statusMessage = "Signing out..."

        googleAuthManager.signOut(
            onComplete = {
                isSigningIn = false
                clearLocalState()
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
        // One coroutine on Main; only the blocking session read hops to IO. Both "not logged in"
        // and "session wiped during rebind" converge on the single `clearLocalState` path.
        viewModelScope.launch {
            val loggedIn = withContext(Dispatchers.IO) {
                try {
                    sessionManager.isLoggedIn
                } catch (_: Exception) {
                    false
                }
            }

            if (!loggedIn) {
                clearLocalState()
                route = AppRoute.LOGIN
                return@launch
            }

            route = if (sessionStore.didCompleteProfileSetup()) AppRoute.HOME else AppRoute.PROFILE_SETUP

            // Best-effort idempotent rebind + warm-up.
            try {
                identityManager.rebind().await()
                zkLoginService.warmUpSigner()
            } catch (e: Exception) {
                if (e.message == SessionError.sessionExpired(swiftArena).description) {
                    clearLocalState()
                    route = AppRoute.LOGIN
                }
            }
        }
    }

    /** Clears local session state and routes to login after a forced session invalidation. */
    private fun clearLocalState() {
        sessionStore.clearUserName()
        userName = sessionStore.userName()
        zkLoginService.clearPending()
        statusMessage = null
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
