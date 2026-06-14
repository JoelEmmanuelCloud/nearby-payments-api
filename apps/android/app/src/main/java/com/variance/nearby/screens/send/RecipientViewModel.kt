package com.variance.nearby.screens.send

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.variance.nearby.core.AppConstants
import com.variance.nearby.services.sui.RecipientService
import com.variance.nearby.ui.ToastController
import com.variance.nearby.ui.ToastTone
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import kotlin.time.Duration.Companion.milliseconds

/**
 * Drives the recipient field's edge-of-field state machine: Idle → Resolving → Resolved ✓ / NotFound
 * ✗. Addresses resolve instantly; SuiNS names debounce then hit the network.
 */
class RecipientViewModel(
    private val service: RecipientService,
    private val toastController: ToastController? = null,
) : ViewModel() {

    sealed interface State {
        data object Idle : State
        data object Invalid : State
        data object Resolving : State
        data class Resolved(val address: String, val name: String?) : State
        data object NotFound : State
    }

    var input by mutableStateOf("")
        private set

    var state by mutableStateOf<State>(State.Idle)
        private set

    private var resolveJob: Job? = null

    /** The address to send to, once a recipient resolves. */
    val resolvedAddress: String?
        get() = (state as? State.Resolved)?.address

    /** Entry point from the text field: reparse, then resolve names after a debounce. */
    fun onInputChange(raw: String) {
        input = raw
        resolveJob?.cancel()

        when (val parsed = RecipientInput.parse(raw)) {
            RecipientInput.Empty -> state = State.Idle
            RecipientInput.Invalid -> state = State.Invalid
            is RecipientInput.Address -> state = State.Resolved(parsed.value, null)
            is RecipientInput.Name -> {
                state = State.Resolving
                resolveJob = viewModelScope.launch {
                    delay(AppConstants.NAME_CHECK_DEBOUNCE_MS.milliseconds)
                    try {
                        val address = withTimeout(AppConstants.NETWORK_TIMEOUT_MS) {
                            withContext(Dispatchers.IO) { service.resolve(parsed.value) }
                        }
                        state = if (address != null) {
                            State.Resolved(address, parsed.value)
                        } else {
                            State.NotFound
                        }
                    } catch (e: TimeoutCancellationException) {
                        state = State.NotFound
                        toastController?.show(
                            "Name lookup timed out. Check your connection.",
                            ToastTone.WARNING,
                        )
                    } catch (_: Exception) {
                        state = State.NotFound
                    }
                }
            }
        }
    }
}
