package com.variance.nearby.screens.activity

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.variance.nearby.core.AppConstants
import com.variance.nearby.core.AppSessionStore
import com.variance.nearby.services.sui.ActivityService
import com.variance.nearby.ui.ToastController
import com.variance.nearby.ui.ToastTone
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout

/**
 * Owns the Activity feed: an append-only list of rows with cursor-based infinite scroll. Network IO
 * and formatting live in `ActivityService` / the shared package; this holds state + transitions.
 */
class ActivityViewModel(
    private val service: ActivityService,
    private val address: String?,
    private val store: AppSessionStore,
    private val toastController: ToastController? = null,
) : ViewModel() {

    enum class Phase { LOADING, CONTENT, EMPTY, ERROR }

    // Seed from cache so re-entering Activity shows the last-known feed immediately (no skeleton);
    // `load` then refreshes it silently.
    private val cachedRows: List<ActivityRow> =
        address?.takeIf { it.isNotEmpty() }?.let { store.cachedActivity(it) } ?: emptyList()

    var phase by mutableStateOf(if (cachedRows.isEmpty()) Phase.LOADING else Phase.CONTENT)
        private set

    var items by mutableStateOf(cachedRows)
        private set

    var isLoadingMore by mutableStateOf(false)
        private set

    /** True while a refresh (pull) is in flight; drives the pull-to-refresh indicator. */
    var isRefreshing by mutableStateOf(false)
        private set

    private var cursor: String? = null
    private var canLoadMore = false

    /** Initial load (and pull-to-refresh): resets to the newest page. */
    fun load() {
        val addr = address
        if (addr.isNullOrEmpty()) {
            phase = Phase.EMPTY
            return
        }
        if (items.isEmpty()) phase = Phase.LOADING
        viewModelScope.launch {
            isRefreshing = true
            try {
                var page = withTimeout(AppConstants.NETWORK_TIMEOUT_MS) {
                    withContext(Dispatchers.IO) { service.activity(addr, null) }
                }
                var accumulated = page.items
                cursor = page.nextCursor
                canLoadMore = page.hasMore

                // Coin-filtering can yield an empty first page while older pages still hold matching
                // rows; pull a few more so the user doesn't see a false "no activity". Bounded.
                var guard = 0
                while (accumulated.isEmpty() && canLoadMore && guard < 5) {
                    guard++
                    page = withContext(Dispatchers.IO) { service.activity(addr, cursor) }
                    accumulated = accumulated + page.items
                    cursor = page.nextCursor
                    canLoadMore = page.hasMore
                }

                items = accumulated
                phase = if (accumulated.isEmpty()) Phase.EMPTY else Phase.CONTENT
                store.cacheActivity(accumulated, addr)
            } catch (e: TimeoutCancellationException) {
                if (items.isEmpty()) phase = Phase.ERROR
                toastController?.show(
                    "Couldn't refresh activity. Check your connection.",
                    ToastTone.WARNING,
                )
            } catch (e: Exception) {
                if (items.isEmpty()) phase = Phase.ERROR
            } finally {
                isRefreshing = false
            }
        }
    }

    /** Appends the next older page; no-ops while already loading or exhausted. */
    fun loadMore() {
        val addr = address ?: return
        if (!canLoadMore || isLoadingMore) return
        isLoadingMore = true
        viewModelScope.launch {
            try {
                val page = withContext(Dispatchers.IO) { service.activity(addr, cursor) }
                items = items + page.items
                cursor = page.nextCursor
                canLoadMore = page.hasMore
            } catch (_: Exception) {
                // Keep what's shown; the row-level loader simply stops.
            } finally {
                isLoadingMore = false
            }
        }
    }
}
