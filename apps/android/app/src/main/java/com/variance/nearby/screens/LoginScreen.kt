package com.variance.nearby.screens

import android.content.Intent
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
import androidx.core.net.toUri
import com.variance.nearby.AppViewModel
import com.variance.nearby.ui.Card
import com.variance.nearby.ui.MutedText
import com.variance.nearby.ui.Title

@Composable
fun LoginScreen(
    viewModel: AppViewModel,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current

    LoginContent(
        isSigningIn = viewModel.isSigningIn,
        statusMessage = viewModel.statusMessage,
        onSignInWithGoogle = { viewModel.signInWithGoogle() },
        onSignInWithApple = {
            viewModel.signInWithApple { url ->
                val intent = Intent(Intent.ACTION_VIEW, url.toUri()).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
            }
        },
        modifier = modifier,
    )
}

@Composable
fun LoginContent(
    isSigningIn: Boolean,
    statusMessage: String?,
    onSignInWithGoogle: () -> Unit,
    onSignInWithApple: () -> Unit,
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

        // Sign in Header
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Title(value = "Sign in")
            MutedText(value = "Choose a provider to continue to your Nearby account.")
        }

        // Account Providers Card
        Card {
            MutedText(value = "Account")

            Spacer(modifier = Modifier.height(8.dp))

            AppleSignInButton(
                isDisabled = isSigningIn,
                onClick = onSignInWithApple,
            )

            Spacer(modifier = Modifier.height(8.dp))

            GoogleSignInButton(
                isDisabled = isSigningIn,
                onClick = onSignInWithGoogle,
            )

            statusMessage?.let { message ->
                Spacer(modifier = Modifier.height(8.dp))
                MutedText(value = message)
            }
        }

        Spacer(modifier = Modifier.height(24.dp))
    }
}

@Preview(showBackground = true)
@Composable
private fun LoginScreenPreview() {
    LoginContent(
        isSigningIn = false,
        statusMessage = null,
        onSignInWithGoogle = {},
        onSignInWithApple = {},
    )
}

@Preview(showBackground = true)
@Composable
private fun LoginScreenSigningInPreview() {
    LoginContent(
        isSigningIn = true,
        statusMessage = "Starting Google Sign-In...",
        onSignInWithGoogle = {},
        onSignInWithApple = {},
    )
}
