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
import com.variance.nearby.services.sui.BalanceService
import com.variance.nearby.services.sui.RecipientService
import com.variance.nearby.services.sui.SendService
import java.math.BigDecimal

/**
 * Coordinates the send flow: amount entry (#6a / #6b) → recipient, where the gasless send executes
 * inline (#6d) and, once it settles, the success / failure result (#6e). [onExit] dismisses it.
 */
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
            RecipientViewModel(
                RecipientService(viewModel.suiNetwork, viewModel.swiftArena),
                viewModel.toastController,
            )
        }
        val sendViewModel = remember(pendingAmount) {
            SendViewModel(
                amount = pendingAmount,
                service = SendService(
                    network = viewModel.suiNetwork,
                    swiftArena = viewModel.swiftArena,
                    signerProvider = { viewModel.reauthenticatedSigner() },
                ),
            )
        }

        when (val outcome = sendViewModel.result) {
            null -> {
                BackHandler(enabled = !sendViewModel.isSending) { amount = null }
                RecipientScreen(
                    amount = pendingAmount,
                    coinSymbol = AppConstants.BALANCE_COIN_SYMBOL,
                    viewModel = recipientViewModel,
                    sendViewModel = sendViewModel,
                    onBack = { amount = null },
                    modifier = modifier,
                )
            }
            else -> SendResultScreen(
                outcome = outcome,
                amount = pendingAmount,
                coinSymbol = AppConstants.BALANCE_COIN_SYMBOL,
                recipient = recipientViewModel.resolvedAddress ?: "",
                onDone = onExit,
                onRetry = { sendViewModel.reset() },
                modifier = modifier,
            )
        }
    }
}
