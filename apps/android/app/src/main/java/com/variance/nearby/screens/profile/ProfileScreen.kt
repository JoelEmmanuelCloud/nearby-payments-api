package com.variance.nearby.screens.profile

import android.graphics.BitmapFactory
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil3.compose.AsyncImage
import com.variance.nearby.R

@Composable
fun ProfileScreen(
    viewModel: ProfileViewModel,
) {
    val context = LocalContext.current
    var showEdit by rememberSaveable { mutableStateOf(false) }

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
            isSetupMode = viewModel.isSetupMode,
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
            onFinish = viewModel.onFinish,
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileMainContent(
    isSetupMode: Boolean,
    isLoading: Boolean,
    isRegistered: Boolean,
    displayName: String,
    suiAddress: String?,
    avatarUrl: String?,
    pickedAvatarData: ByteArray?,
    isSaving: Boolean,
    onAvatarClick: () -> Unit,
    onSetUp: () -> Unit,
    onFinish: () -> Unit,
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = if (isSetupMode) "Set up profile" else "Profile",
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    )
                },
                navigationIcon = {
                    if (!isSetupMode) {
                        IconButton(onClick = onFinish) {
                            Icon(
                                painter = painterResource(id = R.drawable.arrow_back),
                                contentDescription = "Back",
                            )
                        }
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
        ) {
            ProfileAvatar(
                pickedAvatarData = pickedAvatarData,
                avatarUrl = avatarUrl,
                monogram = displayName.take(1).uppercase(),
                enabled = !isSaving,
                onClick = onAvatarClick,
            )

            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Tap photo to update",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )

            Spacer(modifier = Modifier.height(24.dp))

            // Identity: name + resolving badge
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f),
                ),
                shape = RoundedCornerShape(16.dp),
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        text = displayName,
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Medium),
                        color = if (isRegistered) {
                            MaterialTheme.colorScheme.onSurface
                        } else {
                            MaterialTheme.colorScheme.onSurfaceVariant
                        },
                    )
                    Spacer(modifier = Modifier.weight(1f))
                    ProfileBadge(isLoading = isLoading, isRegistered = isRegistered, onSetUp = onSetUp)
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Wallet address
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f),
                ),
                shape = RoundedCornerShape(16.dp),
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        text = "Sui Wallet Address",
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = suiAddress ?: "Deriving Sui zkLogin address...",
                        style = MaterialTheme.typography.bodySmall.copy(fontFamily = FontFamily.Monospace),
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }

            if (isSetupMode) {
                Spacer(modifier = Modifier.height(24.dp))
                OutlinedButton(
                    onClick = onFinish,
                    modifier = Modifier.fillMaxWidth(),
                    enabled = !isSaving,
                ) {
                    Text(text = "Skip for Now")
                }
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
        isRegistered -> Box(
            modifier = Modifier
                .clip(RoundedCornerShape(8.dp))
                .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
                .padding(horizontal = 10.dp, vertical = 5.dp),
        ) {
            Text(
                text = "Registered",
                style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Bold),
                color = MaterialTheme.colorScheme.primary,
            )
        }
        else -> Button(onClick = onSetUp) {
            Text(text = "Set up name")
        }
    }
}

@Composable
private fun ProfileAvatar(
    pickedAvatarData: ByteArray?,
    avatarUrl: String?,
    monogram: String,
    enabled: Boolean,
    onClick: () -> Unit,
) {
    Box(
        modifier = Modifier
            .size(100.dp)
            .clip(CircleShape)
            .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.1f))
            .border(1.dp, MaterialTheme.colorScheme.outline, CircleShape)
            .clickable(enabled = enabled) { onClick() },
        contentAlignment = Alignment.Center,
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
            else -> Text(
                text = monogram,
                fontSize = 36.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary,
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
            Text(
                text = "Choose your unique Nearby handle. This registers an on-chain sub-domain under nearby.sui and cannot be changed.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )

            Row(verticalAlignment = Alignment.CenterVertically) {
                OutlinedTextField(
                    value = nameInput,
                    onValueChange = onNameChange,
                    label = { Text("username") },
                    modifier = Modifier.weight(1f),
                    singleLine = true,
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
                        MaterialTheme.colorScheme.error
                    },
                )
            }

            Button(
                onClick = onRegister,
                modifier = Modifier.fillMaxWidth(),
                enabled = isAvailable && !isSaving && nameInput.isNotEmpty(),
            ) {
                Text(text = if (isSaving) "Registering…" else "Register")
            }
        }
    }
}

@Preview(showBackground = true, name = "Profile · loading")
@Composable
private fun ProfileMainLoadingPreview() {
    ProfileMainContent(
        isSetupMode = false,
        isLoading = true,
        isRegistered = false,
        displayName = "yourname.nearby.sui",
        suiAddress = "0x1234abcd5678ef901234abcd5678ef90",
        avatarUrl = null,
        pickedAvatarData = null,
        isSaving = false,
        onAvatarClick = {},
        onSetUp = {},
        onFinish = {},
    )
}

@Preview(showBackground = true, name = "Profile · registered")
@Composable
private fun ProfileMainRegisteredPreview() {
    ProfileMainContent(
        isSetupMode = false,
        isLoading = false,
        isRegistered = true,
        displayName = "alice.nearby.sui",
        suiAddress = "0x1234abcd5678ef901234abcd5678ef90",
        avatarUrl = null,
        pickedAvatarData = null,
        isSaving = false,
        onAvatarClick = {},
        onSetUp = {},
        onFinish = {},
    )
}

@Preview(showBackground = true, name = "Profile · setup (set up name)")
@Composable
private fun ProfileMainSetupPreview() {
    ProfileMainContent(
        isSetupMode = true,
        isLoading = false,
        isRegistered = false,
        displayName = "yourname.nearby.sui",
        suiAddress = "0x1234abcd5678ef901234abcd5678ef90",
        avatarUrl = null,
        pickedAvatarData = null,
        isSaving = false,
        onAvatarClick = {},
        onSetUp = {},
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
