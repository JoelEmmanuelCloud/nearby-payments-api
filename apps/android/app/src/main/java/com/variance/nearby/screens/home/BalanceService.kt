package com.variance.nearby.screens.home

import com.variance.nearby.core.AppConstants
import com.variance.nearby.leansui.api.GraphQLSuiProvider
import com.variance.nearby.leansui.api.SuiNetwork
import kotlinx.coroutines.future.await
import org.swift.swiftkit.core.SwiftArena
import java.math.BigDecimal
import java.util.Optional

/**
 * IO boundary for the on-chain USDsui balance. Wraps a mainnet GraphQL provider and is single-purpose:
 * it returns the owner's USDsui balance scaled by the token's decimals (looked up once and cached).
 */
class BalanceService(
    network: SuiNetwork,
    private val swiftArena: SwiftArena,
    private val coinType: String = AppConstants.USD_SUI_COIN_TYPE,
) {
    private val provider: GraphQLSuiProvider = GraphQLSuiProvider.init(network, swiftArena)

    @Volatile
    private var cachedDecimals: Int? = null

    /** The owner's USDsui balance, scaled by the token's decimals. */
    suspend fun usdSuiBalance(owner: String): BigDecimal {
        val decimals = decimals()
        val raw = provider.getBalance(owner, Optional.of(coinType), swiftArena).await().totalBalance
        return BigDecimal(raw).movePointLeft(decimals)
    }

    private suspend fun decimals(): Int {
        cachedDecimals?.let { return it }
        val d = provider.getCoinMetadata(coinType, swiftArena).await().decimals
        val decimals = if (d.isPresent) d.asLong.toInt() else 6
        cachedDecimals = decimals
        return decimals
    }
}
