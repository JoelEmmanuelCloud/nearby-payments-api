package com.variance.nearby.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

enum class BadgeTone {
    SUCCESS,
    NEUTRAL,
    WARNING,
    DANGER,
}

/** A small labeled pill, e.g. a "Registered" status tag. Generic — the caller supplies text + tone. */
@Composable
fun Badge(
    text: String,
    tone: BadgeTone = BadgeTone.NEUTRAL,
    modifier: Modifier = Modifier,
) {
    val foreground =
        when (tone) {
            BadgeTone.SUCCESS -> Color(0xFF1B873F)
            BadgeTone.NEUTRAL -> MaterialTheme.colorScheme.onSurfaceVariant
            BadgeTone.WARNING -> Color(0xFFB26A00)
            BadgeTone.DANGER -> MaterialTheme.colorScheme.error
        }
    Text(
        text = text,
        style = MaterialTheme.typography.bodySmall,
        fontWeight = FontWeight.Bold,
        color = foreground,
        modifier =
            modifier
                .clip(RoundedCornerShape(8.dp))
                .background(foreground.copy(alpha = 0.15f))
                .padding(horizontal = 10.dp, vertical = 5.dp),
    )
}
