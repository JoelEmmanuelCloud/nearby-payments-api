package com.variance.nearby.screens.send

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.variance.nearby.R
import com.variance.nearby.core.AppConstants
import com.variance.nearby.ui.UIButton
import java.math.BigDecimal

/**
 * Step 1 of the send flow (#6a): enter an amount of the balance coin on a custom numeric keypad,
 * validated against the available balance. [onNext] hands the amount to the recipient step (#6c).
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SendScreen(
    viewModel: SendAmountViewModel,
    onBack: () -> Unit,
    onNext: (BigDecimal) -> Unit,
    modifier: Modifier = Modifier,
) {
    LaunchedEffect(Unit) { viewModel.refreshBalance() }

    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = { Text(text = "Send", fontWeight = FontWeight.Bold, fontSize = 20.sp) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            painter = painterResource(id = R.drawable.arrow_back),
                            contentDescription = "Back",
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.background,
                ),
            )
        },
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(innerPadding)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Spacer(modifier = Modifier.weight(1f))

            Text(
                text = viewModel.input.display,
                fontSize = 56.sp,
                fontWeight = FontWeight.SemiBold,
                maxLines = 1,
                color = if (viewModel.exceedsBalance) {
                    MaterialTheme.colorScheme.error
                } else {
                    MaterialTheme.colorScheme.onSurface
                },
            )
            Text(
                text = AppConstants.BALANCE_COIN_SYMBOL,
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            // Reserve the line so the keypad doesn't jump when the message toggles.
            Text(
                text = if (viewModel.exceedsBalance) "Insufficient balance" else " ",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.error,
            )

            Spacer(modifier = Modifier.weight(1f))

            QuickSelectChips(
                suggestions = viewModel.suggestions,
                isEnabled = viewModel::isWithinBalance,
                onSelect = viewModel::select,
                modifier = Modifier.fillMaxWidth(),
            )

            Spacer(modifier = Modifier.height(12.dp))

            NumericKeypad(
                onKey = viewModel::handle,
                modifier = Modifier.fillMaxWidth(),
            )

            Spacer(modifier = Modifier.height(16.dp))

            UIButton(
                title = "Next",
                isDisabled = !viewModel.canContinue,
                onClick = { onNext(viewModel.input.decimalValue) },
            )
        }
    }
}
