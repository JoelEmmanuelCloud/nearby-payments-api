package com.variance.nearby.auth

import android.content.Context
import android.os.Build
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.variance.nearby.deviceintegrity.PlayIntegrityProvider
import com.variance.nearby.gateway.APIGateway
import com.variance.nearby.hsm.HardwareSecurityModule
import com.variance.nearby.storage.SecureStorage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.future.await
import kotlinx.coroutines.launch
import org.swift.swiftkit.core.SwiftArena
import java.util.Optional
import java.util.concurrent.ConcurrentHashMap

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
    private val integrityProvider = PlayIntegrityProvider()

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

    private suspend fun attestIntegrity(
        nonce: String,
        state: String,
    ): String = integrityProvider.attest(PKCE.hash(nonce + state).toString())

    fun signInWithGoogle(nonce: String) {
        scope.launch(Dispatchers.IO) {
            try {
                val response = auth.signIn("google", "native", nonce).await()
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

                val token = attestIntegrity(nonce, response.state)

                val completeResponse =
                    auth
                        .completeNativeSignIn(
                            "google",
                            idToken,
                            response.state,
                            Optional.empty(),
                            integrityProvider.provider,
                            Optional.empty(),
                            Optional.empty(),
                            Optional.of(token),
                            Optional.empty(),
                        ).await()

                // Save session natively in Kotlin
                sessionManager.saveSession(completeResponse)
            } catch (e: Exception) {
                // handle error
            }
        }
    }

    // --- 2. Apple OAuth Web Sign In ---
    fun signInWithApple(
        nonce: String,
        launchCustomTabs: (String) -> Unit,
    ) {
        scope.launch(Dispatchers.IO) {
            try {
                val webResponse = auth.signIn("apple", "web", nonce).await()
                stateToNonceMap[webResponse.state] = nonce
                launchCustomTabs(webResponse.authURL)
            } catch (e: Exception) {
                // handle error
            }
        }
    }

    // Capture OAuth Redirect from Deep Link Activity
    fun handleWebRedirect(
        code: String,
        state: String,
    ) {
        scope.launch(Dispatchers.IO) {
            try {
                val nonce =
                    stateToNonceMap.remove(state)
                        ?: throw Exception("Invalid state: No pending authentication request found.")
                val token = attestIntegrity(nonce, state)

                val completeResponse =
                    auth
                        .completeWebSignIn(
                            "apple",
                            code,
                            state,
                            integrityProvider.provider,
                            Optional.empty(),
                            Optional.empty(),
                            Optional.of(token),
                            Optional.empty(),
                        ).await()

                // Save session natively in Kotlin
                sessionManager.saveSession(completeResponse)
            } catch (e: Exception) {
                // handle error
            }
        }
    }
}
