package com.variance.nearby.screens.send

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.variance.nearby.R
import com.variance.nearby.screens.activity.shortSuiAddress
import com.variance.nearby.ui.UIButton
import com.variance.nearby.ui.theme.Green40
import java.math.BigDecimal
import java.text.NumberFormat

/**
 * The terminal screen of the send flow (#6e): the outcome of a gasless transfer — success with the
 * on-chain digest, or a failure with its message. Reached only after the transaction settles, so it
 * never shows a loading state. [onDone] dismisses the whole flow; [onRetry] returns to the recipient
 * screen to try again.
 */
@Composable
fun SendResultScreen(
    outcome: SendViewModel.Outcome,
    amount: BigDecimal,
    coinSymbol: String,
    recipient: String,
    onDone: () -> Unit,
    onRetry: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Spacer(modifier = Modifier.weight(1f))

        when (outcome) {
            is SendViewModel.Outcome.Success -> {
                Icon(
                    painter = painterResource(R.drawable.checkmark_seal_filled),
                    contentDescription = null,
                    tint = Green40,
                    modifier = Modifier.size(56.dp),
                )
                Text("Sent", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.SemiBold)
                Text(
                    text = "${NumberFormat.getNumberInstance().format(amount)} $coinSymbol " +
                        "to ${shortSuiAddress(recipient)}",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                )
                Text(
                    text = shortSuiAddress(outcome.digest),
                    style = MaterialTheme.typography.bodySmall.copy(fontFamily = FontFamily.Monospace),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            is SendViewModel.Outcome.Failure -> {
                Icon(
                    painter = painterResource(R.drawable.error_filled),
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.error,
                    modifier = Modifier.size(56.dp),
                )
                Text(
                    "Couldn't send",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.SemiBold,
                )
                Text(
                    text = outcome.message,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                )
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        when (outcome) {
            is SendViewModel.Outcome.Success ->
                UIButton(title = "Done", modifier = Modifier.fillMaxWidth(), onClick = onDone)
            is SendViewModel.Outcome.Failure ->
                UIButton(title = "Try again", modifier = Modifier.fillMaxWidth(), onClick = onRetry)
        }
    }
}
