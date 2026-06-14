package com.variance.nearby.screens.home

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.variance.nearby.core.AccountRefresh
import com.variance.nearby.core.AppConstants
import com.variance.nearby.core.AppSessionStore
import com.variance.nearby.services.sui.BalanceService
import com.variance.nearby.services.sui.ConsolidateService
import com.variance.nearby.ui.ToastController
import com.variance.nearby.ui.ToastTone
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.math.BigDecimal
import java.math.RoundingMode
import kotlin.time.Duration.Companion.milliseconds

/**
 * Owns the Home account-balance state and its 30s polling. Network IO lives in [BalanceService]; this
 * layer holds state, formats for display, and persists the visibility toggle.
 *
 * The balance is shown in two parts: the **address balance** (spendable, the headline number) and a
 * **pending** balance held as coin objects, which the user moves into the address balance with an
 * explicit gasless consolidation ([ConsolidateService]).
 */
class HomeViewModel(
    private val balanceService: BalanceService,
    private val suiAddress: String?,
    private val store: AppSessionStore,
    private val consolidateService: ConsolidateService? = null,
    private val toastController: ToastController? = null,
) : ViewModel() {

    sealed interface BalanceState {
        data object Loading : BalanceState
        data class Amount(val value: BigDecimal) : BalanceState
    }

    // Seed from the cached (spendable) balance so re-entering Home shows the last value immediately.
    var balance by mutableStateOf<BalanceState>(
        store.lastBalance()?.let { BalanceState.Amount(it) } ?: BalanceState.Loading,
    )
        private set

    /** The pending (coin-object) balance awaiting consolidation. Zero when there's nothing to move. */
    var pendingBalance: BigDecimal by mutableStateOf(BigDecimal.ZERO)
        private set

    var isConsolidating by mutableStateOf(false)
        private set

    var isHidden by mutableStateOf(store.balanceHidden())
        private set

    private var pollJob: Job? = null
    private var observerJob: Job? = null

    /** The spendable balance as a 2-decimal string (empty while loading). */
    val formattedBalance: String
        get() = (balance as? BalanceState.Amount)?.value
            ?.setScale(2, RoundingMode.HALF_UP)?.toPlainString() ?: ""

    /** The pending balance as a 2-decimal string. */
    val formattedPendingBalance: String
        get() = pendingBalance.setScale(2, RoundingMode.HALF_UP).toPlainString()

    /** Whether to surface the "move pending balance" call to action. */
    val hasPendingBalance: Boolean get() = pendingBalance.signum() > 0

    /** Whether consolidation can be triggered (a signer-backed service is wired and none is running). */
    val canConsolidate: Boolean get() = consolidateService != null && !isConsolidating

    /** Begins the silent 30s refresh loop and listens for account-change events. Idempotent. */
    fun start() {
        if (pollJob != null) return
        pollJob = viewModelScope.launch {
            while (isActive) {
                refresh()
                delay(AppConstants.BALANCE_REFRESH_MS.milliseconds)
            }
        }
        observerJob = viewModelScope.launch {
            AccountRefresh.events.collect { refresh() }
        }
    }

    fun stop() {
        pollJob?.cancel()
        pollJob = null
        observerJob?.cancel()
        observerJob = null
    }

    fun toggleVisibility() {
        isHidden = !isHidden
        store.setBalanceHidden(isHidden)
    }

    /**
     * Moves the pending (coin-object) balance into the address balance. Gasless. Keeps the loading
     * state until the refresh reflects the move (the pending strip leaves view first), then reports the
     * outcome via a toast and broadcasts the change so Activity refreshes too.
     */
    fun consolidate() {
        val service = consolidateService ?: return
        if (isConsolidating) return
        viewModelScope.launch {
            isConsolidating = true
            try {
                withContext(Dispatchers.IO) { service.consolidate() }
                refreshUntilPendingClears()
                AccountRefresh.post()
                toastController?.show("Moved to balance", ToastTone.SUCCESS)
            } catch (e: Exception) {
                toastController?.show(e.message ?: "Couldn't move balance", ToastTone.DANGER)
            }
            isConsolidating = false
        }
    }

    /**
     * Refreshes until the pending balance reads zero (the consolidation consumed every coin) or the
     * retry budget is spent — absorbing the brief indexer read-after-write lag after execution.
     */
    private suspend fun refreshUntilPendingClears(maxAttempts: Int = 6) {
        repeat(maxAttempts) { attempt ->
            refresh()
            if (pendingBalance.signum() == 0) return
            if (attempt < maxAttempts - 1) delay(1000.milliseconds)
        }
    }

    private suspend fun refresh() {
        val owner = suiAddress
        if (owner.isNullOrEmpty()) return
        try {
            val b = withContext(Dispatchers.IO) { balanceService.breakdown(owner) }
            balance = BalanceState.Amount(b.addressBalance)
            pendingBalance = b.coinBalance
            store.setLastBalance(b.addressBalance)
        } catch (_: Exception) {
            // Keep the last shown balance — stale beats a false 0.
        }
    }
}
