package com.variance.nearby.screens.send

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.variance.nearby.R

/** The custom 3×4 numeric keypad for entering a send amount. Stateless — taps are reported via [onKey]. */
@Composable
fun NumericKeypad(
    onKey: (KeypadKey) -> Unit,
    modifier: Modifier = Modifier,
) {
    val rows = listOf(
        listOf(KeypadKey.Digit(1), KeypadKey.Digit(2), KeypadKey.Digit(3)),
        listOf(KeypadKey.Digit(4), KeypadKey.Digit(5), KeypadKey.Digit(6)),
        listOf(KeypadKey.Digit(7), KeypadKey.Digit(8), KeypadKey.Digit(9)),
        listOf(KeypadKey.Decimal, KeypadKey.Digit(0), KeypadKey.Backspace),
    )
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(10.dp)) {
        rows.forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                row.forEach { key ->
                    Key(key = key, onClick = { onKey(key) }, modifier = Modifier.weight(1f))
                }
            }
        }
    }
}

@Composable
private fun Key(key: KeypadKey, onClick: () -> Unit, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .height(56.dp)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        val content = when (key) {
            KeypadKey.Backspace -> null
            KeypadKey.Decimal -> "•"
            is KeypadKey.Digit -> key.value.toString()
        }
        if (!content.isNullOrEmpty()) {
            Text(
                text = content,
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurface,
            )
        } else {
            Icon(
                painter = painterResource(R.drawable.backspace),
                contentDescription = null,
                modifier = Modifier.size(20.dp),
            )
        }
    }
}
