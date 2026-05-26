package com.variance.nearby.storage

import android.content.Context
import android.util.Base64

class PreferencesProvider(context: Context, fileName: String = "nearby_secure_prefs") {
    private val sharedPreferences = context.getSharedPreferences(fileName, Context.MODE_PRIVATE)

    fun set(value: ByteArray, key: String) {
        sharedPreferences.edit().putString(key, value.toStoredString()).apply()
    }

    fun get(key: String): ByteArray {
        return sharedPreferences.getString(key, null)?.toStoredBytes() ?: ByteArray(0)
    }

    fun delete(key: String) {
        sharedPreferences.edit().remove(key).apply()
    }

    fun clearAll() {
        sharedPreferences.edit().clear().apply()
    }

    private fun ByteArray.toStoredString(): String {
        return Base64.encodeToString(this, Base64.NO_WRAP)
    }

    private fun String.toStoredBytes(): ByteArray {
        return Base64.decode(this, Base64.NO_WRAP)
    }
}
