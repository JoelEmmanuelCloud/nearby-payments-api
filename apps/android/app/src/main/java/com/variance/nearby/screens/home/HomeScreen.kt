package com.variance.nearby.screens.home

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
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
import com.variance.nearby.ui.Avatar
import com.variance.nearby.ui.Card
import com.variance.nearby.ui.MutedText
import com.variance.nearby.ui.Skeleton
import com.variance.nearby.ui.Title
import kotlinx.coroutines.future.await

@Composable
fun HomeScreen(
    viewModel: AppViewModel,
    homeViewModel: HomeViewModel,
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

    // Silent 30s balance polling, scoped to Home being on screen.
    DisposableEffect(homeViewModel) {
        homeViewModel.start()
        onDispose { homeViewModel.stop() }
    }

    HomeContent(
        userName = displayName,
        avatarUrl = avatarUrl,
        isBalanceLoading = homeViewModel.balance is HomeViewModel.BalanceState.Loading,
        isBalanceHidden = homeViewModel.isHidden,
        balanceText = homeViewModel.formattedBalance,
        onToggleBalance = { homeViewModel.toggleVisibility() },
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
    isBalanceLoading: Boolean,
    isBalanceHidden: Boolean,
    balanceText: String,
    onToggleBalance: () -> Unit,
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
                    Avatar(
                        size = 32.dp,
                        modifier = Modifier
                            .padding(start = 16.dp, end = 8.dp)
                            .clickable { onNavigateToProfile() },
                    ) {
                        if (!avatarUrl.isNullOrEmpty()) {
                            AsyncImage(
                                model = avatarUrl,
                                contentDescription = "Profile Photo",
                                modifier = Modifier.fillMaxSize(),
                                contentScale = ContentScale.Crop,
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

            // Account balance card
            Card {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        text = "Account balance",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface,
                    )
                    Spacer(modifier = Modifier.weight(1f))
                    IconButton(onClick = onToggleBalance) {
                        Icon(
                            painter = painterResource(id = R.drawable.visibility),
                            contentDescription = if (isBalanceHidden) "Show balance" else "Hide balance",
                            tint = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    Image(
                        painter = painterResource(id = R.drawable.sui_droplet_blue),
                        contentDescription = null,
                        modifier = Modifier.size(28.dp),
                    )
                    when {
                        isBalanceHidden -> Text(
                            text = "••••",
                            style = MaterialTheme.typography.headlineSmall,
                            fontWeight = FontWeight.SemiBold,
                        )
                        isBalanceLoading -> Skeleton(
                            modifier = Modifier
                                .width(120.dp)
                                .height(26.dp),
                        )
                        else -> Row(verticalAlignment = Alignment.Bottom) {
                            Text(
                                text = balanceText,
                                style = MaterialTheme.typography.headlineSmall,
                                fontWeight = FontWeight.SemiBold,
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = "USDsui",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                    }
                }
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

@Preview(showBackground = true, name = "Home · loading")
@Composable
private fun HomeLoadingPreview() {
    HomeContent(
        userName = "Alice",
        avatarUrl = null,
        isBalanceLoading = true,
        isBalanceHidden = false,
        balanceText = "",
        onToggleBalance = {},
        onNavigateToProfile = {},
        onSignOut = {},
    )
}

@Preview(showBackground = true, name = "Home · balance")
@Composable
private fun HomeBalancePreview() {
    HomeContent(
        userName = "Alice",
        avatarUrl = null,
        isBalanceLoading = false,
        isBalanceHidden = false,
        balanceText = "42.50",
        onToggleBalance = {},
        onNavigateToProfile = {},
        onSignOut = {},
    )
}
