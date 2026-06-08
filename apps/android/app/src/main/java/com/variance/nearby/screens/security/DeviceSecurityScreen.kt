package com.variance.nearby.screens.security

import android.content.Intent
import android.provider.Settings
import androidx.biometric.BiometricManager
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.variance.nearby.ui.Card
import com.variance.nearby.ui.MutedText
import com.variance.nearby.ui.Title
import com.variance.nearby.ui.UIButton

@Composable
fun DeviceSecurityScreen(
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current

    DeviceSecurityContent(
        onOpenSettings = {
            val intent = Intent(Settings.ACTION_BIOMETRIC_ENROLL).apply {
                putExtra(
                    Settings.EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED,
                    BiometricManager.Authenticators.BIOMETRIC_STRONG,
                )
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            runCatching { context.startActivity(intent) }
                .onFailure {
                    context.startActivity(
                        Intent(Settings.ACTION_SECURITY_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        },
                    )
                }
        },
        modifier = modifier,
    )
}

@Composable
fun DeviceSecurityContent(
    onOpenSettings: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .padding(24.dp),
        verticalArrangement = Arrangement.SpaceBetween,
    ) {
        Spacer(modifier = Modifier.height(24.dp))

        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Title(value = "Set up biometrics")
            MutedText(value = "Nearby needs a strong biometric before sign-in so your secure key can authorize wallet actions.")
        }

        Card {
            MutedText(value = "Device security")
            Spacer(modifier = Modifier.height(8.dp))
            MutedText(value = "Add Face Unlock or fingerprint in Android settings, then return to Nearby to continue.")
            Spacer(modifier = Modifier.height(12.dp))
            UIButton(
                title = "Open settings",
                onClick = onOpenSettings,
            )
        }

        Spacer(modifier = Modifier.height(24.dp))
    }
}

@Preview(showBackground = true)
@Composable
private fun DeviceSecurityScreenPreview() {
    DeviceSecurityContent(
        onOpenSettings = {},
    )
}
