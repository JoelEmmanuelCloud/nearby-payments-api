import Foundation
import LeanSui
import LeanSuiApi

/// Builds, signs, and executes a single **gasless** transaction (Address Balances): gas is paid from
/// the sender's address balance, so `gasPrice`/`gasBudget` are 0 and no SUI is required.
///
/// This is the shared spine for every gasless write path (sending and consolidating). Callers supply
/// only the programmable-transaction body via `configure`; the runner owns the boilerplate — chain
/// identifier, sender, `enableGasless`, build, zkLogin signing, execution, and status checking.
///
/// No dry-run pre-flight: this GraphQL endpoint's `simulateTransaction` expects a JSON gRPC
/// `Transaction` rather than base64 BCS, so it rejects every transaction. Execution uses the correct
/// `transactionDataBcs` field, and since gas is 0 a rejected transaction costs nothing.
struct GaslessTransactionRunner {
  enum RunnerError: LocalizedError {
    case invalidChainIdentifier
    case executionFailed(String)

    var errorDescription: String? {
      switch self {
      case .invalidChainIdentifier: return "Invalid chain identifier."
      case .executionFailed(let message): return message
      }
    }
  }

  let provider: GraphQLSuiProvider
  let chainIdentifierBase58: String
  let signerProvider: () async throws -> ZkLoginSigner

  init(
    network: SuiNetworkKind = AppConstants.suiNetwork,
    chainIdentifierBase58: String = AppConstants.suiChainIdentifierBase58,
    signerProvider: @escaping () async throws -> ZkLoginSigner
  ) {
    self.provider = GraphQLSuiProvider(network: SuiNetwork(kind: network))
    self.chainIdentifierBase58 = chainIdentifierBase58
    self.signerProvider = signerProvider
  }

  /// Runs a gasless transaction whose body is populated by `configure` (given the prepared block and
  /// the resolved sender address). `configure` is `async` so it can read on-chain inputs (e.g. the
  /// sender's coin objects) before composing the transaction. Returns the executed transaction digest.
  func run(
    _ configure: (_ tx: TransactionBlock, _ sender: String) async throws -> Void
  ) async throws -> String {
    guard let chainId = chainIdentifierBase58.base58DecodedData, chainId.count == 32 else {
      throw RunnerError.invalidChainIdentifier
    }

    let signer = try await signerProvider()
    let sender = signer.getAddress()

    let tx = try TransactionBlock.create()
    try tx.setSender(sender: sender)
    try tx.enableGasless(
      chainIdentifier: [UInt8](chainId),
      nonce: UInt32.random(in: UInt32.min...UInt32.max)
    )
    try await configure(tx, sender)

    let bytes = try await tx.build(provider, false)
    let signature = try signer.signTransaction(bytes)
    let response = try await provider.executeTransactionBlock(
      txBytes: bytes.bytes, signatures: [signature])

    if response.effects?.status == .failure {
      throw RunnerError.executionFailed(
        response.effects?.executionError ?? "The transaction failed on-chain.")
    }
    return response.digest
  }
}
