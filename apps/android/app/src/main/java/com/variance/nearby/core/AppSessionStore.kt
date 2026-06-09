package com.variance.nearby.core

import com.variance.nearby.storage.SecureStorage
import com.variance.nearby.storage.StorageItem
import org.json.JSONObject
import org.swift.swiftkit.core.SwiftArena

/** Non-secret profile fields cached for instant display + offline fallback (mirrors iOS UserDefaults). */
data class CachedProfile(
    val suinsName: String?,
    val avatarUrl: String?,
)

class AppSessionStore(
    private val storage: SecureStorage,
    private val swiftArena: SwiftArena,
) {
    companion object {
        private const val KEY_DID_COMPLETE_ONBOARDING = "nearby.didCompleteOnboarding"
        private const val KEY_DID_COMPLETE_PROFILE_SETUP = "nearby.didCompleteProfileSetup"
        private const val KEY_USER_NAME = "nearby.userName"
        private fun profileKey(userId: String) = "nearby.profile.$userId"
    }

    fun didCompleteOnboarding(): Boolean {
        val itemOpt = storage.get(KEY_DID_COMPLETE_ONBOARDING, swiftArena)
        if (!itemOpt.isPresent) return false
        val bytes = itemOpt.get().value
        return bytes.firstOrNull() == 1.toByte()
    }

    /**
     * Whether the user has finished first-run profile setup (e.g. registered a SuiNS name). Used to
     * route post-login to Home vs the setup flow, since `suiAddress` is now always present.
     */
    fun didCompleteProfileSetup(): Boolean {
        val itemOpt = storage.get(KEY_DID_COMPLETE_PROFILE_SETUP, swiftArena)
        if (!itemOpt.isPresent) return false
        val bytes = itemOpt.get().value
        return bytes.firstOrNull() == 1.toByte()
    }

    fun completeProfileSetup() {
        val item = StorageItem.init(byteArrayOf(1), swiftArena)
        storage.set(item, KEY_DID_COMPLETE_PROFILE_SETUP)
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

    fun saveUserName(userName: String) {
        val nameItem = StorageItem.init(userName.toByteArray(Charsets.UTF_8), swiftArena)
        storage.set(nameItem, KEY_USER_NAME)
    }

    fun clearUserName() {
        storage.delete(KEY_USER_NAME)
    }

    // MARK: - Identity profile cache
    //
    // Non-secret profile metadata, keyed by userId, for instant display + offline fallback. Stored in
    // the preferences-backed storage (DataStore later); avatar *images* are loaded from `avatarUrl` by
    // Coil, not cached here.

    fun cacheProfile(userId: String, suinsName: String?, avatarUrl: String?) {
        val json = JSONObject()
        suinsName?.let { json.put("suinsName", it) }
        avatarUrl?.let { json.put("avatarUrl", it) }
        val item = StorageItem.init(json.toString().toByteArray(Charsets.UTF_8), swiftArena)
        storage.set(item, profileKey(userId))
    }

    fun cachedProfile(userId: String): CachedProfile? {
        val itemOpt = storage.get(profileKey(userId), swiftArena)
        if (!itemOpt.isPresent) return null
        return try {
            val json = JSONObject(String(itemOpt.get().value, Charsets.UTF_8))
            CachedProfile(
                suinsName = json.optString("suinsName").ifEmpty { null },
                avatarUrl = json.optString("avatarUrl").ifEmpty { null },
            )
        } catch (e: Exception) {
            null
        }
    }
}
