package com.variance.nearby.services.zk

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.variance.nearby.auth.SessionManager
import com.variance.nearby.core.AppConstants
import com.variance.nearby.hsm.HardwareSecurityModule
import com.variance.nearby.leansui.RemoteZkProofService
import com.variance.nearby.leansui.SignatureScheme
import com.variance.nearby.leansui.SuiGraphQLClient
import com.variance.nearby.leansui.ZkLoginAuthenticator
import com.variance.nearby.leansui.ZkLoginSigner
import com.variance.nearby.leansui.api.GraphQLSuiProvider
import com.variance.nearby.leansui.api.SuiNetwork
import com.variance.nearby.leansui.bcs.SuiData
import com.variance.nearby.leansui.zkLoginSignature
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.future.await
import kotlinx.coroutines.withContext
import org.swift.swiftkit.core.SwiftArena

/**
 * Service coordinator managing the full zkLogin lifecycle on Android: ephemeral credentials and
 * nonces, background proof generation, proof persistence, and just-in-time signer construction.
 *
 * `ZkLoginService` interacts with local hardware security (StrongBox HSM), the remote prover, and
 * the persisted session to keep a usable `ZkLoginSigner` ready without paying the multi-second
 * proving cost in front of a user-initiated signing action.
 *
 * @param swiftArena Confined JNI memory arena.
 * @param hsm Hardware Security Module (StrongBox interface).
 * @param network The Sui network this service targets.
 * @param sessionManager Owns the persisted zkLogin session (jwt/salt/maxEpoch/address/proof).
 * @param scope Coroutine scope (the owning ViewModel's) used to memoize signer construction.
 */
