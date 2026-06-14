package com.variance.nearby.services.sui

import com.variance.nearby.core.AppConstants
import com.variance.nearby.leansui.api.SuiNetwork
import kotlinx.coroutines.future.await
import org.swift.swiftkit.core.SwiftArena

/**
 * Moves the owner's `Coin<T>` objects (the "pending" balance) into their **address balance** so they
 * become spendable by the gasless send. The single-purpose counterpart to [SendService]: one gasless
 * transaction calling `0x2::coin::send_funds<T>(coin, self)` for each coin object — which consumes the
 * coins into the address balance without writing any object, so it qualifies as a gasless stablecoin
 * transfer (no SUI required).
 */
class ConsolidateService(
    network: SuiNetwork,
    swiftArena: SwiftArena,
    signerProvider: SignerProvider,
    private val coinType: String = AppConstants.USD_SUI_COIN_TYPE,
) {
    private val runner = GaslessTransactionRunner(network, swiftArena, signerProvider)

    /** Thrown when there are no coin objects to move into the address balance. */
    class NothingToConsolidate : Exception("No pending balance to move.")

    /**
     * Consolidates every `Coin<coinType>` object the owner holds into their address balance. Returns
     * the executed transaction digest, or throws [NothingToConsolidate] when there are no coins.
     */
    suspend fun consolidate(): String = runner.run { tx, owner ->
        val ids = runner.provider.getAllCoinObjectIds(owner, coinType).await()
        if (ids.isEmpty()) throw NothingToConsolidate()
        tx.gaslessDepositCoins(coinType, ids, owner)
    }
}
