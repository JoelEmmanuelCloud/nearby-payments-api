package com.variance.nearby.screens.home

import androidx.activity.compose.BackHandler
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
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
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.variance.nearby.R
import com.variance.nearby.core.AppViewModel
import com.variance.nearby.screens.auth.AppleLogo
import com.variance.nearby.screens.auth.GoogleLogo
import com.variance.nearby.screens.deposit.DepositScreen
import com.variance.nearby.screens.send.SendFlow
import com.variance.nearby.ui.Card
import com.variance.nearby.ui.MutedText
import com.variance.nearby.ui.SecondaryButton
import com.variance.nearby.ui.Skeleton
import com.variance.nearby.ui.UIButton
import kotlinx.coroutines.future.await

@Composable
fun HomeScreen(
    viewModel: AppViewModel,
    homeViewModel: HomeViewModel,
    modifier: Modifier = Modifier,
) {
    var displayName by remember { mutableStateOf(viewModel.userName) }

    // Fetch the profile on appear for the name.
    LaunchedEffect(Unit) {
        try {
            val sessionOpt = viewModel.sessionManager.getCurrentSession(viewModel.swiftArena)
            val addr = if (sessionOpt.isPresent) sessionOpt.get().suiAddress.orElse(null) else null
            if (addr != null) {
                val profile = viewModel.identityManager.fetchProfile(addr, viewModel.swiftArena).await()
                val name = profile.suinsName.orElse("")
                if (name.isNotEmpty()) displayName = name
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

    // Local sub-route off Home (mirrors ProfileScreen's edit-screen pattern). `send` is a stub until
    // roadmap #6.
    var route by rememberSaveable { mutableStateOf<HomeRoute?>(null) }

    when (route) {
        HomeRoute.DEPOSIT -> {
            BackHandler { route = null }
            DepositScreen(onBack = { route = null }, modifier = modifier)
        }
        HomeRoute.SEND -> SendFlow(
            viewModel = viewModel,
            onExit = { route = null },
            modifier = modifier,
        )
        null -> HomeContent(
            userName = displayName,
            currentProvider = viewModel.currentProvider,
            isBalanceLoading = homeViewModel.balance is HomeViewModel.BalanceState.Loading,
            isBalanceHidden = homeViewModel.isHidden,
            balanceText = homeViewModel.formattedBalance,
            hasPendingBalance = homeViewModel.hasPendingBalance,
            pendingBalanceText = homeViewModel.formattedPendingBalance,
            isConsolidating = homeViewModel.isConsolidating,
            canConsolidate = homeViewModel.canConsolidate,
            onConsolidate = { homeViewModel.consolidate() },
            onToggleBalance = { homeViewModel.toggleVisibility() },
            onSignOut = { viewModel.signOut() },
            onDeposit = { route = HomeRoute.DEPOSIT },
            onSend = { route = HomeRoute.SEND },
            modifier = modifier,
        )
    }
}

private enum class HomeRoute {
    DEPOSIT,
    SEND,
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeContent(
    userName: String,
    currentProvider: String?,
    isBalanceLoading: Boolean,
    isBalanceHidden: Boolean,
    balanceText: String,
    hasPendingBalance: Boolean,
    pendingBalanceText: String,
    isConsolidating: Boolean,
    canConsolidate: Boolean,
    onConsolidate: () -> Unit,
    onToggleBalance: () -> Unit,
    onSignOut: () -> Unit,
    onDeposit: () -> Unit,
    onSend: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Home",
                        fontWeight = FontWeight.Bold,
                        fontSize = 20.sp,
                    )
                },
                navigationIcon = {
                    ProviderIcon(currentProvider = currentProvider)
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
            // User Info
            MutedText(value = "Signed in as $userName.")

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

                // Pending (coin-object) balance: a thin call-to-action shown only when there's value
                // to move into the spendable address balance. Tapping runs the gasless consolidation.
                if (!isBalanceHidden && hasPendingBalance) {
                    Spacer(modifier = Modifier.height(12.dp))
                    PendingBalanceStrip(
                        pendingText = pendingBalanceText,
                        isConsolidating = isConsolidating,
                        enabled = canConsolidate,
                        onConsolidate = onConsolidate,
                    )
                }
            }

            // Primary actions
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                UIButton(
                    title = "Deposit",
                    modifier = Modifier.weight(1f),
                    onClick = onDeposit,
                )
                SecondaryButton(
                    title = "Send",
                    modifier = Modifier.weight(1f),
                    onClick = onSend,
                )
            }
        }
    }
}

/**
 * The thin "pending balance" call to action at the bottom of the balance card. Surfaces value held as
 * coin objects and moves it into the spendable address balance with one gasless transaction.
 */
@Composable
private fun PendingBalanceStrip(
    pendingText: String,
    isConsolidating: Boolean,
    enabled: Boolean,
    onConsolidate: () -> Unit,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(10.dp))
            .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.12f))
            .clickable(enabled = enabled, onClick = onConsolidate)
            .padding(horizontal = 12.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        if (isConsolidating) {
            CircularProgressIndicator(modifier = Modifier.size(16.dp), strokeWidth = 2.dp)
            Text(
                text = "Moving to balance…",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        } else {
            Text(
                text = "$pendingText USDsui pending",
                style = MaterialTheme.typography.bodySmall,
            )
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = "Move to balance",
                style = MaterialTheme.typography.bodySmall,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.primary,
            )
        }
    }
}

@Composable
fun ProviderIcon(
    currentProvider: String?,
    modifier: Modifier = Modifier,
) {
    val iconModifier = modifier
        .padding(start = 16.dp, end = 8.dp)
        .size(20.dp)

    when (currentProvider) {
        "google" -> {
            Icon(
                imageVector = GoogleLogo,
                contentDescription = "Google Logo",
                tint = Color.Unspecified,
                modifier = iconModifier,
            )
        }
        "apple" -> {
            Icon(
                imageVector = AppleLogo,
                contentDescription = "Apple Logo",
                tint = MaterialTheme.colorScheme.onSurface,
                modifier = iconModifier,
            )
        }
        else -> {
            Icon(
                painter = painterResource(id = R.drawable.checkmark_seal),
                contentDescription = "Verified Seal",
                tint = MaterialTheme.colorScheme.primary,
                modifier = iconModifier,
            )
        }
    }
}

@Preview(showBackground = true, name = "Home · loading")
@Composable
private fun HomeLoadingPreview() {
    HomeContent(
        userName = "Alice",
        currentProvider = "google",
        isBalanceLoading = true,
        isBalanceHidden = false,
        balanceText = "",
        hasPendingBalance = false,
        pendingBalanceText = "0.00",
        isConsolidating = false,
        canConsolidate = false,
        onConsolidate = {},
        onToggleBalance = {},
        onSignOut = {},
        onDeposit = {},
        onSend = {},
    )
}

@Preview(showBackground = true, name = "Home · balance")
@Composable
private fun HomeBalancePreview() {
    HomeContent(
        userName = "Alice",
        currentProvider = "apple",
        isBalanceLoading = false,
        isBalanceHidden = false,
        balanceText = "42.50",
        hasPendingBalance = true,
        pendingBalanceText = "20.00",
        isConsolidating = false,
        canConsolidate = true,
        onConsolidate = {},
        onToggleBalance = {},
        onSignOut = {},
        onDeposit = {},
        onSend = {},
    )
}
