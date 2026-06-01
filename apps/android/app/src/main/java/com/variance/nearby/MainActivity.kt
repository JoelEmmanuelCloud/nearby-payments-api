package com.variance.nearby

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.variance.nearby.screens.HomeScreen
import com.variance.nearby.screens.LoginScreen
import com.variance.nearby.screens.OnboardingScreen
import com.variance.nearby.ui.theme.NearbyTheme

class MainActivity : ComponentActivity() {
    private val viewModel by lazy { AppViewModel(applicationContext) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        handleIntent(intent)

        setContent {
            NearbyTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background,
                ) {
                    Nearby(viewModel)
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val uri = intent?.data ?: return
        if (intent.action == Intent.ACTION_VIEW && uri.scheme == "nearby-auth" && uri.host == "callback") {
            val code = uri.getQueryParameter("code")
            val state = uri.getQueryParameter("state")
            if (code != null && state != null) {
                viewModel.handleAppleRedirect(code, state)
            }
        }
    }
}

@Composable
private fun Nearby(viewModel: AppViewModel) {
    when (viewModel.route) {
        AppRoute.ONBOARDING -> OnboardingScreen(viewModel)
        AppRoute.LOGIN -> LoginScreen(viewModel)
        AppRoute.HOME -> HomeScreen(viewModel)
    }
}
