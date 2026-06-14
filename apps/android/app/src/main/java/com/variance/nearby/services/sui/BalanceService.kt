package com.variance.nearby.services.sui

import com.variance.nearby.core.AppConstants
import com.variance.nearby.leansui.api.GraphQLSuiProvider
import com.variance.nearby.leansui.api.SuiNetwork
import kotlinx.coroutines.future.await
import org.swift.swiftkit.core.SwiftArena
import java.math.BigDecimal
import java.util.Optional

/**
 * The owner's balance for the app coin, split across the two places value can live: the account-style
 * **address balance** (spendable gaslessly) and classic **`Coin<T>` objects** (a "pending" balance
 * that must be explicitly consolidated into the address balance first).
 */
data class BalanceBreakdown(val addressBalance: BigDecimal, val coinBalance: BigDecimal) {
    /** Combined holdings (what the node's `totalBalance` reports). */
    val total: BigDecimal get() = addressBalance + coinBalance
}

/**
 * IO boundary for the on-chain balance. Wraps a GraphQL provider and returns the owner's balance split
 * into its address-balance (spendable) and coin-object (pending) parts, scaled by the token's decimals
 * (looked up once and cached).
 */
class BalanceService(
    network: SuiNetwork,
    private val swiftArena: SwiftArena,
    private val coinType: String = AppConstants.USD_SUI_COIN_TYPE,
) {
    private val provider: GraphQLSuiProvider = GraphQLSuiProvider.init(network, swiftArena)

    @Volatile
    private var cachedDecimals: Int? = null

    /** The owner's spendable (address-balance) holdings — what can be sent right now. */
    suspend fun usdSuiBalance(owner: String): BigDecimal = breakdown(owner).addressBalance

    /**
     * The owner's balance split into address-balance (spendable) and coin-object (pending) parts. The
     * node's `totalBalance` already aggregates both pools; summing the owner's coin objects gives the
     * pending part, so the address balance is their difference.
     */
    suspend fun breakdown(owner: String): BalanceBreakdown {
        val decimals = decimals()
        val total = BigDecimal(
            provider.getBalance(owner, Optional.of(coinType), swiftArena).await().totalBalance,
        )
        val coins = BigDecimal(provider.getTotalCoinObjectBalance(owner, coinType).await())
        val address = (total - coins).max(BigDecimal.ZERO) // guard against a transient over-count
        return BalanceBreakdown(
            addressBalance = address.movePointLeft(decimals),
            coinBalance = coins.movePointLeft(decimals),
        )
    }

    private suspend fun decimals(): Int {
        cachedDecimals?.let { return it }
        val d = provider.getCoinMetadata(coinType, swiftArena).await().decimals
        val decimals = if (d.isPresent) d.asLong.toInt() else 6
        cachedDecimals = decimals
        return decimals
    }
}
