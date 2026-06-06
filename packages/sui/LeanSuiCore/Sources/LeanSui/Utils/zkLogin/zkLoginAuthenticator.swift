//
//  zkLoginAuthenticator.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import BigInt
import Foundation
import HSM
import LeanSuiApi
import LeanSuiBCS

/// Manages the zkLogin authentication flow
public class ZkLoginAuthenticator {
  private let provider: GraphQLSuiProvider

  public init(provider: GraphQLSuiProvider) {
    self.provider = provider
  }

  /// Generate a **software** ephemeral Ed25519 keypair for zkLogin.
  ///
  /// The private key lives in app memory. Prefer ``generateHardwareEphemeralKeypair(hsm:)``
  /// where a secure element is available; use this for unsupported devices or testing.
  /// - Returns: A new in-memory Ed25519 keypair.
  public func generateSoftwareEphemeralKeypair() throws -> Account {
    return try Account(accountType: .ed25519)
  }

  /// Generate a **hardware-backed** ephemeral P-256 (secp256r1) keypair for zkLogin.
  ///
  /// The private key is generated and held in the platform secure element (Secure Enclave /
  /// Android Keystore StrongBox) and never enters app memory; signing is delegated to the HSM.
  /// zkLogin accepts secp256r1 ephemeral keys (scheme flag `0x02`).
  ///
  /// - Parameter hsm: The platform HSM that owns (or will generate) the P-256 key.
  /// - Returns: An `Account` whose signing is backed by `hsm`.
  public func generateHardwareEphemeralKeypair(hsm: any HardwareSecurityModule) throws -> Account {
    return try Account(hsm: hsm)
  }

  /// Generate a nonce for the OAuth flow based on the ephemeral public key
  /// - Parameters:
  ///   - publicKey: The ephemeral public key
  ///   - maxEpoch: The maximum epoch until which this nonce is valid
  ///   - randomness: Optional random bytes to include in the nonce
  /// - Returns: A base64 encoded nonce string for use in OAuth
  public func generateNonce(
    publicKey: any PublicKeyProtocol, maxEpoch: UInt64, randomness: [UInt8]? = nil
  ) throws -> String {
    let jwtRandomness = try randomness ?? generateRandomness()

    // Convert randomness bytes to a BigInt string
    let randomnessData = Data(jwtRandomness)
    let randomnessString = zkLoginNonce.toBigIntBE(bytes: randomnessData).description

    return try zkLoginNonce.generateNonce(
      publicKey: publicKey,
      maxEpoch: Int(maxEpoch),
      randomness: randomnessString
    )
  }

  /// Bridge-friendly nonce generation for the OAuth flow.
  ///
  /// Takes the ephemeral `Account` (which bridges cleanly) and derives its public
  /// key internally, avoiding the `any PublicKeyProtocol` existential parameter and
  /// the optional-array `randomness` that prevent ``generateNonce(publicKey:maxEpoch:randomness:)``
  /// from crossing the Swift↔Java boundary. Produces the same nonce.
  ///
  /// - Parameters:
  ///   - ephemeralKeyPair: The ephemeral keypair the nonce commits to.
  ///   - maxEpoch: The maximum epoch until which this nonce is valid.
  ///   - randomness: The random bytes used in the nonce (keep these for proof generation).
  /// - Returns: The base64-encoded zkLogin nonce string for use in OAuth.
  public func generateZkNonce(
    ephemeralKeyPair: Account, maxEpoch: UInt64, randomness: [UInt8]
  ) throws -> String {
    try generateNonce(
      publicKey: ephemeralKeyPair.publicKey,
      maxEpoch: maxEpoch,
      randomness: randomness
    )
  }

  /// Generate random bytes for use in nonce creation
  /// - Returns: Random bytes
  public func generateRandomness() throws -> [UInt8] {
    // Generate 16 bytes of secure random data (cross-platform CSPRNG).
    var rng = SystemRandomNumberGenerator()
    return (0..<16).map { _ in UInt8.random(in: .min ... .max, using: &rng) }
  }

  /// Get the current epoch from the network
  /// - Returns: The current epoch and related information
  public func getCurrentEpoch() async throws -> EpochInfo {
    let systemState = try await provider.getLatestSuiSystemState()
    let startMs = systemState.startTimestamp.map { UInt64($0.timeIntervalSince1970 * 1000) } ?? 0
    // `SuiSystemStateSummary` exposes start/end timestamps rather than a raw
    // duration; derive the epoch duration from them when both are present
    // (falling back to the canonical 24h epoch otherwise).
    let durationMs: UInt64 = {
      if let start = systemState.startTimestamp, let end = systemState.endTimestamp {
        return UInt64(max(0, end.timeIntervalSince(start)) * 1000)
      }
      return 24 * 60 * 60 * 1000
    }()
    return EpochInfo(
      epoch: systemState.epoch,
      epochStartTimestampMs: startMs,
      epochDurationMs: durationMs
    )
  }

