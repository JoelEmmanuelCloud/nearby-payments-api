package com.variance.nearby.ui

import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow

data class ToastEvent(
    val message: String,
    val tone: ToastTone,
)

/**
 * App-wide transient-message bus. Callers invoke [show]; `ToastHost` collects [events] and renders
 * them through compose-sonner. Decouples message producers from the Compose toaster state.
 */
class ToastController {
    private val mutableEvents = MutableSharedFlow<ToastEvent>(extraBufferCapacity = 8)
    val events: SharedFlow<ToastEvent> = mutableEvents.asSharedFlow()

    fun show(
        message: String,
        tone: ToastTone = ToastTone.NEUTRAL,
    ) {
        mutableEvents.tryEmit(ToastEvent(message, tone))
    }
}
