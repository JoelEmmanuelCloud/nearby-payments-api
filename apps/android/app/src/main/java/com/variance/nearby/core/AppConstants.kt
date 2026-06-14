package com.variance.nearby.core

import com.variance.nearby.leansui.api.SuiNetworkKind

object AppConstants {
    const val BASE_URL = "https://nearby-api.variance.space"
    const val API_VERSION = "v1"
    const val GOOGLE_SERVER_CLIENT_ID = "565533426961-glfffimsek0cni5pq7e7hfmi2umm0e5i.apps.googleusercontent.com"

    // / The Sui network used for zkLogin and the on-chain balance: "mainnet", "testnet", or "devnet".
    // / (A bridged `SuiNetworkKind` needs a SwiftArena, so it can't be a compile-time const.)
    val SUI_NETWORK = SuiNetworkKind.Discriminator.TESTNET

    // / Number of epochs ahead of the current epoch that a zkLogin ephemeral key stays valid.
    const val SUI_MAX_EPOCH_BUFFER = 2L

    const val REMOTE_ZK_PROVER = "https://prover.variance.space/v1"

    // / USDsui — Sui's native USD stablecoin (mainnet). Used for the Home account balance.
    // / Temp switch to testnet USDC (usdsui is mainnet-only, so it shows no balance on testnet).
    const val USD_SUI_COIN_TYPE =
        "0xa1ec7fc00a6f40db9693ad1415d0c193ad3906494428cf252621037bd7117e29::usdc::USDC"
    // "0x44f838219cf67b058f3b37907b655f226153c18e33dfcd0da559a844fea9b1c1::usdsui::USDSUI"

    // / Display symbol + entry precision for the balance coin (Home balance + send amount).
    const val BALANCE_COIN_SYMBOL = "USDsui"
    const val BALANCE_COIN_DECIMALS = 6

    // / How often the Home account balance silently refreshes (ms).
    const val BALANCE_REFRESH_MS = 15_000L

    // / Debounce before checking SuiNS name availability as the user types (ms).
    const val NAME_CHECK_DEBOUNCE_MS = 500L

    // / Deadline for one-shot network lookups (name check / resolution, activity refresh) before they
    // / time out and surface a toast, rather than spinning forever on a stalled connection (ms).
    const val NETWORK_TIMEOUT_MS = 12_000L

    // / Full 32-byte genesis checkpoint digests (the chain identifier) per network, hex-encoded. Their
    // / first 4 bytes are the familiar short chain ids (testnet 4c78adac, mainnet 35834a8a). Used in the
    // / `ValidDuring` expiration of gasless (address-balance) transactions for cross-chain replay safety.
    private const val TESTNET_GENESIS_DIGEST_HEX =
        "4c78adacf2a2f5ad80f27ed7d54aa69d3a78f1ca67fdef9ecf5754f5b8bb77b0"
    private const val MAINNET_GENESIS_DIGEST_HEX =
        "35834a8ac17ca48fb14ac8f99c17c98747e95dd07294ae41a46b382246a4499b"

    /** The 32-byte chain identifier for the configured network, for gasless transaction expiration. */
    val SUI_CHAIN_IDENTIFIER: ByteArray
        get() = hexToBytes(
            when (SUI_NETWORK) {
                SuiNetworkKind.Discriminator.MAINNET -> MAINNET_GENESIS_DIGEST_HEX
                else -> TESTNET_GENESIS_DIGEST_HEX
            },
        )

    // / DEBUG ONLY — leave `false`. When `true`, the zkLogin session is treated as expired so the
    // / just-in-time re-login (OAuth) path runs on the next sign. To test: set `true`, cold-launch the
    // / app (so the in-memory ephemeral is cleared), then tap Send or "Move to balance". Reset after.
    const val DEBUG_FORCE_SESSION_EXPIRED = false

    private fun hexToBytes(hex: String): ByteArray = ByteArray(hex.length / 2) {
        ((hex[it * 2].digitToInt(16) shl 4) or hex[it * 2 + 1].digitToInt(16)).toByte()
    }
}
