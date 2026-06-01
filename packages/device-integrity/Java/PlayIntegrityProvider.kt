package com.variance.nearby.deviceintegrity

import android.content.Context
import com.google.android.gms.tasks.Tasks
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import com.google.android.play.core.integrity.StandardIntegrityManager.PrepareIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenRequest

class PlayIntegrityProvider(
    private val context: Context,
    private val cloudProjectNumber: Long,
) {
    private val manager = IntegrityManagerFactory.createStandard(context)
    private var tokenProvider: StandardIntegrityManager.StandardIntegrityTokenProvider? = null

    fun prepare() {
        val request =
            PrepareIntegrityTokenRequest
                .builder()
                .setCloudProjectNumber(cloudProjectNumber)
                .build()

        val task = manager.prepareIntegrityToken(request)
        tokenProvider = Tasks.await(task)
    }

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
