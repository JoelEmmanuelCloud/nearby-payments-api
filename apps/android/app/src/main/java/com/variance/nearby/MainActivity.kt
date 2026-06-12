package com.variance.nearby

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import coil3.ImageLoader
import coil3.SingletonImageLoader
import coil3.network.okhttp.OkHttpNetworkFetcherFactory
import com.variance.nearby.biometrics.BiometricGateHost
import com.variance.nearby.core.AppRoute
import com.variance.nearby.core.AppViewModel
import com.variance.nearby.core.MainTabScreen
import com.variance.nearby.screens.auth.LoginScreen
import com.variance.nearby.screens.auth.LoginViewModel
import com.variance.nearby.screens.onboarding.OnboardingScreen
import com.variance.nearby.screens.profile.WalrusInterceptor
import com.variance.nearby.screens.security.DeviceSecurityScreen
import com.variance.nearby.ui.ToastHost
import com.variance.nearby.ui.theme.NearbyTheme
import okhttp3.OkHttpClient

class MainActivity : ComponentActivity() {
    private val viewModel by lazy { AppViewModel(applicationContext) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        handleIntent(intent)

        // Coil's singleton ImageLoader, fronted by one shared OkHttp client carrying WalrusInterceptor
        // (which makes the Walrus aggregator's UA-gated, content-type-less, race-404'd blobs load).
        // setSafe is a no-op once the loader exists, so it must run before any AsyncImage; onCreate
        // (pre-setContent) is the first entry point.
        SingletonImageLoader.setSafe { context ->
            val okHttpClient = OkHttpClient.Builder()
                .addInterceptor(WalrusInterceptor())
                .build()
            ImageLoader.Builder(context)
                .components {
                    add(OkHttpNetworkFetcherFactory(callFactory = { okHttpClient }))
                }
                .build()
        }

        setContent {
            NearbyTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background,
                ) {
                    // Always mounted so a signing request can present a prompt from any screen.
                    BiometricGateHost(viewModel.biometricGate)
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

    override fun onResume() {
        super.onResume()
        viewModel.refreshDeviceSecurityGate()
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
    val context = androidx.compose.ui.platform.LocalContext.current

    ToastHost(controller = viewModel.toastController) {
        Routes(viewModel, context)
    }
}

@Composable
private fun Routes(viewModel: AppViewModel, context: android.content.Context) {
    when (viewModel.route) {
        AppRoute.LOADING -> {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center,
            ) {
                CircularProgressIndicator()
            }
        }
        AppRoute.ONBOARDING -> OnboardingScreen(
            onFinished = { viewModel.finishOnboarding() },
        )
        AppRoute.DEVICE_SECURITY -> DeviceSecurityScreen()
        AppRoute.LOGIN -> {
            val loginViewModel = remember(viewModel) {
                LoginViewModel(
                    context = context.applicationContext,
                    gateway = viewModel.gateway,
                    sessionManager = viewModel.sessionManager,
                    zkLoginService = viewModel.zkLoginService,
                    toastController = viewModel.toastController,
                    swiftArena = viewModel.swiftArena,
                )
            }
            LoginScreen(
                viewModel = loginViewModel,
                onSignInSuccess = { name -> viewModel.handleSignInSuccess(name) },
            )
        }
        AppRoute.MAIN -> {
            MainTabScreen(viewModel = viewModel)
        }
    }
}
