package com.variance.nearby.screens.profile

import okhttp3.Interceptor
import okhttp3.Request
import okhttp3.Response

/**
 * Makes Walrus aggregator blob requests load in Coil. Three aggregator traits, three fixes:
 *
 * 1. **Cloudflare bot management** 403-blocks the default `okhttp/x` User-Agent (the same URL returns
 *    200 under any other UA), so requests carry an explicit app UA.
 * 2. **No `Content-Type`.** Blobs are served as raw bytes (often with `nosniff`), so Coil's
 *    content-type-driven decode sees nothing to decode. Missing/`octet-stream` types are rewritten to
 *    `image/jpeg`.
 * 3. **Cacheable 404s.** Blob URLs are immutable and content-addressed, but a fetch that races
 *    certification gets a 404 that is itself cacheable (`public, max-age=3600`) and pins at the edge.
 *    On any non-2xx, one retry with a cache-busting query gets a fresh edge response.
 *
 * Only aggregator requests are touched; everything else passes through untouched.
 */
class WalrusInterceptor : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val original = chain.request()
        if (!original.isWalrusBlob()) return chain.proceed(original)

        val request = original.newBuilder()
            .header("User-Agent", USER_AGENT)
            .build()

        var response = chain.proceed(request)
        if (!response.isSuccessful) {
            response.close()
            response = chain.proceed(request.withCacheBust())
        }

        return if (response.needsImageContentType()) {
            response.newBuilder().header("Content-Type", "image/jpeg").build()
        } else {
            response
        }
    }

    private fun Request.isWalrusBlob(): Boolean = url.host.contains("walrus", ignoreCase = true) ||
        url.encodedPath.contains("/v1/blobs/", ignoreCase = true)

    private fun Request.withCacheBust(): Request = newBuilder()
        .url(url.newBuilder().addQueryParameter("cb", System.currentTimeMillis().toString()).build())
        .build()

    private fun Response.needsImageContentType(): Boolean {
        val contentType = header("Content-Type")
        return contentType == null || contentType.contains("octet-stream", ignoreCase = true)
    }

    private companion object {
        const val USER_AGENT = "nearby-android/1.0"
    }
}
