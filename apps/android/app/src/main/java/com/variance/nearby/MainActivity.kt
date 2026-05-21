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
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.variance.nearby.ui.theme.NearbyTheme
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.unit.dp
import com.variance.nearby.hello.SwiftHello

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

        Surface {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(message)

                Button(
                    onClick = {
                        message = SwiftHello.Greeting_message()
                    },
                    modifier = Modifier.padding(top = 16.dp)
                ) {
                    Text("Say Hello")
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
