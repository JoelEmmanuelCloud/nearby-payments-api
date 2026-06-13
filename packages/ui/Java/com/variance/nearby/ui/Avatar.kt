package com.variance.nearby.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.variance.nearby.R

/**
 * A circular avatar. Loader-agnostic: pass the resolved image (e.g. Coil `AsyncImage`) as [content];
 * when none is supplied it shows a system person placeholder. The `ui` package stays image-loader-free.
 */
@Composable
fun Avatar(
    size: Dp,
    modifier: Modifier = Modifier,
    content: (@Composable BoxScope.() -> Unit)? = null,
) {
    Box(
        modifier =
            modifier
                .size(size)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.surfaceVariant)
                .border(1.dp, MaterialTheme.colorScheme.outline, CircleShape),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            painter = painterResource(id = R.drawable.account_circle),
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.fillMaxSize(),
        )
        // The supplied image (if any) overlays and covers the placeholder.
        content?.invoke(this)
    }
}
