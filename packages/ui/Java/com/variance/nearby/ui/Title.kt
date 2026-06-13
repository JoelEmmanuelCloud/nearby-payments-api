package com.variance.nearby.ui

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.sp

@Composable
fun Title(
    value: String,
    modifier: Modifier = Modifier,
) {
    Text(
        text = value,
        fontSize = 28.sp,
        fontWeight = FontWeight.SemiBold,
        color = MaterialTheme.colorScheme.onSurface,
        modifier = modifier,
    )
}

@Preview(showBackground = true)
@Composable
private fun TitlePreview() {
    Title(value = "Onboarding page")
}