class ZkLoginService(
    private val swiftArena: SwiftArena,
    private val hsm: HardwareSecurityModule,
    private val network: SuiNetwork,
    private val sessionManager: SessionManager,
    private val scope: CoroutineScope,
) {
    private val zkAuth: ZkLoginAuthenticator = ZkLoginAuthenticator.init(
        GraphQLSuiProvider.init(network, swiftArena),
        hsm,
        swiftArena,
    )
    private val proofService: RemoteZkProofService =
        RemoteZkProofService.init(AppConstants.REMOTE_ZK_PROVER, swiftArena)
    private val graphQLClient: SuiGraphQLClient =
        SuiGraphQLClient.init(network.graphQLEndpointString, swiftArena)

    /** The active zkLogin ephemeral credential containing signing key material and nonce values. */
    var pendingZKEphemeral by mutableStateOf<ZkEphemeral?>(null)
        private set

    /** Memoized in-flight signer construction, so warm-up and on-demand callers share one proving run. */
    private var signerJob: Deferred<ZkLoginSigner>? = null

    /**
     * Generates a new hardware-backed ephemeral keypair, fetches the current blockchain epoch,
     * and prepares a secure zkLogin nonce bound to the StrongBox public key.
     *
     * @return The generated base64URL-encoded zkLogin nonce.
     */
    suspend fun prepareNonce(): String = withContext(Dispatchers.IO) {
        // A new login invalidates any previously cached signer/proof.
        signerJob = null

        val account = zkAuth.generateEphemeralKeypair(SignatureScheme.secp256r1(swiftArena), swiftArena)
        val epoch = zkAuth.getCurrentEpoch(swiftArena).await()
        val maxEpoch = epoch.epoch + AppConstants.SUI_MAX_EPOCH_BUFFER
        val randomness = zkAuth.generateRandomness()
        val nonce = zkAuth.generateZkNonce(account, maxEpoch, randomness)

        pendingZKEphemeral = ZkEphemeral(account, maxEpoch, randomness, nonce)
        nonce
    }

    /**
     * Derives the (stable) zkLogin Sui address and persists it together with the current `maxEpoch`.
     *
     * This is the **single writer** of the session's Sui properties: the address is a pure function of
     * `iss/sub/aud/salt` (never changes), while `maxEpoch` is renewed by each (re-)auth. Called by the
     * login flow right after OAuth completes, before binding/warm-up. Identity must not write these.
     */
    suspend fun commitSessionIdentity() = withContext(Dispatchers.IO) {
        val session = sessionManager.getCurrentSession(swiftArena).orElse(null)
            ?: throw IllegalStateException("No active zkLogin session")
        val address = zkAuth.derivezkLoginAddress(session.jwt, session.salt)
        val maxEpoch = pendingZKEphemeral?.maxEpoch ?: session.maxEpoch
        sessionManager.updateSuiProperties(maxEpoch, java.util.Optional.of(address))
    }

    /**
     * Eagerly prepares a usable signer in the background after login, so the expensive proof is ready
     * before the user attempts to sign. Shares the in-flight construction with [signer].
     *
     * Its only session side effect is persisting the generated proof; it does not touch maxEpoch or
     * the Sui address (those are owned by the login flow).
     */
    suspend fun warmUpSigner(): ZkLoginSigner = resolveSigner()

    /**
     * Returns a ready-to-use signer, constructing it just-in-time from the persisted proof (or, if
     * none is cached yet, by generating one). Shares the in-flight warm-up job when present.
     *
     * Throws [SessionUnusableException] when the session can no longer sign (expired `maxEpoch` /
     * missing StrongBox key) so the caller routes a just-in-time re-authentication instead of
     * submitting a signature the network will reject.
     */
    suspend fun signer(): ZkLoginSigner {
        if (!isSessionUsable()) throw SessionUnusableException()
        return resolveSigner()
    }

    /**
     * Whether the persisted session can currently produce a valid signature: its `maxEpoch` is still
     * ahead of the chain's current epoch and the StrongBox key is present. A fresh login (with a
     * `pendingZKEphemeral` in memory) is also usable even before its proof is persisted.
     */
    suspend fun isSessionUsable(): Boolean = withContext(Dispatchers.IO) {
        if (pendingZKEphemeral != null) return@withContext true
        if (AppConstants.DEBUG_FORCE_SESSION_EXPIRED) return@withContext false
        val epoch = zkAuth.getCurrentEpoch(swiftArena).await().epoch
        sessionManager.isZkLoginSessionUsable(epoch)
    }

    /** Clears any active pending zkLogin ephemeral session and cached signer. */
    fun clearPending() {
        pendingZKEphemeral = null
        signerJob = null
    }

    /** Returns the memoized signer job's value, resetting the cache on failure so callers can retry. */
    private suspend fun resolveSigner(): ZkLoginSigner {
        val job = signerJob ?: scope.async(Dispatchers.IO) { constructSigner() }.also { signerJob = it }
        return try {
            job.await()
        } catch (e: Exception) {
            signerJob = null
            throw e
        }
    }

    /**
     * Assembles a [ZkLoginSigner] from the persisted session: reuses the cached proof when present,
     * otherwise generates one from the in-memory ephemeral and persists it.
     */
    private suspend fun constructSigner(): ZkLoginSigner {
        val session = sessionManager.getCurrentSession(swiftArena).orElse(null)
            ?: throw IllegalStateException("No active zkLogin session")
        val userAddress = session.suiAddress.orElse(null)
            ?: throw IllegalStateException("Session has no Sui address")

        val inputs = session.proof.orElse(null)?.let { proof ->
            ZkLoginAuthenticator.parseInputs(proof, swiftArena)
        } ?: run {
            val eph = pendingZKEphemeral
                ?: throw IllegalStateException("No ephemeral available to generate proof")
            val signature = zkAuth.processJWT(
                session.jwt,
                session.salt,
                eph.account,
                eph.maxEpoch,
                eph.randomness,
                proofService,
                swiftArena,
            ).await()
            val ins = signature.getInputs(swiftArena)
            sessionManager.updateProof(ZkLoginAuthenticator.serializeInputs(ins))
            ins
        }

        val template = zkLoginSignature.init(
            inputs,
            session.maxEpoch,
            SuiData.init(ByteArray(0), swiftArena),
            swiftArena,
        )
        // Reconstructs the same stable, non-extractable StrongBox key (no biometric for the public
        // key); only the eventual `.sign(...)` prompts the user.
        val account = zkAuth.generateEphemeralKeypair(SignatureScheme.secp256r1(swiftArena), swiftArena)

        return zkAuth.createzkLoginSigner(account, template, userAddress, graphQLClient, swiftArena)
    }
}

/**
 * Thrown by [ZkLoginService.signer] when the session can no longer sign (its `maxEpoch` has passed or
 * the StrongBox key is unavailable). The caller re-authenticates just-in-time before signing.
 */
class SessionUnusableException : Exception("zkLogin session expired; re-authentication required.")
