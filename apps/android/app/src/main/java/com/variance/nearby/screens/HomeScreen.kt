package com.variance.nearby.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.variance.nearby.AppViewModel
import com.variance.nearby.ui.Card
import com.variance.nearby.ui.MutedText
import com.variance.nearby.ui.Title

@Composable
fun HomeScreen(
    viewModel: AppViewModel,
    modifier: Modifier = Modifier,
) {
    HomeContent(
        userName = viewModel.userName,
        onSignOut = { viewModel.signOut() },
        modifier = modifier,
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeContent(
    userName: String,
    onSignOut: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Nearby",
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 20.sp,
                    )
                },
                actions = {
                    TextButton(onClick = onSignOut) {
                        Text(
                            text = "Sign out",
                            color = MaterialTheme.colorScheme.primary,
                            fontWeight = FontWeight.Medium,
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.background,
                ),
            )
        },
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(24.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp),
        ) {
            // Title & User Info
            Column(
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Title(value = "Home")
                MutedText(value = "Signed in as $userName.")
            }

            // Account Status Card
            Card {
                Text(
                    text = "Account status",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface,
                )
                MutedText(
                    value = "Your session is ready. Wallet and zkLogin actions will appear here as the Sui package is wired in.",
                )
            }

            // Next Action Card
            Card {
                Text(
                    text = "Next action",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface,
                )
                MutedText(
                    value = "Connect the lean Sui signer and transaction flow after authentication is stable on both platforms.",
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun HomeScreenPreview() {
    HomeContent(
        userName = "Alice",
        onSignOut = {},
    )
}
