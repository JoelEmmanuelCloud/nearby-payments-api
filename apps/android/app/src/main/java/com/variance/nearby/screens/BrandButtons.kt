package com.variance.nearby.screens

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.path
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun AppleSignInButton(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    isDisabled: Boolean = false,
) {
    Button(
        onClick = onClick,
        enabled = !isDisabled,
        shape = RoundedCornerShape(8.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = Color.Black,
            contentColor = Color.White,
        ),
        modifier = modifier.fillMaxWidth(),
        contentPadding = PaddingValues(vertical = 14.dp),
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                imageVector = AppleLogo,
                contentDescription = null,
                tint = Color.White,
                modifier = Modifier.size(18.dp),
            )
            Spacer(modifier = Modifier.width(10.dp))
            Text(
                text = "Sign in with Apple",
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium,
            )
        }
    }
}

private val AppleLogo: ImageVector
    get() = ImageVector.Builder(
        name = "AppleLogo",
        defaultWidth = 24.dp,
        defaultHeight = 24.dp,
        viewportWidth = 24f,
        viewportHeight = 24f,
    ).apply {
        path(fill = SolidColor(Color.White)) {
            moveTo(15.2f, 12.9f)
            curveTo(15.3f, 15.9f, 17.9f, 16.9f, 17.9f, 17f)
            curveTo(17.8f, 17.2f, 17.5f, 17.8f, 17f, 18.5f)
            curveTo(16.3f, 19.6f, 15.5f, 20.6f, 14.4f, 20.6f)
            curveTo(13.3f, 20.6f, 12.9f, 19.9f, 11.6f, 19.9f)
            curveTo(10.3f, 19.9f, 9.9f, 20.6f, 8.8f, 20.6f)
            curveTo(7.7f, 20.6f, 6.8f, 19.7f, 6.1f, 18.6f)
            curveTo(4.6f, 16.4f, 3.4f, 12.4f, 5f, 9.7f)
            curveTo(5.8f, 8.3f, 7.2f, 7.4f, 8.7f, 7.4f)
            curveTo(9.8f, 7.4f, 10.9f, 8.2f, 11.6f, 8.2f)
            curveTo(12.3f, 8.2f, 13.6f, 8.1f, 14.9f, 9.1f)
            curveTo(16.3f, 10.2f, 16.9f, 11.7f, 16.9f, 11.8f)
            curveTo(16.9f, 11.8f, 14f, 13.5f, 15.2f, 12.9f)
            close()
            moveTo(14.2f, 4.2f)
            curveTo(14.8f, 3.4f, 15.3f, 2.3f, 15.1f, 1.1f)
            curveTo(14.1f, 1.2f, 12.8f, 1.8f, 12.1f, 2.7f)
            curveTo(11.5f, 3.4f, 11.1f, 4.5f, 11.2f, 5.6f)
            curveTo(12.3f, 5.7f, 13.5f, 5f, 14.2f, 4.2f)
            close()
        }
    }.build()
