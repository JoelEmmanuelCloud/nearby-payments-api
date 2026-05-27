package com.variance.nearby

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.variance.nearby.gateway.APIGateway
import com.variance.nearby.ui.theme.NearbyTheme
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.swift.swiftkit.core.SwiftArena

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            NearbyTheme {
                Nearby()
            }
        }
    }
}

@Composable
private fun Nearby() {
    var message by remember { mutableStateOf("Tap the button") }
    val scope = rememberCoroutineScope()

    Surface {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(message)

            Button(
                onClick = {
                    message = "Loading..."
                    scope.launch {
                        try {
                            message = withContext(Dispatchers.IO) {
                                SwiftArena.ofConfined().use { arena ->
                                    val gateway = APIGateway.init(
                                        "http://localhost:8080",
                                        "v1",
                                        arena,
                                    )
                                    gateway.serverPublicKey(arena).get().publicKey
                                }
                            }
                        } catch (_: Throwable) {
                            message = "server unavailable"
                        }
                    }
                },
                modifier = Modifier.padding(top = 16.dp),
            ) {
                Text("Test Typed Interface")
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun NearbyPreview() {
    NearbyTheme {
        Nearby()
    }
}
