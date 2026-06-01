package com.variance.nearby.deviceintegrity

import android.content.Context
import com.google.android.gms.tasks.Tasks
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import com.google.android.play.core.integrity.StandardIntegrityManager.PrepareIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenRequest

/**
 * Android-specific device integrity provider implementing Play Integrity API checks.
 * Uses Google Play Services' Standard Integrity API to prepare an integrity token provider
 * and retrieve attestation tokens bound to client request hashes.
 *
 * @property context Application context to initialize IntegrityManager.
 * @property cloudProjectNumber Google Cloud Project Number linked to Play Console integrity checks.
 */
class PlayIntegrityProvider(
    private val context: Context,
    private val cloudProjectNumber: Long,
) {
    private val manager = IntegrityManagerFactory.createStandard(context)
    private var tokenProvider: StandardIntegrityManager.StandardIntegrityTokenProvider? = null

    /**
     * Warms up the Play Integrity API client and retrieves standard token provider.
     * This is a blocking call and should be run on a background thread.
     */
    fun prepare() {
        val request =
            PrepareIntegrityTokenRequest
                .builder()
                .setCloudProjectNumber(cloudProjectNumber)
                .build()

        val task = manager.prepareIntegrityToken(request)
        tokenProvider = Tasks.await(task)
    }

    /**
     * Generates a device integrity token bound to the provided request hash.
     *
     * @param requestHash Base64url-encoded SHA-256 hash representing client verification nonce payload.
     * @return The raw Play Integrity JWT token string returned by Google services.
     * @throws Exception if [prepare] was not called successfully prior to attestation.
     */
    fun attest(requestHash: String): String {
        val provider = tokenProvider ?: throw Exception("PlayIntegrityProvider was not prepared.")

        val request =
            StandardIntegrityTokenRequest
                .builder()
                .setRequestHash(requestHash)
                .build()

        val tokenResponse = Tasks.await(provider.request(request))
        return tokenResponse.token()
    }

    companion object {
        /** The identifier name identifying the Play Integrity provider platform. */
        const val provider = "play_integrity"
    }
}

/**
 * A stub integrity provider for development and testing on emulators or sandbox environments.
 * It mimics the interface of [PlayIntegrityProvider] but does not interact with Google Play Services.
 */
class StubIntegrityProvider {
    /** No-op preparation. */
    fun prepare() {
        // No-op
    }

    /**
     * Returns a mock integrity token without contacting Google Play Services.
     *
     * @param requestHash Unused request hash parameter.
     * @return A static mock token string.
     */
    fun attest(requestHash: String): String = "mock_integrity_token"
}
