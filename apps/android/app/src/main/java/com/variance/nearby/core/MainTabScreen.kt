package com.variance.nearby.core

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.variance.nearby.R
import com.variance.nearby.screens.activity.ActivityScreen
import com.variance.nearby.screens.activity.ActivityViewModel
import com.variance.nearby.screens.home.HomeScreen
import com.variance.nearby.screens.home.HomeViewModel
import com.variance.nearby.screens.profile.ProfileScreen
import com.variance.nearby.screens.profile.ProfileViewModel
import com.variance.nearby.services.sui.ActivityService
import com.variance.nearby.services.sui.BalanceService
import com.variance.nearby.services.sui.ConsolidateService

enum class Tab {
    HOME,
    ACTIVITY,
    PROFILE,
}

@Composable
fun MainTabScreen(
    viewModel: AppViewModel,
    modifier: Modifier = Modifier,
) {
    var selectedTab by remember { mutableStateOf(Tab.HOME) }

    val homeViewModel = remember(viewModel) {
        HomeViewModel(
            balanceService = BalanceService(viewModel.suiNetwork, viewModel.swiftArena),
            suiAddress = viewModel.currentSuiAddress,
            store = viewModel.sessionStore,
            consolidateService = ConsolidateService(
                network = viewModel.suiNetwork,
                swiftArena = viewModel.swiftArena,
                signerProvider = { viewModel.reauthenticatedSigner() },
            ),
            toastController = viewModel.toastController,
        )
    }

    val profileViewModel = remember(viewModel) {
        ProfileViewModel(
            identityManager = viewModel.identityManager,
            store = viewModel.sessionStore,
            toastController = viewModel.toastController,
            currentSuiAddress = viewModel.currentSuiAddress,
            userId = viewModel.currentUserId,
            swiftArena = viewModel.swiftArena,
        )
    }

    val activityViewModel = remember(viewModel) {
        ActivityViewModel(
            service = ActivityService(viewModel.suiNetwork, viewModel.swiftArena),
            address = viewModel.currentSuiAddress,
            store = viewModel.sessionStore,
            toastController = viewModel.toastController,
        )
    }

    Scaffold(
        modifier = modifier.fillMaxSize(),
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    selected = selectedTab == Tab.HOME,
                    onClick = { selectedTab = Tab.HOME },
                    icon = { Icon(painterResource(id = R.drawable.home), contentDescription = "Space") },
                    label = { Text("Space") },
                )
                NavigationBarItem(
                    selected = selectedTab == Tab.ACTIVITY,
                    onClick = { selectedTab = Tab.ACTIVITY },
                    icon = { Icon(painterResource(id = R.drawable.receipt), contentDescription = "Activity") },
                    label = { Text("Activity") },
                )
                NavigationBarItem(
                    selected = selectedTab == Tab.PROFILE,
                    onClick = { selectedTab = Tab.PROFILE },
                    icon = {
                        val avatarUrl = profileViewModel.avatarUrl
                        if (!avatarUrl.isNullOrEmpty()) {
                            AsyncImage(
                                model = avatarUrl,
                                contentDescription = "Profile",
                                modifier = Modifier
                                    .size(24.dp)
                                    .clip(CircleShape),
                                contentScale = ContentScale.Crop,
                            )
                        } else {
                            Icon(
                                painter = painterResource(id = R.drawable.person),
                                contentDescription = "Profile",
                            )
                        }
                    },
                    label = { Text("You") },
                )
            }
        },
    ) { innerPadding ->
        Box(modifier = Modifier.padding(innerPadding)) {
            when (selectedTab) {
                Tab.HOME -> HomeScreen(viewModel = viewModel, homeViewModel = homeViewModel)
                Tab.ACTIVITY -> ActivityScreen(
                    viewModel = activityViewModel,
                    currentAddress = viewModel.currentSuiAddress,
                )
                Tab.PROFILE -> ProfileScreen(viewModel = profileViewModel)
            }
        }
    }
}
