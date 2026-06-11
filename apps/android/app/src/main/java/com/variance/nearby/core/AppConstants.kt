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
    const val USD_SUI_COIN_TYPE =
        "0x44f838219cf67b058f3b37907b655f226153c18e33dfcd0da559a844fea9b1c1::usdsui::USDSUI"

    // / How often the Home account balance silently refreshes (ms).
    const val BALANCE_REFRESH_MS = 30_000L

    // / Debounce before checking SuiNS name availability as the user types (ms).
    const val NAME_CHECK_DEBOUNCE_MS = 500L
}
