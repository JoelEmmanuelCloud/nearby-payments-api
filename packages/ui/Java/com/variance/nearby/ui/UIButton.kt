package com.variance.nearby.ui

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun UIButton(
    title: String,
    modifier: Modifier = Modifier,
    isDisabled: Boolean = false,
    onClick: () -> Unit,
) {
    Button(
        onClick = onClick,
        enabled = !isDisabled,
        shape = RoundedCornerShape(8.dp),
        modifier = modifier.fillMaxWidth(),
        contentPadding = PaddingValues(vertical = 14.dp),
    ) {
        Text(
            text = title,
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun UIButtonPreview() {
    UIButton(
        title = "Continue",
        onClick = {},
    )
}

@Preview(showBackground = true)
@Composable
private fun UIButtonDisabledPreview() {
    UIButton(
        title = "Disabled",
        isDisabled = true,
        onClick = {},
    )
}
