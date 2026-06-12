package com.variance.nearby.screens.activity

import com.variance.nearby.leansui.api.SuiNetworkKind

/** A `0xabcd…wxyz` short form of a Sui address for compact display. */
fun shortSuiAddress(address: String, leading: Int = 6, trailing: Int = 4): String {
    val body = if (address.startsWith("0x")) address.substring(2) else address
    if (body.length <= leading + trailing) return address
    return "0x${body.take(leading)}…${body.takeLast(trailing)}"
}

/** Whether two Sui addresses are the same, tolerant of `0x` and leading-zero padding differences. */
fun isSameSuiAddress(a: String?, b: String?): Boolean {
    if (a == null || b == null) return false
    fun normalize(raw: String): String {
        var value = raw.lowercase()
        if (value.startsWith("0x")) value = value.substring(2)
        return value.trimStart('0').ifEmpty { "0" }
    }
    return normalize(a) == normalize(b)
}

/** "You" for the current user, the short address otherwise, "—" if absent. */
fun suiPartyLabel(address: String?, currentAddress: String?): String {
    if (address == null) return "—"
    return if (isSameSuiAddress(address, currentAddress)) "You" else shortSuiAddress(address)
}

/** The Suiscan explorer URL for a transaction digest on the app's network. */
fun suiExplorerUrl(digest: String, network: SuiNetworkKind.Discriminator): String {
    val segment = when (network) {
        SuiNetworkKind.Discriminator.MAINNET -> "mainnet"
        SuiNetworkKind.Discriminator.TESTNET -> "testnet"
        SuiNetworkKind.Discriminator.DEVNET -> "devnet"
    }
    return "https://suiscan.xyz/$segment/tx/$digest"
}
