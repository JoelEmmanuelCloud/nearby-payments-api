package com.variance.nearby.deviceintegrity

import android.content.Context
import com.google.android.gms.tasks.Tasks
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager.PrepareIntegrityTokenRequest

class PlayIntegrityProvider(private val context: Context, private val cloudProjectNumber: Long) {

    private val manager = IntegrityManagerFactory.createStandard(context)
    private var tokenProvider: StandardIntegrityManager.StandardIntegrityTokenProvider? = null

    fun prepare() {
        val request = PrepareIntegrityTokenRequest.builder()
            .setCloudProjectNumber(cloudProjectNumber)
            .build()

        val task = manager.prepareIntegrityToken(request)
        tokenProvider = Tasks.await(task)
    }

    fun attest(requestHash: String): String {
        val provider = tokenProvider ?: throw Exception("PlayIntegrityProvider was not prepared.")

        val request = StandardIntegrityTokenRequest.builder()
            .setRequestHash(requestHash)
            .build()

        val tokenResponse = Tasks.await(provider.request(request))
        return tokenResponse.token()
    }
}