  /// Process JWT and salt to derive a zkLogin signature
  /// - Parameters:
  ///   - jwt: The JWT token from OAuth provider
  ///   - userSalt: The user's salt value
  ///   - ephemeralKeyPair: The ephemeral keypair
  ///   - maxEpoch: The maximum epoch for validity
  ///   - randomness: The randomness used in nonce generation
  ///   - proofService: Optional service for ZK proof generation
  /// - Returns: A zkLogin signature object
  func processJWT(
    jwt: String,
    userSalt: String,
    ephemeralKeyPair: Account,
    maxEpoch: UInt64,
    randomness: [UInt8],
    proofService: any ZkProofService
  ) async throws -> zkLoginSignature {
    let proof = try await proofService.generateProof(
      jwt: jwt,
      userSalt: userSalt,
      ephemeralPublicKey: try ephemeralKeyPair.publicKey.toSuiBytes().bytes,
      maxEpoch: maxEpoch,
      jwtRandomness: randomness
    )

    return try buildSignature(
      jwt: jwt,
      userSalt: userSalt,
      maxEpoch: maxEpoch,
      proof: proof
    )
  }

  /// Bridge-friendly JWT processing with a concrete proof service.
  public func processJWT(
    jwt: String,
    userSalt: String,
    ephemeralKeyPair: Account,
    maxEpoch: UInt64,
    randomness: [UInt8],
    remoteProofService: RemoteZkProofService
  ) async throws -> zkLoginSignature {
    let proof = try await remoteProofService.generateProof(
      jwt: jwt,
      userSalt: userSalt,
      ephemeralPublicKey: try ephemeralKeyPair.publicKey.toSuiBytes().bytes,
      maxEpoch: maxEpoch,
      jwtRandomness: randomness
    )

    return try buildSignature(
      jwt: jwt,
      userSalt: userSalt,
      maxEpoch: maxEpoch,
      proof: proof
    )
  }

  private func buildSignature(
    jwt: String,
    userSalt: String,
    maxEpoch: UInt64,
    proof: ZkProof
  ) throws -> zkLoginSignature {
    let jwtClaims = try JWTUtilities.extractClaims(from: jwt)

    _ = try zkLoginUtilities.generateAddressSeed(
      salt: userSalt,
      keyClaimName: "sub",
      keyClaimValue: jwtClaims.sub ?? "",
      audience: jwtClaims.audienceString() ?? ""
    )

    let inputs = zkLoginSignatureInputs(
      proofPoints: proof.proofPoints,
      issBase64Details: proof.issBase64Details,
      headerBase64: proof.headerBase64,
      addressSeed: ""
    )

    return zkLoginSignature(
      inputs: inputs,
      maxEpoch: maxEpoch,
      userSignature: SuiData([])
    )
  }

  /// Get the zkLogin address for a user
  /// - Parameters:
  ///   - jwt: The JWT token
  ///   - userSalt: The user's salt
  /// - Returns: The zkLogin Sui address
  public func derivezkLoginAddress(jwt: String, userSalt: String) throws -> String {
    let jwtClaims = try JWTUtilities.extractClaims(from: jwt)

    return try zkLoginPublicKey.deriveAddress(
      keyClaimName: "sub",
      keyClaimValue: jwtClaims.sub ?? "",
      issuer: jwtClaims.iss ?? "",
      audience: jwtClaims.audienceString() ?? "",
      userSalt: userSalt
    )
  }

  /// Create a signer that can sign transactions with zkLogin (legacy version)
  /// - Parameters:
  ///   - ephemeralKeyPair: The ephemeral keypair used for signing
  ///   - zkLoginSignature: The zkLogin signature
  ///   - userAddress: The user's zkLogin address
  /// - Returns: A ZkLoginSigner
  public func createSigner(
    ephemeralKeyPair: Account,
    zkLoginSignature: zkLoginSignature,
    userAddress: String,
    graphQLClient: SuiGraphQLClient
  ) -> ZkLoginSigner {
    return ZkLoginSigner(
      provider: provider,
      ephemeralKeyPair: ephemeralKeyPair,
      zkLoginSignature: zkLoginSignature,
      userAddress: userAddress,
      graphQLClient: graphQLClient
    )
  }

  /// Create a comprehensive zkLogin signer with verification capabilities
  /// - Parameters:
  ///   - ephemeralKeyPair: The ephemeral keypair used for signing
  ///   - zkLoginSignature: The zkLogin signature
  ///   - userAddress: The user's zkLogin address
  ///   - graphQLClient: Optional GraphQL client for signature verification
  /// - Returns: A zkLoginSigner with enhanced capabilities
  public func createzkLoginSigner(
    ephemeralKeyPair: Account,
    zkLoginSignature: zkLoginSignature,
    userAddress: String,
    graphQLClient: SuiGraphQLClient
  ) -> ZkLoginSigner {
    return ZkLoginSigner(
      provider: provider,
      ephemeralKeyPair: ephemeralKeyPair,
      zkLoginSignature: zkLoginSignature,
      userAddress: userAddress,
      graphQLClient: graphQLClient
    )
  }
}
