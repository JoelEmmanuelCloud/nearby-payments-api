package com.variance.nearby.screens.send

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.variance.nearby.core.AccountRefresh
import com.variance.nearby.services.sui.SendService
import kotlinx.coroutines.launch
import java.math.BigDecimal

/**
 * Drives the send execution that runs from the recipient screen (#6d): an idle → sending →
 * success / failure machine around [SendService]. The amount is fixed for the screen's lifetime; the
 * recipient is supplied at send time (once it has resolved).
 */
class SendViewModel(
    val amount: BigDecimal,
    private val service: SendService,
) : ViewModel() {

    sealed interface Outcome {
        data class Success(val digest: String) : Outcome
        data class Failure(val message: String) : Outcome
    }

    var isSending by mutableStateOf(false)
        private set

    /** Set once the transaction settles; drives navigation to the result screen. */
    var result by mutableStateOf<Outcome?>(null)
        private set

    /**
     * Executes the gasless send to [recipient]. On success, broadcasts the account change so the
     * balance- and activity-backed screens refresh before the user returns to them.
     */
    fun send(recipient: String) {
        if (isSending) return
        viewModelScope.launch {
            isSending = true
            result = try {
                val digest = service.send(amount, recipient)
                AccountRefresh.post()
                Outcome.Success(digest)
            } catch (e: Exception) {
                Outcome.Failure(e.message ?: "Couldn't send")
            }
            isSending = false
        }
    }

    /** Returns to the recipient screen to try again. */
    fun reset() {
        result = null
    }
}
