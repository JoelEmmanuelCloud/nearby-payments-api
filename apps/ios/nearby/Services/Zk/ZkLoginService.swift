import Auth
import Combine
import Foundation
import HSM
import LeanSui
import LeanSuiApi
import LeanSuiBCS

/// Service coordinator managing the full zkLogin lifecycle on iOS: ephemeral credentials and
/// nonces, background proof generation, proof persistence, and just-in-time signer construction.
///
/// `ZkLoginService` interacts with local hardware security (Secure Enclave), the remote prover,
/// and the persisted session to keep a usable `ZkLoginSigner` ready without paying the multi-second
/// proving cost in front of a user-initiated signing action.
@MainActor
final class ZkLoginService: ObservableObject {
  /// Errors surfaced while assembling a zkLogin signer.
  enum ZkLoginServiceError: Error {
    /// No persisted session is available.
    case noSession
    /// The session has no derived Sui address (populated by the login flow).
    case missingAddress
    /// No in-memory ephemeral session is available to generate a fresh proof.
    case noEphemeral
    /// The zkLogin session can no longer sign: the ephemeral key's `maxEpoch` has passed or the
    /// Secure Enclave key is unavailable. The caller must re-authenticate (fresh nonce + OAuth with
    /// the current provider) before a signer can be produced — see `freshSigner(...)`.
    case sessionUnusable
  }

  private let zkAuth: ZkLoginAuthenticator
  private let sessionManager: SessionManager
  private let proofService: RemoteZkProofService
  private let graphQLClient: SuiGraphQLClient

  /// The active zkLogin ephemeral credential containing signing key material and nonce values.
  @Published private(set) var pendingZKEphemeral: ZkEphemeral?

  /// Memoized in-flight signer construction, so warm-up and on-demand callers share one proving run.
  private var signerTask: Task<ZkLoginSigner, Error>?

  /// Initializes the service with the Secure Enclave HSM (required for `.secp256r1` ephemeral key
  /// generation) and the session manager that owns persisted zkLogin state.
  init(hsm: any HardwareSecurityModule, sessionManager: SessionManager) {
    let network = SuiNetwork(kind: AppConstants.suiNetwork)
    self.zkAuth = ZkLoginAuthenticator(provider: GraphQLSuiProvider(network: network), hsm: hsm)
    self.sessionManager = sessionManager
    // Endpoints come from compile-time constants, so a malformed URL is a programmer error.
    self.proofService = try! RemoteZkProofService(urlString: AppConstants.remoteZkProverURL)
    self.graphQLClient = try! SuiGraphQLClient(urlString: network.graphQLEndpointString)
  }

