package com.variance.nearby.core

import com.variance.nearby.leansui.api.SuiNetworkKind

object AppConstants {
    const val BASE_URL = "https://nearby-api.variance.space"
    const val API_VERSION = "v1"
    const val GOOGLE_SERVER_CLIENT_ID = "565533426961-glfffimsek0cni5pq7e7hfmi2umm0e5i.apps.googleusercontent.com"

    // / The Sui network used for zkLogin: "mainnet", "testnet", or "devnet".
    // / (A bridged `SuiNetworkKind` needs a SwiftArena, so it can't be a compile-time const.)
    val SUI_NETWORK = SuiNetworkKind.Discriminator.TESTNET

    // / Number of epochs ahead of the current epoch that a zkLogin ephemeral key stays valid.
    const val SUI_MAX_EPOCH_BUFFER = 2L

    const val REMOTE_ZK_PROVER = "https://variance.outray.app/v1"
}
