package com.variance.nearby.services.zk

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.variance.nearby.core.AppConstants
import com.variance.nearby.hsm.HardwareSecurityModule
import com.variance.nearby.leansui.SignatureScheme
import com.variance.nearby.leansui.ZkLoginAuthenticator
import com.variance.nearby.leansui.api.GraphQLSuiProvider
import com.variance.nearby.leansui.api.SuiNetwork
import com.variance.nearby.leansui.api.SuiNetworkKind
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.future.await
import kotlinx.coroutines.withContext
import org.swift.swiftkit.core.SwiftArena

/**
 * Service coordinator managing hardware-backed ephemeral credentials and nonces for zkLogin on Android.
 *
 * `ZkLoginService` interacts with local hardware security (StrongBox HSM) and remote
 * GraphQL providers to prepare cryptographic parameters required for zkLogin authentication.
 *
 * @param swiftArena Confined JNI memory arena.
 */
class ZkLoginService(
    private val swiftArena: SwiftArena,
    private val hsm: HardwareSecurityModule,
) {
    private val zkAuth: ZkLoginAuthenticator = ZkLoginAuthenticator.init(
        GraphQLSuiProvider.init(suiNetwork(), swiftArena),
        hsm,
        swiftArena,
    )

    /** The active zkLogin ephemeral credential containing signing key material and nonce values. */
    var pendingZKEphemeral by mutableStateOf<ZkEphemeral?>(null)
        private set

    private fun suiNetwork(): SuiNetwork = when (AppConstants.SUI_NETWORK) {
        SuiNetworkKind.Discriminator.MAINNET -> SuiNetwork.getMainnet(swiftArena)
        SuiNetworkKind.Discriminator.DEVNET -> SuiNetwork.getDevnet(swiftArena)
        SuiNetworkKind.Discriminator.TESTNET -> SuiNetwork.getTestnet(swiftArena)
    }

    /**
     * Generates a new hardware-backed ephemeral keypair, fetches the current blockchain epoch,
     * and prepares a secure zkLogin nonce bound to the StrongBox public key.
     *
     * Runs asynchronously on Dispatchers.IO for background network/HSM operations.
     *
     * @param hsm Hardware Security Module (StrongBox interface).
     * @return The generated base64URL-encoded zkLogin nonce.
     */
    suspend fun prepareNonce(): String = withContext(Dispatchers.IO) {
        val account = zkAuth.generateEphemeralKeypair(SignatureScheme.secp256r1(swiftArena), swiftArena)
        val epoch = zkAuth.getCurrentEpoch(swiftArena).await()
        val maxEpoch = epoch.epoch + AppConstants.SUI_MAX_EPOCH_BUFFER
        val randomness = zkAuth.generateRandomness()
        val nonce = zkAuth.generateZkNonce(account, maxEpoch, randomness)

        val session = ZkEphemeral(account, maxEpoch, randomness, nonce)
        pendingZKEphemeral = session
        nonce
    }

    /** Clears any active pending zkLogin ephemeral session. */
    fun clearPending() {
        pendingZKEphemeral = null
    }
}
