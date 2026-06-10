package com.variance.nearby.screens.profile

import android.content.ClipData
import android.graphics.BitmapFactory
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
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
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.ClipEntry
import androidx.compose.ui.platform.LocalClipboard
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.variance.nearby.R
import com.variance.nearby.ui.Avatar
import com.variance.nearby.ui.Badge
import com.variance.nearby.ui.BadgeTone
import com.variance.nearby.ui.Card
import com.variance.nearby.ui.Input
import com.variance.nearby.ui.MutedText
import com.variance.nearby.ui.UIButton
import com.variance.nearby.ui.theme.Green40
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun ProfileScreen(
    viewModel: ProfileViewModel,
) {
    val context = LocalContext.current
    val clipboard = LocalClipboard.current
    var showEdit by rememberSaveable { mutableStateOf(false) }

    val coroutineScope = rememberCoroutineScope()

    val imagePickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent(),
    ) { uri ->
        uri?.let {
            try {
                val inputStream = context.contentResolver.openInputStream(it)
                val bytes = inputStream?.readBytes()
                inputStream?.close()
                if (bytes != null) {
                    viewModel.uploadAvatar(bytes)
                }
            } catch (e: Exception) {
                println("Failed to read image bytes: ${e.localizedMessage}")
            }
        }
    }

    LaunchedEffect(Unit) { viewModel.loadProfile() }

    // Registration completed → leave the edit screen (main page now shows the Registered badge).
    LaunchedEffect(viewModel.suinsName) {
        if (viewModel.suinsName != null) showEdit = false
    }

    if (showEdit) {
        BackHandler { showEdit = false }
        ProfileEditContent(
            nameInput = viewModel.nameInput,
            statusMessage = viewModel.statusMessage,
            isAvailable = viewModel.isAvailable,
            isSaving = viewModel.isSaving,
            onNameChange = viewModel::onNameInputChange,
            onRegister = viewModel::registerProfileName,
            onBack = { showEdit = false },
        )
    } else {
        ProfileMainContent(
            isLoading = viewModel.isLoading,
            isRegistered = viewModel.isRegistered,
            displayName = viewModel.displayName,
            suiAddress = viewModel.suiAddress,
            avatarUrl = viewModel.avatarUrl,
            pickedAvatarData = viewModel.pickedAvatarData,
            isSaving = viewModel.isSaving,
            onAvatarClick = { imagePickerLauncher.launch("image/*") },
            onSetUp = {
                viewModel.resetNameEntry()
                showEdit = true
            },
            onCopyAddress = {
                viewModel.suiAddress?.let { addr ->
                    coroutineScope.launch {
                        val clipEntry = ClipEntry(ClipData.newPlainText("Copied Sui Address", addr))
                        clipboard.setClipEntry(clipEntry)
                    }
                }
            },
            onFinish = viewModel.onFinish,
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileMainContent(
    isLoading: Boolean,
    isRegistered: Boolean,
    displayName: String,
    suiAddress: String?,
    avatarUrl: String?,
    pickedAvatarData: ByteArray?,
    isSaving: Boolean,
    onAvatarClick: () -> Unit,
    onSetUp: () -> Unit,
    onCopyAddress: () -> Unit,
    onFinish: () -> Unit,
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Profile",
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onFinish) {
                        Icon(
                            painter = painterResource(id = R.drawable.arrow_back),
                            contentDescription = "Back",
                        )
                    }
                },
            )
        },
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            ProfileAvatar(
                pickedAvatarData = pickedAvatarData,
                avatarUrl = avatarUrl,
                enabled = !isSaving,
                onClick = onAvatarClick,
            )
            MutedText(value = if (isRegistered) "Tap photo to update" else "Choose a profile photo")

            // Nearby Identity: headline + name + resolving badge (mirrors iOS)
            Card(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Nearby Identity",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurface,
                )
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(
                        painter = painterResource(
                            id = if (isRegistered) R.drawable.checkmark_seal else R.drawable.at,
                        ),
                        contentDescription = null,
                        tint = if (isRegistered) {
                            Color(0xFF1B873F)
                        } else {
                            MaterialTheme.colorScheme.onSurfaceVariant
                        },
                        modifier = Modifier.size(20.dp),
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = displayName,
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Medium,
                        color = if (isRegistered) {
                            MaterialTheme.colorScheme.onSurface
                        } else {
                            MaterialTheme.colorScheme.onSurfaceVariant
                        },
                        modifier = Modifier.weight(5f, fill = false),
                    )
                    Spacer(modifier = Modifier.weight(1f))
                    ProfileBadge(isLoading = isLoading, isRegistered = isRegistered, onSetUp = onSetUp)
                }
            }

            // Wallet address — tap the card to copy
            var copied by remember { mutableStateOf(false) }
            LaunchedEffect(copied) {
                if (copied) {
                    delay(2000)
                    copied = false
                }
            }
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(enabled = suiAddress != null) {
                        onCopyAddress()
                        copied = true
                    },
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        text = "Sui Wallet Address",
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    )
                    Spacer(modifier = Modifier.weight(1f))
                    if (suiAddress != null) {
                        Text(
                            text = if (copied) "copied" else "tap to copy",
                            style = MaterialTheme.typography.bodySmall,
                            color = if (copied) Green40 else MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
                Text(
                    text = suiAddress ?: "Deriving Sui zkLogin address...",
                    style = MaterialTheme.typography.bodySmall.copy(fontFamily = FontFamily.Monospace),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}

@Composable
private fun ProfileBadge(
    isLoading: Boolean,
    isRegistered: Boolean,
    onSetUp: () -> Unit,
) {
    when {
        isLoading -> CircularProgressIndicator(
            modifier = Modifier.size(20.dp),
            strokeWidth = 2.dp,
        )
        isRegistered -> Badge(text = "Registered", tone = BadgeTone.SUCCESS)
        else -> Button(onClick = onSetUp, shape = RoundedCornerShape(8.dp)) {
            Text(text = "Set up name")
        }
    }
}

@Composable
private fun ProfileAvatar(
    pickedAvatarData: ByteArray?,
    avatarUrl: String?,
    enabled: Boolean,
    onClick: () -> Unit,
) {
    Avatar(
        size = 100.dp,
        modifier = Modifier.clickable(enabled = enabled, onClick = onClick),
    ) {
        when {
            pickedAvatarData != null -> {
                val bitmap = remember(pickedAvatarData) {
                    BitmapFactory.decodeByteArray(pickedAvatarData, 0, pickedAvatarData.size)
                }
                if (bitmap != null) {
                    Image(
                        bitmap = bitmap.asImageBitmap(),
                        contentDescription = "Avatar Photo",
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop,
                    )
                }
            }
            !avatarUrl.isNullOrEmpty() -> AsyncImage(
                model = avatarUrl,
                contentDescription = "Avatar Photo",
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Crop,
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileEditContent(
    nameInput: String,
    statusMessage: String?,
    isAvailable: Boolean,
    isSaving: Boolean,
    onNameChange: (String) -> Unit,
    onRegister: () -> Unit,
    onBack: () -> Unit,
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Choose your name",
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            painter = painterResource(id = R.drawable.arrow_back),
                            contentDescription = "Back",
                        )
                    }
                },
            )
        },
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            MutedText(
                value = "Choose your unique Nearby handle. This registers an on-chain sub-domain under nearby.sui and cannot be changed.",
            )

            Row(verticalAlignment = Alignment.CenterVertically) {
                Input(
                    value = nameInput,
                    onValueChange = onNameChange,
                    placeholder = "username",
                    modifier = Modifier.weight(1f),
                    enabled = !isSaving,
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = ".nearby.sui",
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            statusMessage?.let { status ->
                Text(
                    text = status,
                    style = MaterialTheme.typography.bodySmall,
                    color = if (isAvailable) {
                        MaterialTheme.colorScheme.primary
                    } else {
                        MaterialTheme.colorScheme.onSurfaceVariant
                    },
                )
            }

            Spacer(modifier = Modifier.height(8.dp))
            UIButton(
                title = if (isSaving) "Registering…" else "Register",
                modifier = Modifier.fillMaxWidth(),
                isDisabled = !isAvailable || isSaving || nameInput.isEmpty(),
                onClick = onRegister,
            )
        }
    }
}

@Preview(showBackground = true, name = "Profile · registered")
@Composable
private fun ProfileMainRegisteredPreview() {
    ProfileMainContent(
        isLoading = false,
        isRegistered = true,
        displayName = "alice.nearby.sui",
        suiAddress = "0x1234abcd5678ef901234abcd5678ef90",
        avatarUrl = null,
        pickedAvatarData = null,
        isSaving = false,
        onAvatarClick = {},
        onSetUp = {},
        onCopyAddress = {},
        onFinish = {},
    )
}

@Preview(showBackground = true, name = "Profile edit")
@Composable
private fun ProfileEditPreview() {
    ProfileEditContent(
        nameInput = "alice",
        statusMessage = "Name is available!",
        isAvailable = true,
        isSaving = false,
        onNameChange = {},
        onRegister = {},
        onBack = {},
    )
}
