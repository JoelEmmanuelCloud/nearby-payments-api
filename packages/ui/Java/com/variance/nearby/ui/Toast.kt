package com.variance.nearby.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

enum class ToastTone {
    SUCCESS,
    WARNING,
    DANGER,
    NEUTRAL,
    ;

    val color: Color
        @Composable
        get() =
            when (this) {
                SUCCESS -> Color.Green
                WARNING -> Color(0xFFFFA500) // Orange
                DANGER -> Color.Red
                NEUTRAL -> MaterialTheme.colorScheme.onSurfaceVariant
            }
}

@Composable
fun Toast(
    title: String,
    tone: ToastTone = ToastTone.NEUTRAL,
    modifier: Modifier = Modifier,
) {
    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(8.dp),
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.8f), // thinMaterial equivalent
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                modifier =
                    Modifier
                        .size(8.dp)
                        .background(tone.color, CircleShape),
            )

            Text(
                text = title,
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onSurface,
            )

            Spacer(modifier = Modifier.width(1.dp))
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun ToastNeutralPreview() {
    Toast(title = "Neutral notification")
}

@Preview(showBackground = true)
@Composable
private fun ToastSuccessPreview() {
    Toast(title = "Success message", tone = ToastTone.SUCCESS)
}

@Preview(showBackground = true)
@Composable
private fun ToastWarningPreview() {
    Toast(title = "Warning warning!", tone = ToastTone.WARNING)
}

@Preview(showBackground = true)
@Composable
private fun ToastDangerPreview() {
    Toast(title = "Danger occurred!", tone = ToastTone.DANGER)
}
