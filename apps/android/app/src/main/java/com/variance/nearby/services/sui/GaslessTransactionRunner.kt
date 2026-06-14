package com.variance.nearby.services.sui

import com.variance.nearby.core.AppConstants
import com.variance.nearby.leansui.TransactionBlock
import com.variance.nearby.leansui.ZkLoginSigner
import com.variance.nearby.leansui.api.GraphQLSuiProvider
import com.variance.nearby.leansui.api.SuiNetwork
import com.variance.nearby.leansui.api.TransactionExecutionStatus
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.future.await
import kotlinx.coroutines.withContext
import org.swift.swiftkit.core.SwiftArena
import java.util.Optional
import kotlin.random.Random

/** Produces a usable zkLogin signer on demand, re-authenticating first when the session has expired. */
typealias SignerProvider = suspend () -> ZkLoginSigner

/**
 * Builds, signs, and executes a single **gasless** transaction (Address Balances): gas is paid from
 * the sender's address balance, so `gasPrice`/`gasBudget` are 0 and no SUI is required.
 *
 * The shared spine for every gasless write path (sending and consolidating). Callers supply only the
 * programmable-transaction body via `configure`; the runner owns the boilerplate — chain identifier,
 * sender, `enableGasless`, build, zkLogin signing, execution, and status checking. No dry-run
 * pre-flight: this GraphQL endpoint's simulate wants a JSON gRPC transaction, not base64 BCS, so it
 * rejects every tx; execution uses the correct `transactionDataBcs` field, and gas is 0.
 */
class GaslessTransactionRunner(
    network: SuiNetwork,
    private val swiftArena: SwiftArena,
    private val signerProvider: SignerProvider,
    private val chainIdentifier: ByteArray = AppConstants.SUI_CHAIN_IDENTIFIER,
) {
    /** Exposed so callers can read on-chain inputs (e.g. coin objects) with the same provider. */
    val provider: GraphQLSuiProvider = GraphQLSuiProvider.init(network, swiftArena)

    /**
     * Runs a gasless transaction whose body is populated by [configure] (given the prepared block and
     * the resolved sender address). Returns the executed transaction digest.
     */
    suspend fun run(configure: suspend (tx: TransactionBlock, sender: String) -> Unit): String = withContext(Dispatchers.IO) {
        val signer = signerProvider()
        val sender = signer.address

        val tx = TransactionBlock.create(swiftArena)
        tx.setSender(sender)
        tx.enableGasless(chainIdentifier, Random.nextInt())
        configure(tx, sender)

        val bytes = tx.build(provider, Optional.empty(), swiftArena).await()
        val signature = signer.signTransaction(bytes)
        val options = GraphQLSuiProvider.TransactionResponseOptions.init(
            true,
            true,
            true,
            true,
            true,
            swiftArena,
        )
        val response = provider
            .executeTransactionBlock(bytes.bytes, arrayOf(signature), options, swiftArena)
            .await()

        val status = response.getEffects(swiftArena).orElse(null)
            ?.getStatus(swiftArena)?.orElse(null)?.discriminator
        if (status == TransactionExecutionStatus.Discriminator.FAILURE) {
            throw RuntimeException("The transaction failed on-chain.")
        }
        response.digest
    }
}
