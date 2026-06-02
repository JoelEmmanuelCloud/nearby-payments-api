package com.variance.nearby.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.isSystemInDarkTheme
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

@Composable
fun GoogleSignInButton(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    isDisabled: Boolean = false,
) {
    val isDark = isSystemInDarkTheme()
    val containerColor = if (isDark) Color(0xFF131314) else Color(0xFFFFFFFF)
    val contentColor = if (isDark) Color(0xFFE3E3E3) else Color(0xFF1F1F1F)
    val borderColor = if (isDark) Color(0xFF8E918F) else Color(0xFF747775)

    Button(
        onClick = onClick,
        enabled = !isDisabled,
        shape = RoundedCornerShape(8.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = containerColor,
            contentColor = contentColor,
        ),
        border = BorderStroke(1.dp, borderColor),
        modifier = modifier.fillMaxWidth(),
        contentPadding = PaddingValues(vertical = 14.dp),
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                imageVector = GoogleLogo,
                contentDescription = null,
                tint = Color.Unspecified, // Keep Google's original multicolored brand colors
                modifier = Modifier.size(18.dp),
            )
            Spacer(modifier = Modifier.width(10.dp))
            Text(
                text = "Sign in with Google",
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium,
            )
        }
    }
}

private val GoogleLogo: ImageVector
    get() = ImageVector.Builder(
        name = "GoogleLogo",
        defaultWidth = 24.dp,
        defaultHeight = 24.dp,
        viewportWidth = 512f,
        viewportHeight = 512f,
    ).apply {
        // Blue path
        path(fill = SolidColor(Color(0xFF4285F4))) {
            moveTo(482.6f, 261.4f)
            curveToRelative(0f, -16.7f, -1.5f, -32.8f, -4.3f, -48.3f)
            horizontalLineTo(256f)
            verticalLineToRelative(91.3f)
            horizontalLineToRelative(127f)
            curveToRelative(-5.5f, 29.5f, -22.1f, 54.5f, -47.1f, 71.2f)
            verticalLineToRelative(59.2f)
            horizontalLineToRelative(76.3f)
            curveToRelative(44.6f, -41.1f, 70.4f, -101.6f, 70.4f, -173.5f)
            close()
        }
        // Green path
        path(fill = SolidColor(Color(0xFF34A853))) {
            moveTo(256f, 492f)
            curveToRelative(63.7f, 0f, 117.1f, -21.1f, 156.2f, -57.2f)
            lineToRelative(-76.3f, -59.2f)
            curveToRelative(-21.1f, 14.2f, -48.2f, 22.5f, -79.9f, 22.5f)
            curveToRelative(-61.5f, 0f, -113.5f, -41.5f, -132.1f, -97.3f)
            horizontalLineTo(45.1f)
            verticalLineToRelative(61.2f)
            curveToRelative(38.8f, 77.1f, 118.6f, 130f, 210.9f, 130f)
            close()
        }
        // Yellow path
        path(fill = SolidColor(Color(0xFFFBBC05))) {
            moveTo(123.9f, 300.8f)
            curveToRelative(-4.7f, -14.2f, -7.4f, -29.3f, -7.4f, -44.8f)
            reflectiveCurveToRelative(2.7f, -30.7f, 7.4f, -44.8f)
            verticalLineTo(150f)
            horizontalLineTo(45.1f)
            curveTo(29.1f, 181.9f, 20f, 217.9f, 20f, 256f)
            curveToRelative(0f, 38.1f, 9.1f, 74.1f, 25.1f, 106f)
            lineToRelative(78.8f, -61.2f)
            close()
        }
        // Red path
        path(fill = SolidColor(Color(0xFFEA4335))) {
            moveTo(256f, 113.9f)
            curveToRelative(34.7f, 0f, 65.8f, 11.9f, 90.2f, 35.3f)
            lineToRelative(67.7f, -67.7f)
            curveTo(373f, 43.4f, 319.6f, 20f, 256f, 20f)
            curveTo(163.7f, 20f, 83.9f, 72.9f, 45.1f, 150f)
            lineToRelative(78.8f, 61.2f)
            curveToRelative(18.6f, -55.8f, 70.6f, -97.3f, 132.1f, -97.3f)
            close()
        }
    }.build()
