package com.variance.nearby.hsm

import android.content.Context
import android.content.pm.PackageManager
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.security.spec.ECGenParameterSpec

class StrongBoxHSM(private val context: Context) {

    private val keyAlias = "com.variance.nearby.hsm.key"
    private val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }

    fun generateKey(): ByteArray {
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
        return kpg.generateKeyPair().public.encoded
    }

    fun getPublicKey(): ByteArray? {
        val entry = keyStore.getEntry(keyAlias, null) as? KeyStore.PrivateKeyEntry ?: return null
        return entry.certificate.publicKey.encoded
    }

    fun sign(data: ByteArray): ByteArray {
        val entry = keyStore.getEntry(keyAlias, null) as? KeyStore.PrivateKeyEntry
            ?: throw Exception("Key not found")

        val signature = Signature.getInstance("SHA256withECDSA").apply {
            initSign(entry.privateKey)
            update(data)
        }
        
        return signature.sign()
    }

    fun deleteKey() {
        if (keyStore.containsAlias(keyAlias)) {
            keyStore.deleteEntry(keyAlias)
        }
    }
}
