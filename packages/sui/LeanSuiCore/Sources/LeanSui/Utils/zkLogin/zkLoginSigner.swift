//
//  ZkLoginAuthenticator.swift
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
import LeanSuiApi
import LeanSuiBCS

/// A comprehensive zkLogin signer that can sign transactions and personal messages
public class ZkLoginSigner {
  /// The Sui provider for network operations
  private let provider: GraphQLSuiProvider

  /// The ephemeral keypair used for signing
  private let ephemeralKeyPair: Account

  /// The zkLogin signature structure (contains proof, metadata, but not user signature until signing)
  private var zkLoginSignatureTemplate: zkLoginSignature

  /// The user's zkLogin address
  private let userAddress: String

  /// Optional GraphQL client for signature verification
  private let graphQLClient: SuiGraphQLClient?

  /// Initialize a new ZkLoginSigner.
  /// - Parameters:
  ///   - provider: The Sui provider for network operations
  ///   - ephemeralKeyPair: The ephemeral keypair used for signing
  ///   - zkLoginSignature: The zkLogin signature structure template
  ///   - userAddress: The user's zkLogin address
  ///   - graphQLClient: Optional GraphQL client for signature verification
  public init(
    provider: GraphQLSuiProvider,
    ephemeralKeyPair: Account,
    zkLoginSignature: zkLoginSignature,
    userAddress: String,
    graphQLClient: SuiGraphQLClient
  ) {
    self.provider = provider
    self.ephemeralKeyPair = ephemeralKeyPair
    self.zkLoginSignatureTemplate = zkLoginSignature
    self.userAddress = userAddress
    self.graphQLClient = graphQLClient
  }

  /// Get the zkLogin address for this signer
  /// - Returns: The Sui address string
  public func getAddress() -> String {
    return userAddress
  }

  /// Create a zkLogin public identifier for verification purposes
  /// - Returns: A zkLoginPublicIdentifier for signature verification
  public func getPublicKey() throws -> zkLoginPublicIdentifier {
    // Extract issuer from the signature template
    let issClaimJWT = zkLoginSignatureInputsClaim(
      value: zkLoginSignatureTemplate.inputs.issBase64Details.value,
      indexMod4: zkLoginSignatureTemplate.inputs.issBase64Details.indexMod4
    )
    let iss = try JWTUtilities.extractClaimValue(claim: issClaimJWT, claimName: "iss") as String

    return try zkLoginPublicIdentifier(
      addressSeed: BigInt(zkLoginSignatureTemplate.inputs.addressSeed)!,
      iss: iss,
      client: graphQLClient
    )
  }

  /// Sign raw bytes with the ephemeral keypair and create a complete zkLogin signature
  /// - Parameter bytes: The bytes to sign
  /// - Returns: A complete zkLogin signature
  private func signBytes(_ bytes: SuiData) throws -> zkLoginSignature {
    // Sign with the ephemeral keypair
    let ephemeralSignature = try ephemeralKeyPair.sign(bytes)

    // Create a complete zkLogin signature with the user signature
    var completeSignature = zkLoginSignatureTemplate
    completeSignature.userSignature = ephemeralSignature.signature

    return completeSignature
  }

  /// Sign a transaction block and return the serialized signature
  /// - Parameter transactionData: The transaction data bytes to sign
  /// - Returns: A serialized zkLogin signature string
  public func signTransaction(_ transactionData: SuiData) throws -> String {
    let signature = try signBytes(transactionData)
    return try signature.getSignature()
  }

  /// Sign a personal message and return the serialized signature
  /// - Parameter message: The message bytes to sign
  /// - Returns: A serialized zkLogin signature string
  public func signPersonalMessage(_ message: SuiData) throws -> String {
    // For personal messages, we need to add the personal message prefix
    let messageWithPrefix = IntentHelper.messageWithIntent(.PersonalMessage, message.data)
    let signature = try signBytes(messageWithPrefix.suiData)
    return try signature.getSignature()
  }

  /// Sign and execute a transaction using zkLogin authentication
  /// - Parameters:
  ///   - transactionBlock: The transaction to execute
  ///   - options: Optional execution parameters
  /// - Returns: The transaction execution response
  public func signAndExecuteTransaction(
    transactionBlock: TransactionBlock,
    options: GraphQLSuiProvider.TransactionResponseOptions = .init()
  ) async throws -> SuiTransactionBlockResponse {
    // Ensure the transaction has the zkLogin user address as sender
    try transactionBlock.setSender(sender: userAddress)

    // Build the transaction
    let bytes = try await transactionBlock.build(self.provider)

    // Sign the transaction data with our zkLogin signer
    let serializedSignature = try signTransaction(bytes)

    // Execute the transaction with the zkLogin signature. The GraphQL
    // `executeTransaction` mutation waits for finality, so no separate
    // `waitForTransaction` poll is required.
    return try await provider.executeTransactionBlock(
      txBytes: bytes.bytes,
      signatures: [serializedSignature],
      options: options
    )
  }