  /// Generates a new hardware-backed ephemeral keypair, fetches the current blockchain epoch,
  /// and prepares a secure zkLogin nonce bound to the Secure Enclave public key.
  ///
  /// - Returns: The generated base64URL-encoded zkLogin nonce.
  /// - Throws: An error if key generation, network epoch lookup, or nonce serialization fails.
  func prepareNonce() async throws -> String {
    // A new login invalidates any previously cached signer/proof.
    signerTask = nil

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

  /// Derives the (stable) zkLogin Sui address and persists it together with the current `maxEpoch`.
  ///
  /// This is the **single writer** of the session's Sui properties: the address is a pure function of
  /// `iss/sub/aud/salt` (never changes), while `maxEpoch` is renewed by each (re-)auth. Called by the
  /// login flow right after OAuth completes, before binding/warm-up. Identity must not write these.
  ///
  /// - Throws: `ZkLoginServiceError.noSession` if no session is present, or a derivation/storage error.
  func commitSessionIdentity() throws {
    guard let session = try sessionManager.getCurrentSession() else {
      throw ZkLoginServiceError.noSession
    }
    let address = try zkAuth.derivezkLoginAddress(jwt: session.jwt, userSalt: session.salt)
    let maxEpoch = pendingZKEphemeral?.maxEpoch ?? session.maxEpoch
    try sessionManager.updateSuiProperties(maxEpoch: maxEpoch, suiAddress: address)
  }

  /// Eagerly prepares a usable signer in the background after login, so the expensive proof is ready
  /// before the user attempts to sign. Discardable: callers may fire-and-forget or await the result.
  ///
  /// Sole side effect on the session is persisting the generated proof; it does not touch maxEpoch
  /// or the Sui address (those are owned by the login flow).
  @discardableResult
  func warmUpSigner() async throws -> ZkLoginSigner {
    try await resolveSigner()
  }

  /// Whether the persisted session can currently produce a valid signature: its `maxEpoch` is still
  /// ahead of the chain's current epoch and the Secure Enclave key is present. A fresh login (with a
  /// `pendingZKEphemeral` in memory) is also usable even before its proof is persisted.
  func isSessionUsable() async throws -> Bool {
    if pendingZKEphemeral != nil { return true }
    if AppConstants.debugForceSessionExpired { return false }
    let epoch = try await zkAuth.getCurrentEpoch().epoch
    return try sessionManager.isZkLoginSessionUsable(currentEpoch: epoch)
  }

  /// Returns a ready-to-use signer, constructing it just-in-time from the persisted proof (or, if
  /// none is cached yet, by generating one). Shares the in-flight warm-up task when present.
  ///
  /// Throws `ZkLoginServiceError.sessionUnusable` when the session can no longer sign (expired
  /// `maxEpoch` / missing Secure Enclave key) so the caller routes a just-in-time re-authentication
  /// instead of submitting a signature that the network will reject. Without this guard the signer
  /// would be assembled from a stale proof and fail only at execution, with an opaque error.
  func signer() async throws -> ZkLoginSigner {
    guard try await isSessionUsable() else {
      throw ZkLoginServiceError.sessionUnusable
    }
    return try await resolveSigner()
  }

  /// Clears any active pending zkLogin ephemeral session and cached signer.
  func clearPending() {
    pendingZKEphemeral = nil
    signerTask = nil
  }

  /// Returns the memoized signer task's value, resetting the cache on failure so callers can retry.
  private func resolveSigner() async throws -> ZkLoginSigner {
    let task = signerTask ?? Task { try await self.constructSigner() }
    signerTask = task
    do {
      return try await task.value
    } catch {
      signerTask = nil
      throw error
    }
  }

  /// Assembles a `ZkLoginSigner` from the persisted session: reuses the cached proof when present,
  /// otherwise generates one from the in-memory ephemeral and persists it.
  private func constructSigner() async throws -> ZkLoginSigner {
    guard let session = try sessionManager.getCurrentSession() else {
      throw ZkLoginServiceError.noSession
    }
    guard let userAddress = session.suiAddress else {
      throw ZkLoginServiceError.missingAddress
    }

    let inputs: zkLoginSignatureInputs
    if let proof = session.proof {
      inputs = try ZkLoginAuthenticator.parseInputs(proof)
    } else {
      guard let eph = pendingZKEphemeral else {
        throw ZkLoginServiceError.noEphemeral
      }
      let signature = try await zkAuth.processJWT(
        jwt: session.jwt,
        userSalt: session.salt,
        ephemeralKeyPair: eph.account,
        maxEpoch: eph.maxEpoch,
        randomness: eph.randomness,
        remoteProofService: proofService)
      inputs = signature.inputs
      try sessionManager.updateProof(ZkLoginAuthenticator.serializeInputs(inputs))
    }

    let template = zkLoginSignature(
      inputs: inputs, maxEpoch: session.maxEpoch, userSignature: SuiData([]))
    // Reconstructs the same stable, non-extractable Secure Enclave key (no biometric for the
    // public key); only the eventual `.sign(...)` prompts the user.
    let account = try zkAuth.generateEphemeralKeypair(scheme: .secp256r1)

    return zkAuth.createzkLoginSigner(
      ephemeralKeyPair: account,
      zkLoginSignature: template,
      userAddress: userAddress,
      graphQLClient: graphQLClient)
  }
}
