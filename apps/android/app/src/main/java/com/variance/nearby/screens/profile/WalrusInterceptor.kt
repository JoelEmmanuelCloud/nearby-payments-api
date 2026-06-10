package com.variance.nearby.screens.profile

import okhttp3.Interceptor
import okhttp3.Response

class WalrusInterceptor : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request()
        val url = request.url
        val host = url.host.lowercase()
        val path = url.encodedPath.lowercase()

        val isWalrus = host.contains("walrus") || path.contains("/v1/blobs/")
        val response = chain.proceed(request)

        if (isWalrus) {
            val contentType = response.header("Content-Type") ?: response.header("content-type")
            if (contentType == null || contentType.lowercase().contains("octet-stream")) {
                return response
                    .newBuilder()
                    .removeHeader("content-type")
                    .removeHeader("Content-Type")
                    .header("Content-Type", "image/jpeg")
                    .build()
            }
        }

        return response
    }
}
