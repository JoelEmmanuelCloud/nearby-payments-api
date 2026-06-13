package com.variance.nearby.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import com.dokar.sonner.ToastType
import com.dokar.sonner.Toaster
import com.dokar.sonner.rememberToasterState

/**
 * Mounts the app-wide compose-sonner toaster over [content], driven by [controller]. The toaster
 * follows the device light/dark theme.
 */
@Composable
fun ToastHost(
    controller: ToastController,
    content: @Composable () -> Unit,
) {
    val toaster = rememberToasterState()
    LaunchedEffect(controller) {
        controller.events.collect { event ->
            toaster.show(event.message, type = event.tone.toToastType())
        }
    }
    Box(modifier = Modifier.fillMaxSize()) {
        content()
        Toaster(state = toaster, darkTheme = isSystemInDarkTheme())
    }
}

private fun ToastTone.toToastType(): ToastType =
    when (this) {
        ToastTone.SUCCESS -> ToastType.Success
        ToastTone.WARNING -> ToastType.Warning
        ToastTone.DANGER -> ToastType.Error
        ToastTone.NEUTRAL -> ToastType.Normal
    }
