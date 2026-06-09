package com.variance.nearby.screens.home

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil3.compose.AsyncImage
import com.variance.nearby.R
import com.variance.nearby.core.AppRoute
import com.variance.nearby.core.AppViewModel
import com.variance.nearby.ui.Card
import com.variance.nearby.ui.MutedText
import com.variance.nearby.ui.Title
import kotlinx.coroutines.future.await

@Composable
fun HomeScreen(
    viewModel: AppViewModel,
    modifier: Modifier = Modifier,
) {
    var displayName by remember { mutableStateOf(viewModel.userName) }
    var avatarUrl by remember { mutableStateOf<String?>(null) }

    // Fetch the profile on appear for the name + avatar URL. The avatar image itself is loaded and
    // disk-cached by Coil from `avatarUrl`; no image blobs are stored locally.
    LaunchedEffect(Unit) {
        try {
            val sessionOpt = viewModel.sessionManager.getCurrentSession(viewModel.swiftArena)
            val addr = if (sessionOpt.isPresent) sessionOpt.get().suiAddress.orElse(null) else null
            if (addr != null) {
                val profile = viewModel.identityManager.fetchProfile(addr, viewModel.swiftArena).await()
                val name = profile.suinsName.orElse("")
                if (name.isNotEmpty()) displayName = name
                avatarUrl = profile.avatarUrl.orElse(null)
            }
        } catch (e: Exception) {
            println("Android HomeScreen failed to load profile: ${e.localizedMessage}")
        }
    }

    HomeContent(
        userName = displayName,
        avatarUrl = avatarUrl,
        onNavigateToProfile = { viewModel.route = AppRoute.PROFILE },
        onSignOut = { viewModel.signOut() },
        modifier = modifier,
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeContent(
    userName: String,
    avatarUrl: String?,
    onNavigateToProfile: () -> Unit,
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
                navigationIcon = {
                    Box(
                        modifier = Modifier
                            .padding(start = 16.dp, end = 8.dp)
                            .size(32.dp)
                            .clip(CircleShape)
                            .border(1.dp, MaterialTheme.colorScheme.outline.copy(alpha = 0.5f), CircleShape)
                            .clickable { onNavigateToProfile() },
                        contentAlignment = Alignment.Center,
                    ) {
                        if (!avatarUrl.isNullOrEmpty()) {
                            AsyncImage(
                                model = avatarUrl,
                                contentDescription = "Profile Photo",
                                modifier = Modifier.fillMaxSize(),
                                contentScale = ContentScale.Crop,
                            )
                        } else {
                            Icon(
                                painter = painterResource(id = R.drawable.account_circle),
                                contentDescription = "Profile",
                                tint = MaterialTheme.colorScheme.onSurfaceVariant,
                                modifier = Modifier.fillMaxSize(),
                            )
                        }
                    }
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
        avatarUrl = null,
        onNavigateToProfile = {},
        onSignOut = {},
    )
}
