//
//  WritePathProtocols.swift
//  LeanSuiApi
//
//  The provider's write path (devInspect / dryRun / signAndExecute) needs to
//  talk to a transaction builder and a signer that live in the *core* package
//  (where BCS + key material live). To avoid a dependency cycle, this package
//  owns thin protocols describing only what the provider calls. The concrete
//  `TransactionBlock`, `Account`, etc. in the core package declare conformance.
//

import Foundation

/// A public key that can produce its on-chain Sui address.
public protocol SuiPublicKeyProtocol {
  /// 32-byte hex address with leading `0x`.
  func toSuiAddress() throws -> String
}

/// A signer (account) able to sign transaction bytes.
public protocol SuiSignerProtocol {
  /// The signer's public key.
  var signerPublicKey: any SuiPublicKeyProtocol { get }

  /// The signer's Sui address (`0x`-prefixed hex).
  func address() throws -> String

  /// Sign BCS-serialized `TransactionData` bytes and return the serialized
  /// signature (`flag || signature || pubkey`, base-64 encoded) ready for
  /// submission to `executeTransactionBlock`.
  func signTransactionBlock(_ bytes: [UInt8]) throws -> String
}

/// A transaction builder the provider can drive during the write path.
///
/// Implemented by the core package's `TransactionBlock`. `build` receives the
/// provider so the builder can resolve gas price / object refs via read calls.
///
/// This is a **class-bound** protocol: the builder is a reference type, so the
/// provider mutates it through the reference rather than via `inout`. (An
/// `inout some Protocol` parameter cannot be bridged to Java by swift-java,
/// because Java has no pass-by-reference for arbitrary objects; a class
/// reference bridges cleanly.) The concrete `TransactionBlock` in the core
/// package must therefore be a `class`.
public protocol TransactionBlockProtocol: AnyObject {
  /// Set the sender if one hasn't been set already.
  func setSenderIfNotSet(sender: String) throws

  /// Build and BCS-serialize the transaction.
  /// - Parameters:
  ///   - provider: The provider, for any read calls the builder needs.
  ///   - onlyTransactionKind: When `true`, serialize only the
  ///     `TransactionKind` (for dev-inspect) rather than full `TransactionData`.
  /// - Returns: BCS-serialized bytes.
  func build(
    provider: GraphQLSuiProvider,
    onlyTransactionKind: Bool
  ) async throws -> [UInt8]
}
