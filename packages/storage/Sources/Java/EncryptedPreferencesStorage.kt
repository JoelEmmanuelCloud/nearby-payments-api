package com.variance.nearby.storage

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import android.util.Base64

class EncryptedPreferencesStorage(context: Context, fileName: String = "nearby_secure_prefs") {
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val sharedPreferences = EncryptedSharedPreferences.create(
        context,
        fileName,
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    fun set(value: ByteArray, key: String) {
        val encodedString = Base64.encodeToString(value, Base64.DEFAULT)
        sharedPreferences.edit().putString(key, encodedString).apply()
    }

    fun get(key: String): ByteArray? {
        val encodedString = sharedPreferences.getString(key, null)
        if (encodedString != null) {
            return Base64.decode(encodedString, Base64.DEFAULT)
        }
        return null
    }

    fun delete(key: String) {
        sharedPreferences.edit().remove(key).apply()
    }

    fun clearAll() {
        sharedPreferences.edit().clear().apply()
    }
}
