package com.variance.nearby.screens.send

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.variance.nearby.core.AppSessionStore
import com.variance.nearby.screens.home.BalanceService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.math.BigDecimal

/**
 * Owns the send-amount entry: the keypad mutates an [AmountInput], and the typed amount is validated
 * against the available balance. The balance is seeded from cache (instant) and refreshed once when
 * the screen appears, so validation is live without re-fetching on every keystroke.
 */
class SendAmountViewModel(
    private val balanceService: BalanceService,
    private val store: AppSessionStore,
    private val address: String?,
    maxFractionDigits: Int,
) : ViewModel() {

    var input by mutableStateOf(AmountInput(maxFractionDigits = maxFractionDigits))
        private set

    /** Spendable balance of the send coin. Null until known — while unknown we don't block. */
    var availableBalance by mutableStateOf(store.lastBalance())
        private set

    /** True once a positive amount strictly exceeds the known balance. */
    val exceedsBalance: Boolean
        get() = availableBalance?.let { input.decimalValue > it } ?: false

    /** Whether the entry can advance: a positive amount that fits the balance. */
    val canContinue: Boolean
        get() = input.isValid && !exceedsBalance

    fun handle(key: KeypadKey) {
        input = when (key) {
            is KeypadKey.Digit -> input.appendDigit(key.value)
            KeypadKey.Decimal -> input.appendDecimal()
            KeypadKey.Backspace -> input.backspace()
        }
    }

    /** One-shot freshness fetch on screen appear; falls back to the seeded cache value on failure. */
    fun refreshBalance() {
        val addr = address ?: return
        viewModelScope.launch {
            try {
                val amount: BigDecimal = withContext(Dispatchers.IO) { balanceService.usdSuiBalance(addr) }
                availableBalance = amount
                store.setLastBalance(amount)
            } catch (_: Exception) {
                // Keep the seeded value — stale beats blocking the user on a transient failure.
            }
        }
    }
}
