package com.variance.nearby.storage

import android.content.Context
import android.util.Base64
import org.swift.swiftkit.core.SwiftArena
import java.util.Optional

class PreferencesProvider(
    context: Context,
    fileName: String = "nearby_secure_prefs",
) : SecureStorage {
    private val sharedPreferences = context.getSharedPreferences(fileName, Context.MODE_PRIVATE)

    override fun set(
        item: StorageItem,
        key: String,
    ) {
        sharedPreferences.edit().putString(key, item.value.toStoredString()).apply()
    }

    override fun get(
        key: String,
        swiftArena: SwiftArena,
    ): Optional<StorageItem> {
        val bytes =
            sharedPreferences.getString(key, null)?.toStoredBytes()
                ?: return Optional.empty()

        return Optional.of(StorageItem.init(bytes, swiftArena))
    }

    override fun delete(key: String) {
        sharedPreferences.edit().remove(key).apply()
    }

    override fun clearAll() {
        sharedPreferences.edit().clear().apply()
    }

    private fun ByteArray.toStoredString(): String = Base64.encodeToString(this, Base64.NO_WRAP)

    private fun String.toStoredBytes(): ByteArray = Base64.decode(this, Base64.NO_WRAP)
}
