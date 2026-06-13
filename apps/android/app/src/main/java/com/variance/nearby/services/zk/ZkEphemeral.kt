package com.variance.nearby.services.zk

import com.variance.nearby.leansui.Account

/**
 * Data model representing an active ephemeral cryptographic session for zkLogin.
 *
 * `ZkEphemeral` holds the secure hardware-backed signing account and metadata
 * required to construct and verify the zero-knowledge login signature.
 *
 * @param account The local hardware-bound ephemeral signing account (held in the StrongBox HSM).
 * @param maxEpoch The maximum blockchain epoch for which this session key remains valid.
 * @param randomness Cryptographic salt/randomness generated for nonce blinding.
 * @param nonce The base64URL-encoded zkLogin nonce bound to this session's parameters.
 */
class ZkEphemeral(
    val account: Account,
    val maxEpoch: Long,
    val randomness: ByteArray,
    val nonce: String,
)
