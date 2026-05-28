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

class StrongBoxHSM(private val context: Context): HardwareSecurityModule {

    private val keyAlias = "com.variance.nearby.hsm.key"
    private val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }

    override fun generateKey(swiftArena: SwiftArena): DEREncodedItem {
        deleteKey()

        val kpg = KeyPairGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_EC,
            "AndroidKeyStore"
        )
        
        val hasStrongBox = context.packageManager.hasSystemFeature(PackageManager.FEATURE_STRONGBOX_KEYSTORE)
        
        val specBuilder = KeyGenParameterSpec.Builder(
            keyAlias,
            KeyProperties.PURPOSE_SIGN
        )
            .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
            .setDigests(KeyProperties.DIGEST_SHA256)
            
        if (hasStrongBox) {
            specBuilder.setIsStrongBoxBacked(true)
        }

        kpg.initialize(specBuilder.build())
        return DEREncodedItem.init(kpg.generateKeyPair().public.encoded, swiftArena)
    }

    override fun getPublicKey(swiftArena: SwiftArena): Optional<DEREncodedItem> {
        val entry = keyStore.getEntry(keyAlias, null) as? KeyStore.PrivateKeyEntry ?: return Optional.empty()
        return Optional.of(DEREncodedItem.init(entry.certificate.publicKey.encoded, swiftArena))
    }

    override fun sign(data: ByteArray, swiftArena: SwiftArena): DEREncodedItem {
        val entry = keyStore.getEntry(keyAlias, null) as? KeyStore.PrivateKeyEntry
            ?: throw Exception("Key not found")

        val signature = Signature.getInstance("SHA256withECDSA").apply {
            initSign(entry.privateKey)
            update(data)
        }
        return DEREncodedItem.init(signature.sign(), swiftArena)
    }

    override fun deleteKey() {
        if (keyStore.containsAlias(keyAlias)) {
            keyStore.deleteEntry(keyAlias)
        }
    }
}
