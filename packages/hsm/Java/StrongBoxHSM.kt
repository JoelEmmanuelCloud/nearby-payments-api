package com.variance.nearby.hsm

import android.content.Context
import android.content.pm.PackageManager
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import org.swift.swiftkit.core.SwiftArena
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.security.spec.ECGenParameterSpec
import java.util.Optional

/**
 * Android implementation of the `HardwareSecurityModule` protocol.
 * Generates and stores cryptographic keys in the Android KeyStore provider.
 * Uses a hardware-backed StrongBox KeyStore if supported by the device, falling
 * back to standard software/TEE-backed hardware keystore if StrongBox is unavailable.
 *
 * @property context Application context to check system features (PackageManager).
 */
class StrongBoxHSM(
    private val context: Context,
) : HardwareSecurityModule {
    private val keyAlias = "com.variance.nearby.hsm.key"
    private val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }

    /**
     * Generates a NIST P-256 (secp256r1) EC keypair in the AndroidKeyStore.
     * Enforces StrongBox protection if available.
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

        if (hasStrongBox) {
            specBuilder.setIsStrongBoxBacked(true)
        }

        kpg.initialize(specBuilder.build())
        return DEREncodedItem.init(kpg.generateKeyPair().public.encoded, swiftArena)
    }

    /**
     * Retrieves the public key of the active key pair if one exists.
     *
     * @param swiftArena Memory arena to allocate the returned Swift-bridged [DEREncodedItem].
     * @return An Optional wrapping the DER-encoded public key, or empty if the key is not found.
     */
    override fun getPublicKey(swiftArena: SwiftArena): Optional<DEREncodedItem> {
        val entry = keyStore.getEntry(keyAlias, null) as? KeyStore.PrivateKeyEntry ?: return Optional.empty()
        return Optional.of(DEREncodedItem.init(entry.certificate.publicKey.encoded, swiftArena))
    }

    /**
     * Signs data using the AndroidKeyStore EC private key with SHA256withECDSA.
     *
     * @param data The raw data bytes to sign.
     * @param swiftArena Memory arena to allocate the returned Swift-bridged signature structure.
     * @return A [DEREncodedItem] wrapping the signature bytes.
     */
    override fun sign(
        data: ByteArray,
        swiftArena: SwiftArena,
    ): DEREncodedItem {
        val entry =
            keyStore.getEntry(keyAlias, null) as? KeyStore.PrivateKeyEntry
                ?: throw Exception("Key not found")

        val signature =
            Signature.getInstance("SHA256withECDSA").apply {
                initSign(entry.privateKey)
                update(data)
            }
        return DEREncodedItem.init(signature.sign(), swiftArena)
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
