package com.variance.nearby.hsm

import android.content.Context
import android.content.pm.PackageManager
import android.os.Looper
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import androidx.biometric.BiometricPrompt
import org.swift.swiftkit.core.SwiftArena
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.security.spec.ECGenParameterSpec
import java.util.Optional
import java.util.concurrent.CompletableFuture
import java.util.concurrent.ExecutionException

/**
 * Android implementation of the `HardwareSecurityModule` protocol.
 * Generates and stores cryptographic keys in the Android KeyStore provider.
 * Uses a hardware-backed StrongBox KeyStore if supported by the device, falling
 * back to standard software/TEE-backed hardware keystore if StrongBox is unavailable.
 *
 * The signing key requires per-use biometric authentication. Android Keystore does not present a
 * prompt itself (it only throws if no auth has occurred), so [sign] binds the signing operation to
 * a `BiometricPrompt.CryptoObject` and delegates the prompt to a UI-owned [BiometricGate], blocking
 * the (background) caller until the user authenticates — preserving the synchronous
 * `HardwareSecurityModule.sign` contract across the bridge.
 *
 * @property context Application context (system features).
 * @property gate Bridges signing to the Compose biometric prompt (see [BiometricGate]).
 */
class StrongBoxHSM(
    private val context: Context,
    private val gate: BiometricGate,
) : HardwareSecurityModule {
    private val keyAlias = "com.variance.nearby.hsm.key"
    private val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }

    /**
     * Generates a NIST P-256 (secp256r1) EC keypair in the AndroidKeyStore.
     * Enforces StrongBox protection if available and requires a strong biometric for
     * every signing operation (auth-per-use). Key generation itself does not prompt;
     * only [sign] does.
     *
     * @param swiftArena Memory arena to allocate the returned Swift-bridged [DEREncodedItem].
     * @return The DER-encoded X.509 representation of the public key.
     */
    override fun generateKey(swiftArena: SwiftArena): DEREncodedItem {
        deleteKey()

        val kpg =
            KeyPairGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_EC,
                "AndroidKeyStore",
            )

        val hasStrongBox = context.packageManager.hasSystemFeature(PackageManager.FEATURE_STRONGBOX_KEYSTORE)

        val specBuilder =
            KeyGenParameterSpec
                .Builder(
                    keyAlias,
                    KeyProperties.PURPOSE_SIGN,
                ).setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
                .setDigests(KeyProperties.DIGEST_SHA256)
                .setUserAuthenticationRequired(true)
                // Timeout 0 = auth-per-use: each signature must be authorized via a
                // CryptoObject-bound prompt (see [sign]). STRONG biometric only —
                // required for CryptoObject-backed (crypto-bound) authentication.
                .setUserAuthenticationParameters(0, KeyProperties.AUTH_BIOMETRIC_STRONG)

        if (hasStrongBox) {
            specBuilder.setIsStrongBoxBacked(true)
        }

        kpg.initialize(specBuilder.build())
        return DEREncodedItem.init(kpg.generateKeyPair().public.encoded, swiftArena)
    }

    /**
     * Retrieves the public key of the active key pair if one exists. Does not require auth.
     *
     * @param swiftArena Memory arena to allocate the returned Swift-bridged [DEREncodedItem].
     * @return An Optional wrapping the DER-encoded public key, or empty if the key is not found.
     */
    override fun getPublicKey(swiftArena: SwiftArena): Optional<DEREncodedItem> {
        val entry = keyStore.getEntry(keyAlias, null) as? KeyStore.PrivateKeyEntry ?: return Optional.empty()
        return Optional.of(DEREncodedItem.init(entry.certificate.publicKey.encoded, swiftArena))
    }

    /**
     * Signs data using the AndroidKeyStore EC private key with SHA256withECDSA, gated by a
     * per-use biometric prompt.
     *
     * Binds the [Signature] to a [BiometricPrompt.CryptoObject], hands it to the [gate], and blocks
     * the calling thread until the user authenticates, so the bridged signature stays synchronous.
     *
     * @param data The raw data bytes to sign.
     * @param swiftArena Memory arena to allocate the returned Swift-bridged signature structure.
     * @return A [DEREncodedItem] wrapping the signature bytes.
     * @throws IllegalStateException if called on the main thread (the blocking `get()` below would
     *   deadlock the prompt) or if the authenticated result is missing its signing object.
     */
    override fun sign(
        data: ByteArray,
        swiftArena: SwiftArena,
    ): DEREncodedItem {
        check(Looper.myLooper() != Looper.getMainLooper()) {
            "StrongBoxHSM.sign must be called off the main thread; it blocks while the biometric prompt runs."
        }

        val entry =
            keyStore.getEntry(keyAlias, null) as? KeyStore.PrivateKeyEntry
                ?: throw Exception("Key not found")

        // Initialize, but do not update/sign until the CryptoObject has been authenticated.
        val signature =
            Signature.getInstance("SHA256withECDSA").apply {
                initSign(entry.privateKey)
            }

        // Blocks the background caller until the gate resolves the prompt. The gate guarantees
        // completion (success, error, cancellation, or its own timeout), so this never hangs.
        val authenticated =
            try {
                gate.authenticate(BiometricPrompt.CryptoObject(signature)).get()
            } catch (e: ExecutionException) {
                // Surface the underlying cause (cancellation, biometric error, timeout) directly.
                throw e.cause ?: e
            }

        val authenticatedSignature =
            authenticated.signature
                ?: error("Authenticated CryptoObject did not contain a signing object.")
        authenticatedSignature.update(data)

        return DEREncodedItem.init(authenticatedSignature.sign(), swiftArena)
    }

    /**
     * Deletes the cryptographic key entry from the AndroidKeyStore.
     */
    override fun deleteKey() {
        if (keyStore.containsAlias(keyAlias)) {
            keyStore.deleteEntry(keyAlias)
        }
    }
}

/**
 * Bridges the headless, synchronous [StrongBoxHSM.sign] (invoked off the main thread from the
 * Swift/JNI signing path) to a UI-owned biometric prompt.
 *
 * The new `androidx.biometric.compose` API is Activity-Result/Compose scoped: its launcher must
 * be registered during composition and invoked on the UI thread, so the prompt cannot be created
 * inside `sign()`. Instead `sign()` hands the crypto-bound [BiometricPrompt.CryptoObject] to this
 * gate and blocks on the returned future; the UI layer presents the prompt and completes the
 * future with the authenticated crypto object (or fails it on error/cancel).
 */
fun interface BiometricGate {
    /**
     * Requests user authentication bound to [crypto].
     *
     * Called off the main thread. The implementation drives the prompt on the UI thread and
     * completes the returned future with the authenticated [BiometricPrompt.CryptoObject], or
     * completes it exceptionally on error or cancellation.
     */
    fun authenticate(crypto: BiometricPrompt.CryptoObject): CompletableFuture<BiometricPrompt.CryptoObject>
}
