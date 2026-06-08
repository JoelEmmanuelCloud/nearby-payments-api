import Combine
import Foundation
import HSM
import LeanSui
import LeanSuiApi

/// Service coordinator managing hardware-backed ephemeral credentials and nonces for zkLogin on iOS.
///
/// `ZkLoginService` interacts with local hardware security (Secure Enclave) and remote
/// GraphQL providers to prepare cryptographic parameters required for zkLogin authentication.
@MainActor
final class ZkLoginService: ObservableObject {
  private let zkAuth = ZkLoginAuthenticator(
    provider: GraphQLSuiProvider(network: SuiNetwork(kind: AppConstants.suiNetwork)))

  /// The active zkLogin ephemeral credential containing signing key material and nonce values.
  @Published private(set) var pendingZKEphemeral: ZkEphemeral?

  /// Default constructor initialization.
  init() {}

  /// Generates a new hardware-backed ephemeral keypair, fetches the current blockchain epoch,
  /// and prepares a secure zkLogin nonce bound to the Secure Enclave public key.
  ///
  /// - Parameter hsm: Secure Enclave interface instance.
  /// - Returns: The generated base64URL-encoded zkLogin nonce.
  /// - Throws: An error if key generation, network epoch lookup, or nonce serialization fails.
  func prepareNonce() async throws -> String {
    let account = try zkAuth.generateEphemeralKeypair(scheme: .secp256r1)
    let epoch = try await zkAuth.getCurrentEpoch()
    let maxEpoch = epoch.epoch + AppConstants.suiMaxEpochBuffer
    let randomness = try zkAuth.generateRandomness()
    let nonce = try zkAuth.generateZkNonce(
      ephemeralKeyPair: account, maxEpoch: maxEpoch, randomness: randomness)

    let session = ZkEphemeral(
      account: account, maxEpoch: maxEpoch, randomness: randomness, nonce: nonce)
    self.pendingZKEphemeral = session
    return nonce
  }

  /// Clears any active pending zkLogin ephemeral session.
  func clearPending() {
    pendingZKEphemeral = nil
  }
}
