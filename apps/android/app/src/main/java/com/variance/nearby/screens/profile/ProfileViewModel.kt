package com.variance.nearby.screens.profile

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.variance.nearby.auth.SessionManager
import com.variance.nearby.core.AppSessionStore
import com.variance.nearby.deviceintegrity.PlayIntegrityProvider
import com.variance.nearby.identity.IdentityManager
import com.variance.nearby.identity.IdentityProfile
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.future.await
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.swift.swiftkit.core.SwiftArena

class ProfileViewModel(
    private val identityManager: IdentityManager,
    private val sessionManager: SessionManager,
    private val store: AppSessionStore,
    private val userId: String,
    val isSetupMode: Boolean,
    private val swiftArena: SwiftArena,
    val onFinish: () -> Unit,
) : ViewModel() {

    /** True until the first resolution (cache prefill or fetch) completes; drives the badge spinner. */
    var isLoading by mutableStateOf(true)
        private set

    /** The registered SuiNS name, or null if none. Single source of truth for "registered". */
    var suinsName by mutableStateOf<String?>(null)
        private set

    var suiAddress by mutableStateOf<String?>(null)
        private set

    /** Remote avatar URL — loaded and memory+disk-cached by Coil. No image blobs are stored. */
    var avatarUrl by mutableStateOf<String?>(null)
        private set

    /** A just-picked local image, shown immediately while the upload/URL round-trips. */
    var pickedAvatarData by mutableStateOf<ByteArray?>(null)
        private set

    // Edit-screen state
    var nameInput by mutableStateOf("")
        private set
    var statusMessage by mutableStateOf<String?>(null)
        private set
    var isAvailable by mutableStateOf(false)
        private set
    var isSaving by mutableStateOf(false)
        private set

    private var nameCheckJob: Job? = null

    val isRegistered: Boolean get() = suinsName != null

    val displayName: String get() = suinsName?.let { "$it.nearby.sui" } ?: "yourname.nearby.sui"

    companion object {
        /** SuiNS labels are lowercase [a-z0-9-]; strip everything else so the gateway never errors. */
        fun sanitize(raw: String): String = raw.lowercase().filter { it in 'a'..'z' || it in '0'..'9' || it == '-' }
    }

    fun loadProfile() {
        // 1. Read the stable address that the zkLogin layer persisted at login.
        loadAddress()

        // 2. Prefill from the app-side cache for an instant badge resolution on re-entry.
        store.cachedProfile(userId)?.let {
            applyValues(it.suinsName, it.avatarUrl)
            isLoading = false
        }

        // 3. Fetch fresh in the background.
        val addr = suiAddress
        viewModelScope.launch(Dispatchers.IO) {
            if (addr == null) {
                withContext(Dispatchers.Main) { isLoading = false }
                return@launch
            }
            try {
                val remoteProfile = identityManager.fetchProfile(addr, swiftArena).await()
                withContext(Dispatchers.Main) {
                    applyProfile(remoteProfile)
                    if (isSetupMode && suinsName != null) {
                        onFinish()
                    }
                }
            } catch (e: Exception) {
                println("Android ProfileViewModel remote fetch failed: ${e.localizedMessage}")
            } finally {
                withContext(Dispatchers.Main) { isLoading = false }
            }
        }
    }

    private fun applyProfile(profile: IdentityProfile) {
        applyValues(profile.suinsName.orElse(null), profile.avatarUrl.orElse(null))
        store.cacheProfile(userId, suinsName, avatarUrl)
    }

    private fun applyValues(name: String?, avatar: String?) {
        suinsName = name?.ifEmpty { null }
        avatarUrl = avatar
    }

    private fun loadAddress() {
        try {
            val sessionOpt = sessionManager.getCurrentSession(swiftArena)
            if (sessionOpt.isPresent) {
                val suiAddressOpt = sessionOpt.get().suiAddress
                if (suiAddressOpt.isPresent && suiAddressOpt.get().isNotEmpty()) {
                    suiAddress = suiAddressOpt.get()
                }
            }
        } catch (e: Exception) {
            println("Android ProfileViewModel failed to read address: ${e.localizedMessage}")
        }
    }

    /** Clears transient name-entry state so the edit screen always starts fresh. */
    fun resetNameEntry() {
        nameCheckJob?.cancel()
        nameInput = ""
        statusMessage = null
        isAvailable = false
    }

    fun onNameInputChange(input: String) {
        val clean = sanitize(input)
        nameInput = clean
        isAvailable = false
        statusMessage = null
        nameCheckJob?.cancel()

        if (clean.isEmpty() || suinsName != null) return

        nameCheckJob = viewModelScope.launch {
            delay(500) // Debounce 500ms
            checkNameAvailability(clean)
        }
    }

    private suspend fun checkNameAvailability(leafName: String) = withContext(Dispatchers.IO) {
        withContext(Dispatchers.Main) {
            statusMessage = "Checking availability..."
        }
        try {
            val res = identityManager.checkNameAvailability(leafName, swiftArena).await()
            withContext(Dispatchers.Main) {
                isAvailable = res.isAvailable
                statusMessage = if (res.isAvailable) "Name is available!" else "Name is already taken."
            }
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                statusMessage = "Could not verify name: ${e.localizedMessage}"
            }
        }
    }

    fun registerProfileName() {
        if (!isAvailable || nameInput.isEmpty() || suinsName != null) return
        isSaving = true
        statusMessage = "Registering name..."

        viewModelScope.launch(Dispatchers.IO) {
            try {
                val deviceProvider = PlayIntegrityProvider.PROVIDER

                val regRes = identityManager.registerName(
                    nameInput,
                    deviceProvider,
                    swiftArena,
                ).await()

                withContext(Dispatchers.Main) {
                    statusMessage = "Polling registration status..."
                }

                identityManager.pollNameTask(
                    regRes.taskId,
                    deviceProvider,
                    2.0,
                    15,
                    swiftArena,
                ).await()

                withContext(Dispatchers.Main) {
                    isSaving = false
                    suinsName = nameInput
                    statusMessage = "Name registered successfully!"
                    store.cacheProfile(userId, suinsName, avatarUrl)
                    if (isSetupMode) {
                        onFinish()
                    }
                }

                // Refresh profile (name + avatar) from on-chain truth after registration.
                suiAddress?.let { addr ->
                    val refreshed = identityManager.fetchProfile(addr, swiftArena).await()
                    withContext(Dispatchers.Main) { applyProfile(refreshed) }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    isSaving = false
                    statusMessage = "Registration failed: ${e.localizedMessage}"
                }
            }
        }
    }

    fun uploadAvatar(bytes: ByteArray) {
        isSaving = true
        pickedAvatarData = bytes // show the picked image immediately
        statusMessage = "Uploading avatar..."
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val newUrl = identityManager
                    .updateAvatar(bytes, "image/jpeg")
                    .await()
                withContext(Dispatchers.Main) {
                    avatarUrl = newUrl
                    store.cacheProfile(userId, suinsName, newUrl)
                    isSaving = false
                    statusMessage = "Avatar updated!"
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    isSaving = false
                    statusMessage = "Avatar upload failed: ${e.localizedMessage}"
                }
            }
        }
    }
}
