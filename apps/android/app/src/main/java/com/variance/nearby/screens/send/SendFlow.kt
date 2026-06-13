package com.variance.nearby.screens.send

import androidx.activity.compose.BackHandler
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.variance.nearby.core.AppConstants
import com.variance.nearby.core.AppViewModel
import com.variance.nearby.screens.home.BalanceService
import java.math.BigDecimal

/** Coordinates the send flow: amount entry (#6a / #6b) → recipient (#6c). [onExit] dismisses it. */
@Composable
fun SendFlow(
    viewModel: AppViewModel,
    onExit: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val sendAmountViewModel = remember(viewModel) {
        SendAmountViewModel(
            balanceService = BalanceService(viewModel.suiNetwork, viewModel.swiftArena),
            store = viewModel.sessionStore,
            address = viewModel.currentSuiAddress,
            maxFractionDigits = AppConstants.BALANCE_COIN_DECIMALS,
        )
    }

    var amount by remember { mutableStateOf<BigDecimal?>(null) }

    val pendingAmount = amount
    if (pendingAmount == null) {
        BackHandler { onExit() }
        SendScreen(
            viewModel = sendAmountViewModel,
            onBack = onExit,
            onNext = { amount = it },
            modifier = modifier,
        )
    } else {
        val recipientViewModel = remember {
            RecipientViewModel(RecipientService(viewModel.suiNetwork, viewModel.swiftArena))
        }
        BackHandler { amount = null }
        RecipientScreen(
            amount = pendingAmount,
            coinSymbol = AppConstants.BALANCE_COIN_SYMBOL,
            viewModel = recipientViewModel,
            onBack = { amount = null },
            onContinue = { /* 6d: build/sign/execute the gasless send. */ },
            modifier = modifier,
        )
    }
}
