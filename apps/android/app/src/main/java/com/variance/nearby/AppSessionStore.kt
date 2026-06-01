package com.variance.nearby

import com.variance.nearby.storage.SecureStorage
import com.variance.nearby.storage.StorageItem
import org.swift.swiftkit.core.SwiftArena

class AppSessionStore(
    private val storage: SecureStorage,
    private val swiftArena: SwiftArena,
) {
    companion object {
        private const val KEY_DID_COMPLETE_ONBOARDING = "nearby.didCompleteOnboarding"
        private const val KEY_IS_AUTHENTICATED = "nearby.isAuthenticated"
        private const val KEY_USER_NAME = "nearby.userName"
    }

    fun didCompleteOnboarding(): Boolean {
        val itemOpt = storage.get(KEY_DID_COMPLETE_ONBOARDING, swiftArena)
        if (!itemOpt.isPresent) return false
        val bytes = itemOpt.get().value
        return bytes.firstOrNull() == 1.toByte()
    }

    fun isAuthenticated(): Boolean {
        val itemOpt = storage.get(KEY_IS_AUTHENTICATED, swiftArena)
        if (!itemOpt.isPresent) return false
        val bytes = itemOpt.get().value
        return bytes.firstOrNull() == 1.toByte()
    }

    fun userName(): String {
        val itemOpt = storage.get(KEY_USER_NAME, swiftArena)
        if (!itemOpt.isPresent) return "Nearby user"
        val bytes = itemOpt.get().value
        return String(bytes, Charsets.UTF_8)
    }

    fun completeOnboarding() {
        val item = StorageItem.init(byteArrayOf(1), swiftArena)
        storage.set(item, KEY_DID_COMPLETE_ONBOARDING)
    }

    fun saveAuthenticatedSession(userName: String) {
        val authItem = StorageItem.init(byteArrayOf(1), swiftArena)
        storage.set(authItem, KEY_IS_AUTHENTICATED)

        val nameItem = StorageItem.init(userName.toByteArray(Charsets.UTF_8), swiftArena)
        storage.set(nameItem, KEY_USER_NAME)
    }

    fun clearSession() {
        val authItem = StorageItem.init(byteArrayOf(0), swiftArena)
        storage.set(authItem, KEY_IS_AUTHENTICATED)
        storage.delete(KEY_USER_NAME)
    }
}
