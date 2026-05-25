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
import com.variance.nearby.hello.HelloAndroid
import com.variance.nearby.hello.HelloGateway
import com.variance.nearby.ui.theme.NearbyTheme
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

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

class MyJavaObject {
    fun performAction() {
        // do nothing
    }
}

class DirectPayloadProvider {
    fun echoText(value: String): String = value

    fun echoBytes(value: ByteArray): ByteArray = value

    fun echoData(value: ByteArray): ByteArray = value
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
                    scope.launch(Dispatchers.IO) {
                        try {
                            val provider = HelloAndroid()
                            val test = HelloGateway.init(
                                provider,
                                org.swift.swiftkit.core.SwiftMemoryManagement.DEFAULT_SWIFT_JAVA_AUTO_ARENA,
                            )

                            message = test.runRoundTrip("Nearby")
                        } catch (e: Exception) {
                            message = "Error: ${e.message}"
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
