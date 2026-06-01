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
        sharedPreferences.edit().putString(key, item.value.toStoredString()).apply()
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
        sharedPreferences.edit().remove(key).apply()
    }

    /**
     * Clears all entries from this preferences provider.
     */
    override fun clearAll() {
        sharedPreferences.edit().clear().apply()
    }

    private fun ByteArray.toStoredString(): String = Base64.encodeToString(this, Base64.NO_WRAP)

    private fun String.toStoredBytes(): ByteArray = Base64.decode(this, Base64.NO_WRAP)
}
