package com.variance.nearby.ui

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.sp

@Composable
fun MutedText(
    value: String,
    modifier: Modifier = Modifier,
) {
    Text(
        text = value,
        fontSize = 14.sp,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        modifier = modifier,
    )
}

@Preview(showBackground = true)
@Composable
private fun MutedTextPreview() {
    MutedText(value = "Secondary text keeps supporting content quieter than the main title.")
}
