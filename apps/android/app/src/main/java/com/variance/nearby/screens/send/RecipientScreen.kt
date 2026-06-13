package com.variance.nearby.screens.send

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.variance.nearby.R
import com.variance.nearby.screens.activity.shortSuiAddress
import com.variance.nearby.ui.MutedText
import com.variance.nearby.ui.UIButton
import com.variance.nearby.ui.theme.Green40
import java.math.BigDecimal
import java.text.NumberFormat

/**
 * Step 2 of the send flow (#6c): enter the recipient as a SuiNS name or `0x` address. The field shows
 * a live Idle → Resolving → ✓ / ✗ state; [onContinue] hands the resolved address to #6d.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RecipientScreen(
    amount: BigDecimal,
    coinSymbol: String,
    viewModel: RecipientViewModel,
    onBack: () -> Unit,
    onContinue: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = { Text(text = "Recipient", fontWeight = FontWeight.Bold, fontSize = 20.sp) },
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
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            MutedText(value = "Sending ${NumberFormat.getNumberInstance().format(amount)} $coinSymbol")

            OutlinedTextField(
                value = viewModel.input,
                onValueChange = viewModel::onInputChange,
                placeholder = { Text("name.sui or 0x address") },
                singleLine = true,
                keyboardOptions = KeyboardOptions(
                    autoCorrectEnabled = false,
                    capitalization = KeyboardCapitalization.None,
                ),
                trailingIcon = { StatusIcon(viewModel.state) },
                modifier = Modifier.fillMaxWidth(),
            )

            Detail(viewModel.state)

            Spacer(modifier = Modifier.weight(1f))

            UIButton(
                title = "Continue",
                isDisabled = viewModel.resolvedAddress == null,
                onClick = { viewModel.resolvedAddress?.let(onContinue) },
            )
        }
    }
}

@Composable
private fun StatusIcon(state: RecipientViewModel.State) {
    when (state) {
        RecipientViewModel.State.Resolving ->
            CircularProgressIndicator(modifier = Modifier.size(20.dp), strokeWidth = 2.dp)
        is RecipientViewModel.State.Resolved ->
            Icon(
                painter = painterResource(R.drawable.checkmark_seal_filled),
                contentDescription = "Resolved",
                tint = Green40,
                modifier = Modifier.size(20.dp),
            )
        RecipientViewModel.State.Invalid, RecipientViewModel.State.NotFound ->
            Icon(
                painter = painterResource(R.drawable.error_filled),
                contentDescription = "Invalid",
                tint = MaterialTheme.colorScheme.error,
                modifier = Modifier.size(20.dp),
            )
        RecipientViewModel.State.Idle -> Unit
    }
}

@Composable
private fun Detail(state: RecipientViewModel.State) {
    when (state) {
        is RecipientViewModel.State.Resolved ->
            if (state.name != null) {
                Text(
                    text = "→ ${shortSuiAddress(state.address)}",
                    style = MaterialTheme.typography.bodySmall.copy(fontFamily = FontFamily.Monospace),
                    color = Green40,
                )
            }
        RecipientViewModel.State.NotFound ->
            Text(
                text = "Name not found",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.error,
            )
        RecipientViewModel.State.Invalid ->
            Text(
                text = "Enter a valid .sui name or 0x address",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        RecipientViewModel.State.Idle, RecipientViewModel.State.Resolving -> Unit
    }
}