  public func executeTransaction(
    transactionBlock: SuiData,
    options: GraphQLSuiProvider.TransactionResponseOptions = .init()
  ) async throws -> SuiTransactionBlockResponse {
    // Sign the transaction data with our zkLogin signer
    let serializedSignature = try signTransaction(transactionBlock)

    // Execute the transaction with the zkLogin signature.
    return try await provider.executeTransactionBlock(
      txBytes: transactionBlock.bytes,
      signatures: [serializedSignature],
      options: options
    )
  }

  /// Sign and execute a transaction block using zkLogin authentication
  /// - Parameters:
  ///   - transactionBlock: The transaction block to execute
  ///   - options: Optional execution parameters
  /// - Returns: The transaction execution response
  public func signAndExecuteTransactionBlock(
    transactionBlock: TransactionBlock,
    options: GraphQLSuiProvider.TransactionResponseOptions = .init()
  ) async throws -> SuiTransactionBlockResponse {
    return try await signAndExecuteTransaction(transactionBlock: transactionBlock, options: options)
  }

  /// Verify a zkLogin signature against transaction data
  /// - Parameters:
  ///   - transactionData: The transaction data bytes
  ///   - signature: The zkLogin signature to verify
  /// - Returns: True if signature is valid, false otherwise
  public func verifyTransaction(
    transactionData: SuiData,
    signature: zkLoginSignature
  ) async throws -> Bool {
    guard self.graphQLClient != nil else {
      throw SuiError.customError(message: "GraphQL client required for verification")
    }

    let publicKey = try getPublicKey()
    return try await publicKey.verifyTransaction(
      transactionData: transactionData,
      signature: signature
    )
  }

  /// Verify a zkLogin signature against a personal message
  /// - Parameters:
  ///   - message: The message bytes
  ///   - signature: The zkLogin signature to verify
  /// - Returns: True if signature is valid, false otherwise
  public func verifyPersonalMessage(
    message: SuiData,
    signature: zkLoginSignature
  ) async throws -> Bool {
    guard self.graphQLClient != nil else {
      throw SuiError.customError(message: "GraphQL client required for verification")
    }

    let publicKey = try getPublicKey()
    return try await publicKey.verifyPersonalMessage(
      message: message,
      signature: signature
    )
  }
}

/// Utility methods for zkLogin signature operations
extension ZkLoginAuthenticator {
  /// Parse a serialized zkLogin signature string
  /// - Parameter serialized: The base64 encoded signature string
  /// - Returns: A parsed zkLogin signature
  public static func parseSignature(_ serialized: String) throws -> zkLoginSignature {
    return try zkLoginSignature.parse(serialized: serialized)
  }

  /// Serialize a zkLogin signature to a string
  /// - Parameter signature: The zkLogin signature
  /// - Returns: A base64 encoded signature string
  public static func serializeSignature(_ signature: zkLoginSignature) throws -> String {
    return try signature.getSignature()
  }

  /// Parse a serialized zkLogin signature and extract the public key
  /// - Parameters:
  ///   - serializedSignature: The serialized signature string
  ///   - graphQLClient: Optional GraphQL client for verification
  /// - Returns: A tuple containing the public key and signature
  public static func parseSerializedZkLoginSignature(
    _ serializedSignature: String,
    graphQLClient: SuiGraphQLClient
  ) throws -> (publicKey: zkLoginPublicIdentifier, signature: zkLoginSignature) {
    let signature = try parseSignature(serializedSignature)

    // Extract issuer from signature
    let issClaimJWT = zkLoginSignatureInputsClaim(
      value: signature.inputs.issBase64Details.value,
      indexMod4: signature.inputs.issBase64Details.indexMod4
    )
    let iss = try JWTUtilities.extractClaimValue(claim: issClaimJWT, claimName: "iss") as String

    let publicKey = try zkLoginPublicIdentifier(
      addressSeed: BigInt(signature.inputs.addressSeed)!,
      iss: iss,
      client: graphQLClient
    )

    return (publicKey: publicKey, signature: signature)
  }
}
