package com.variance.nearby.screens.home

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.variance.nearby.core.AppConstants
import com.variance.nearby.core.AppSessionStore
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.math.BigDecimal
import java.math.RoundingMode

/**
 * Owns the Home account-balance state and its 30s polling. Network IO lives in [BalanceService]; this
 * layer holds state, formats for display, and persists the visibility toggle.
 */
class HomeViewModel(
    private val balanceService: BalanceService,
    private val suiAddress: String?,
    private val store: AppSessionStore,
) : ViewModel() {

    sealed interface BalanceState {
        data object Loading : BalanceState
        data class Amount(val value: BigDecimal) : BalanceState
    }

    // Seed from the cached balance so re-entering Home shows the last value immediately (no skeleton).
    var balance by mutableStateOf<BalanceState>(
        store.lastBalance()?.let { BalanceState.Amount(it) } ?: BalanceState.Loading,
    )
        private set

    var isHidden by mutableStateOf(store.balanceHidden())
        private set

    private var pollJob: Job? = null

    /** The balance as a 2-decimal string (empty while loading). */
    val formattedBalance: String
        get() = (balance as? BalanceState.Amount)?.value
            ?.setScale(2, RoundingMode.HALF_UP)?.toPlainString() ?: ""

    /** Begins the silent 30s refresh loop. Idempotent. */
    fun start() {
        if (pollJob != null) return
        pollJob = viewModelScope.launch {
            while (isActive) {
                refresh()
                delay(AppConstants.BALANCE_REFRESH_MS)
            }
        }
    }

    fun stop() {
        pollJob?.cancel()
        pollJob = null
    }

    fun toggleVisibility() {
        isHidden = !isHidden
        store.setBalanceHidden(isHidden)
    }

    private suspend fun refresh() {
        val owner = suiAddress
        if (owner.isNullOrEmpty()) return
        try {
            val amount = withContext(Dispatchers.IO) { balanceService.usdSuiBalance(owner) }
            balance = BalanceState.Amount(amount)
            store.setLastBalance(amount)
        } catch (_: Exception) {
            // Keep the last shown balance — stale beats a false 0.
        }
    }
}
