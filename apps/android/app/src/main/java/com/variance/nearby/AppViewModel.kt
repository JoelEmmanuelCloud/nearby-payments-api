package com.variance.nearby

import android.content.Context
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.variance.nearby.auth.GoogleAuthManager
import com.variance.nearby.auth.SessionManager
import com.variance.nearby.gateway.APIGateway
import com.variance.nearby.hsm.HardwareSecurityModule
import com.variance.nearby.hsm.StrongBoxHSM
import com.variance.nearby.storage.PreferencesProvider
import org.swift.swiftkit.core.SwiftArena
import java.util.UUID

data class OnboardingPage(
    val title: String,
    val message: String,
)

class AppViewModel(
    context: Context,
) : ViewModel() {

    var route by mutableStateOf(AppRoute.ONBOARDING)
        private set

    var onboardingStep by mutableIntStateOf(0)
        private set

    var isSigningIn by mutableStateOf(false)
        private set

    var statusMessage by mutableStateOf<String?>(null)
        private set

    var userName by mutableStateOf("Nearby user")
        private set

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

    private val swiftArena = SwiftArena.ofConfined()
    private val preferencesProvider = PreferencesProvider(context.applicationContext)
    private val hsm: HardwareSecurityModule = StrongBoxHSM(context.applicationContext)
    private val sessionStore = AppSessionStore(preferencesProvider, swiftArena)

    private val gateway: APIGateway = APIGateway.init(
        AppConstants.BASE_URL,
        AppConstants.API_VERSION,
        swiftArena,
    )
    private val sessionManager: SessionManager = SessionManager.init(
        preferencesProvider,
        hsm,
        gateway,
        swiftArena,
    )
    private val googleAuthManager: GoogleAuthManager = GoogleAuthManager(
        context = context.applicationContext,
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
            checkStoredSession()
        }
    }

    val canGoBackInOnboarding: Boolean
        get() = onboardingStep > 0

    val isLastOnboardingStep: Boolean
        get() = onboardingStep == onboardingPages.size - 1

    fun previousOnboardingStep() {
        if (onboardingStep > 0) {
            onboardingStep--
        }
    }

    fun nextOnboardingStep() {
        if (isLastOnboardingStep) {
            finishOnboarding()
        } else {
            onboardingStep++
        }
    }

    fun finishOnboarding() {
        sessionStore.completeOnboarding()
        checkStoredSession()
    }

    fun signInWithGoogle() {
        isSigningIn = true
        statusMessage = "Starting Google Sign-In..."
        val nonce = UUID.randomUUID().toString()

        googleAuthManager.signInWithGoogle(
            nonce = nonce,
            onSuccess = { name ->
                isSigningIn = false
                statusMessage = null
                userName = name
                sessionStore.saveUserName(name)
                route = AppRoute.HOME
            },
            onError = { error ->
                isSigningIn = false
                statusMessage = "Google Sign-In failed: ${error.localizedMessage}"
            },
        )
    }

    fun signInWithApple(launchCustomTabs: (String) -> Unit) {
        isSigningIn = true
        statusMessage = "Starting Apple Sign-In..."
        val nonce = UUID.randomUUID().toString()

        googleAuthManager.signInWithApple(
            nonce = nonce,
            launchCustomTabs = { url ->
                isSigningIn = false
                statusMessage = "Please log in in the browser..."
                launchCustomTabs(url)
            },
            onError = { error ->
                isSigningIn = false
                statusMessage = "Apple Sign-In failed: ${error.localizedMessage}"
            },
        )
    }

    fun handleAppleRedirect(code: String, state: String) {
        isSigningIn = true
        statusMessage = "Completing Apple Sign-In..."

        googleAuthManager.handleWebRedirect(
            code = code,
            state = state,
            onSuccess = { name ->
                isSigningIn = false
                statusMessage = null
                userName = name
                sessionStore.saveUserName(name)
                route = AppRoute.HOME
            },
            onError = { error ->
                isSigningIn = false
                statusMessage = "Apple Sign-In failed: ${error.localizedMessage}"
            },
        )
    }

    fun signOut() {
        isSigningIn = true
        statusMessage = "Signing out..."

        googleAuthManager.signOut(
            onComplete = {
                sessionStore.clearUserName()
                userName = sessionStore.userName()
                isSigningIn = false
                statusMessage = null
                route = AppRoute.LOGIN
            },
            onError = { error ->
                statusMessage = "Sign out failed: ${error.localizedMessage}"
            },
        )
    }

    private fun checkStoredSession() {
        route = AppRoute.LOADING
        route = if (isLoggedIn()) {
            AppRoute.HOME
        } else {
            AppRoute.LOGIN
        }
    }

    private fun isLoggedIn(): Boolean = try {
        sessionManager.isLoggedIn()
    } catch (_: Exception) {
        false
    }

    override fun onCleared() {
        super.onCleared()
        swiftArena.close()
    }
}
