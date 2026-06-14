package com.variance.nearby.core

import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow

/**
 * App-wide signal that the account's on-chain state changed (a send or consolidation executed), so
 * balance- and activity-backed screens should refresh. Posted by the gasless write actions and
 * observed by the Home and Activity view models.
 */
object AccountRefresh {
    private val _events = MutableSharedFlow<Unit>(extraBufferCapacity = 16)
    val events: SharedFlow<Unit> = _events

    /** Announce that the account changed. */
    fun post() {
        _events.tryEmit(Unit)
    }
}
