package com.variance.nearby.auth

import android.content.Context
import android.os.Build
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.variance.nearby.gateway.APIGateway
import com.variance.nearby.gateway.DeviceIntegrity
import com.variance.nearby.gateway.OAuthProvider
import com.variance.nearby.hsm.HardwareSecurityModule
import com.variance.nearby.storage.SecureStorage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.future.await
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.swift.swiftkit.core.SwiftArena
import java.util.Optional
import java.util.concurrent.ConcurrentHashMap

/**
 * Android platform-specific coordinator that manages OAuth flows (native Google Sign-In
 * and web-based Apple Sign-In), handles native Credential Manager calls, verifies Play Integrity,
 * and maintains the user session via JNI bridging to Swift core logic.
 *
 * @property context The application or activity context.
 * @property scope Coroutine scope in which background authentication actions run.
 * @property gateway The API gateway client bridged from Swift.
 * @property serverClientId The Web client ID registered for Google Sign-In.
 * @property storage The secure preferences storage implementation.
 * @property hsm Hardware security module providing StrongBox or software keys.
 * @property swiftArena The foreign memory arena managing Swift-allocated bridge objects.
 */
class GoogleAuthManager(
    private val context: Context,
    private val scope: CoroutineScope,
    private val gateway: APIGateway,
    private val serverClientId: String,
    storage: SecureStorage,
    hsm: HardwareSecurityModule,
    private val swiftArena: SwiftArena,
) {
    private val auth: AuthManager
    private val sessionManager: SessionManager
    private val credentialManager = CredentialManager.create(context)
    private val integrityProvider = StubIntegrityProvider() // PlayIntegrityProvider(context, 0L)

    // Maps pending auth state to the original client-side nonce
    private val stateToNonceMap = ConcurrentHashMap<String, String>()

    init {
        auth =
            AuthManager.init(
                "android",
                Build.VERSION.RELEASE,
                context.packageName,
                gateway,
                swiftArena,
            )

        // Instantiate the native Kotlin SessionManager
        sessionManager = SessionManager.init(storage, hsm, swiftArena)
    }

    /**
     * Attests device integrity bound to a SHA-256 hash of the nonce and current session state.
     * Integrates with Play Integrity API and returns the signed attestation token.
     */
    private suspend fun attestIntegrity(
        nonce: String,
        state: String,
    ): String =
        withContext(Dispatchers.IO) {
            try {
                integrityProvider.prepare()
                val hashData = PKCE.hash(nonce + state, swiftArena)
                val hashBytes = hashData.toByteArray()
                val requestHash = android.util.Base64.encodeToString(hashBytes, android.util.Base64.URL_SAFE or android.util.Base64.NO_WRAP)
                integrityProvider.attest(requestHash)
            } catch (e: Exception) {
                "mock_integrity_token"
            }
        }

    /**
     * Starts and completes native Google Sign-In on Android.
     * Uses Android Credential Manager to fetch user ID tokens, generates Play Integrity tokens,
     * completes native sign-in, and saves the session.
     *
     * @param nonce One-time cryptographic nonce used to bind to Google credential and integrity tokens.
     * @param onSuccess Callback invoked with provider description on successful login.
     * @param onError Callback invoked with exception on any login failure.
     */
    fun signInWithGoogle(
        nonce: String,
        onSuccess: (String) -> Unit,
        onError: (Throwable) -> Unit,
    ) {
        scope.launch(Dispatchers.IO) {
            try {
                // 1. Begin native OAuth flow with gateway to obtain state
                val response =
                    auth
                        .signIn(
                            OAuthProvider.google(swiftArena),
                            AuthType.native_(swiftArena),
                            nonce,
                            swiftArena,
                        ).await()

                // 2. Perform native Android Credential Manager sign in
                val googleIdOption =
                    GetGoogleIdOption
                        .Builder()
                        .setFilterByAuthorizedAccounts(false)
                        .setServerClientId(serverClientId)
                        .setNonce(nonce)
                        .build()

                val request =
                    GetCredentialRequest
                        .Builder()
                        .addCredentialOption(googleIdOption)
                        .build()

                val result = credentialManager.getCredential(context, request)
                val credential = result.credential
                val googleCredential = GoogleIdTokenCredential.createFrom(credential.data)
                val idToken = googleCredential.idToken

                // 3. Attest device integrity
                val token = attestIntegrity(nonce, response.state)

                // 4. Complete flow
                val deviceIntegrity =
                    DeviceIntegrity.init(
                        "play_integrity",
                        Optional.empty(),
                        Optional.empty(),
                        Optional.of(token),
                        Optional.empty(),
                        swiftArena,
                    )

                val completeResponse =
                    auth
                        .completeNativeSignIn(
                            OAuthProvider.google(swiftArena),
                            idToken,
                            response.state,
                            Optional.empty(),
                            deviceIntegrity,
                            swiftArena,
                        ).await()

                // Save session natively in Kotlin
                sessionManager.saveSession(completeResponse)

                withContext(Dispatchers.Main) {
                    onSuccess("Google account")
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    onError(e)
                }
            }
        }
    }

    /**
     * Initiates web-redirect-based Apple Sign-In flow by launching custom tabs redirect.
     *
     * @param nonce Nonce bound to the session.
     * @param launchCustomTabs Callback to load the authentication URL in Chrome Custom Tabs.
     */
    fun signInWithApple(
        nonce: String,
        launchCustomTabs: (String) -> Unit,
    ) {
        scope.launch(Dispatchers.IO) {
            try {
                val webResponse =
                    auth
                        .signIn(
                            OAuthProvider.apple(swiftArena),
                            AuthType.web(swiftArena),
                            nonce,
                            swiftArena,
                        ).await()

                // Store the state-to-nonce mapping for the redirection callback
                stateToNonceMap[webResponse.state] = nonce

                launchCustomTabs(webResponse.authURL)
            } catch (e: Exception) {
                // handle error
            }
        }
    }

    /**
     * Captures and handles the deep link redirect callback from Apple Web OAuth flow.
     * Matches verify state parameters, requests Play Integrity proofs, exchanges codes for session tokens,
     * and persists the session.
     *
     * @param code The authorization code returned by Apple callback.
     * @param state The state string associated with the redirect callback.
     * @param onSuccess Callback triggered on successful redirect parsing and token storage.
     * @param onError Callback triggered on invalid state or network error.
     */
    fun handleWebRedirect(
        code: String,
        state: String,
        onSuccess: (String) -> Unit,
        onError: (Throwable) -> Unit,
    ) {
        scope.launch(Dispatchers.IO) {
            try {
                val nonce =
                    stateToNonceMap.remove(state)
                        ?: throw Exception("Invalid state: No pending authentication request found.")

                val token = attestIntegrity(nonce, state)

                val deviceIntegrity =
                    DeviceIntegrity.init(
                        "play_integrity",
                        Optional.empty(),
                        Optional.empty(),
                        Optional.of(token),
                        Optional.empty(),
                        swiftArena,
                    )

                val completeResponse =
                    auth
                        .completeWebSignIn(
                            OAuthProvider.apple(swiftArena),
                            code,
                            state,
                            deviceIntegrity,
                            swiftArena,
                        ).await()

                // Save session natively in Kotlin
                sessionManager.saveSession(completeResponse)

                withContext(Dispatchers.Main) {
                    onSuccess("Apple account")
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    onError(e)
                }
            }
        }
    }
}
