package com.variance.nearby.storage

import android.content.Context
import android.util.Base64
import org.swift.swiftkit.core.SwiftArena
import java.util.Optional

/**
 * Android implementation of the Swift `SecureStorage` protocol.
 * Stores sensitive byte arrays (such as OAuth access tokens and credentials) inside private
 * [android.content.SharedPreferences] using Base64 encoding.
 *
 * @param context Application context used to retrieve private preferences.
 * @param fileName Name of the shared preferences file. Defaults to "nearby_secure_prefs".
 */
class PreferencesProvider(
    context: Context,
    fileName: String = "nearby_secure_prefs",
) : SecureStorage {
    private val sharedPreferences = context.getSharedPreferences(fileName, Context.MODE_PRIVATE)

    /**
     * Stores a [StorageItem] byte array securely under the designated key.
     * Encodes raw byte payload to a Base64 string prior to saving.
     */
    override fun set(
        item: StorageItem,
        key: String,
    ) {
        // commit() (synchronous) — not apply() — so rotated refresh tokens are flushed to disk before
        // returning. With apply(), an OS process-kill before the async flush loses the new one-time
        // token, and the next launch's refresh fails terminally → spurious sign-out. iOS Keychain
        // writes are synchronous, which is why this only bites Android.
        sharedPreferences.edit().putString(key, item.value.toStoredString()).commit()
    }

    /**
     * Retrieves the stored [StorageItem] associated with the given key.
     * Decodes the stored Base64 string back to a byte array.
     *
     * @param key The key identifier to query.
     * @param swiftArena The foreign memory arena utilized to allocate the returned Swift-bridged [StorageItem].
     * @return An Optional wrapping the retrieved [StorageItem], or empty if not found.
     */
    override fun get(
        key: String,
        swiftArena: SwiftArena,
    ): Optional<StorageItem> {
        val bytes =
            sharedPreferences.getString(key, null)?.toStoredBytes()
                ?: return Optional.empty()

        return Optional.of(StorageItem.init(bytes, swiftArena))
    }

    /**
     * Removes the stored entry associated with the given key from shared preferences.
     */
    override fun delete(key: String) {
        sharedPreferences.edit().remove(key).commit()
    }

    /**
     * Clears all entries from this preferences provider.
     */
    override fun clearAll() {
        sharedPreferences.edit().clear().commit()
    }

    private fun ByteArray.toStoredString(): String = Base64.encodeToString(this, Base64.NO_WRAP)

    private fun String.toStoredBytes(): ByteArray = Base64.decode(this, Base64.NO_WRAP)
}
