package com.variance.nearby.services.sui

import com.variance.nearby.core.AppConstants
import com.variance.nearby.leansui.api.SuiNetwork
import org.swift.swiftkit.core.SwiftArena
import java.math.BigDecimal

/**
 * Sends the balance coin gaslessly from the sender's **address balance** to a recipient, via
 * `0x2::balance::send_funds` (#6d).
 *
 * Intentionally single-purpose: it draws only from the address balance. Value still held as
 * `Coin<T>` objects (the "pending" balance) is surfaced on Home and moved into the address balance by
 * [ConsolidateService] — a separate, also-gasless action.
 */
class SendService(
    network: SuiNetwork,
    swiftArena: SwiftArena,
    signerProvider: SignerProvider,
    private val coinType: String = AppConstants.USD_SUI_COIN_TYPE,
    private val coinDecimals: Int = AppConstants.BALANCE_COIN_DECIMALS,
) {
    private val runner = GaslessTransactionRunner(network, swiftArena, signerProvider)

    /** Sends [amount] (human units) to [recipient] (a `0x` address). Returns the transaction digest. */
    suspend fun send(amount: BigDecimal, recipient: String): String {
        // The amount entry caps fraction digits at coinDecimals, so the scaled value is integral.
        val baseUnits = amount.movePointRight(coinDecimals).toBigInteger().toLong()
        return runner.run { tx, _ ->
            tx.gaslessSendFunds(coinType, baseUnits, recipient)
        }
    }
}
