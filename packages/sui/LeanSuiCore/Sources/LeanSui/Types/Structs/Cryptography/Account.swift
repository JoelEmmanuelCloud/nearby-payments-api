//
//  Account.swift
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

import Crypto
import Foundation
import LeanSuiBCS

/// Sui Blockchain Account
public struct Account: Equatable, Hashable, Sendable {
  /// Represents the type of cryptographic key associated with the account.
  public let accountType: KeyType

  /// Represents the public key associated with the account.
  public let publicKey: any PublicKeyProtocol

  /// Represents the private key associated with the account.
  private let privateKey: any PrivateKeyProtocol

  /// Creates an account with the given key type.
  ///
  /// - Parameter accountType: The type of cryptographic key to be used. Defaults to `.ed25519`.
  /// - Throws: An error if the account initialization fails.
  public init(accountType: KeyType = .ed25519, hasBiometrics: Bool = false) throws {
    switch accountType {
    case .ed25519:
      let privateKey = ED25519PrivateKey()
      try self.init(privateKey: privateKey, accountType: accountType)
    }
  }

  /// Creates an account with the given private key and key type.
  ///
  /// - Parameters:
  ///   - privateKey: The private key data.
  ///   - accountType: The type of cryptographic key to be used. Defaults to `.ed25519`.
  /// - Throws: An error if the account initialization fails.
  public init(
    privateKey: Data,
    accountType: KeyType = .ed25519
  ) throws {
    switch accountType {
    case .ed25519:
      let privateKey = try ED25519PrivateKey(key: privateKey)
      try self.init(privateKey: privateKey, accountType: accountType)
    }
  }

  /// Creates an account with the given public key, private key, and key type.
  ///
  /// - Parameters:
  ///   - publicKey: The public key protocol.
  ///   - privateKey: The private key protocol.
  ///   - accountType: The type of cryptographic key to be used. Defaults to `.ed25519`.
  init(  // internal: `any PublicKeyProtocol/PrivateKeyProtocol` existentials don't bridge; Ed25519 path uses init(privateKey: Data:)
    publicKey: any PublicKeyProtocol,
    privateKey: any PrivateKeyProtocol,
    accountType: KeyType = .ed25519
  ) {
    self.publicKey = publicKey
    self.privateKey = privateKey
    self.accountType = accountType
  }

  /// Creates an account with the given private key protocol and key type.
  ///
  /// - Parameters:
  ///   - privateKey: The private key protocol.
  ///   - accountType: The type of cryptographic key to be used. Defaults to `.ed25519`.
  /// - Throws: An error if the public key initialization fails.
  init(  // internal: `any PublicKeyProtocol/PrivateKeyProtocol` existentials don't bridge; Ed25519 path uses init(privateKey: Data:)
    privateKey: any PrivateKeyProtocol,
    accountType: KeyType = .ed25519
  ) throws {
    self.privateKey = privateKey
    self.publicKey = try privateKey.publicKey()
    self.accountType = accountType
  }

  /// Creates an account with the given key type and hexadecimal string representation of the private key.
  ///
  /// - Parameters:
  ///   - keyType: The type of cryptographic key to be used. Defaults to `.ed25519`.
  ///   - hexString: The hexadecimal string representation of the private key.
  /// - Throws: An error if the account initialization fails.
  public init(
    keyType: KeyType = .ed25519,
    hexString: String
  ) throws {
    switch keyType {
    case .ed25519:
      let privateKey = ED25519PrivateKey(hexString: hexString)
      self.privateKey = privateKey
      self.publicKey = try privateKey.publicKey()
      self.accountType = keyType
    }
  }

  /// Creates an account from the JSON representation of the private key stored at the given file path.
  ///
  /// - Parameters:
  ///   - keyType: The type of cryptographic key to be used. Defaults to `.ed25519`.
  ///   - path: The file path to the JSON representation of the private key.
  /// - Throws: `SuiError.invalidJsonData` if the data is not a valid JSON,
  ///           or `SuiError.missingPrivateKey` if the private key is missing in the JSON data.
  public init(keyType: KeyType = .ed25519, path: String) throws {
    let fileURL = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: fileURL)
    guard
      let json = try JSONSerialization
        .jsonObject(with: data, options: []) as? [String: Any]
    else {
      throw SuiError.customError(message: "Invalid JSON data")
    }

    guard let privateKeyHex = json["private_key"] as? String else {
      throw SuiError.customError(message: "Missing Private Key")
    }

    try self.init(
      keyType: keyType,
      hexString: privateKeyHex
    )
  }

  /// Creates an account with the given value and key type.
  ///
  /// - Parameters:
  ///   - accountType: The type of cryptographic key to be used. Defaults to `.ed25519`.
  ///   - value: A string value representing the private key.
  /// - Throws: An error if the account initialization fails.
  public init(accountType: KeyType = .ed25519, _ value: String) throws {
    self.accountType = accountType

    switch accountType {
    case .ed25519:
      let privateKey = try ED25519PrivateKey(value: value)
      self.privateKey = privateKey
      self.publicKey = try privateKey.publicKey()
    }
  }

  public static func == (lhs: Account, rhs: Account) -> Bool {
    return lhs.privateKey.base64() == rhs.privateKey.base64()
      && lhs.publicKey.base64() == rhs.publicKey.base64()
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.privateKey.base64())
    hasher.combine(self.publicKey.base64())
  }

  /// Store the account information to a file at the given path.
  ///
  /// - Parameters:
  ///    - path: A string representing the file path to store the account information.
  ///
  /// - Throws: An error of type SuiError if there is an issue writing to the file.
  public func store(_ path: String) throws {
    let data: [String: String] = [
      "account_address": self.publicKey.hex(),
      "private_key": self.privateKey.hex(),
    ]

    let fileURL = URL(fileURLWithPath: path)
    let jsonData =
      try JSONSerialization
      .data(withJSONObject: data, options: [])

    try jsonData.write(to: fileURL)
  }

  /// Returns the account's account address.
  /// - Returns: An AccountAddress object
  public func address() throws -> String {
    return try self.publicKey.toSuiAddress()
  }

  /// Use the private key to sign the data inputted.
  /// - Parameter data: The data being serialized / signed
  /// - Returns: A Signature object
  public func sign(_ data: Data) throws -> Signature {
    return try self.privateKey.sign(data: data)
  }

  /// Verifies the given signature with the given data using the public key.
  ///
  /// - Parameters:
  ///   - data: The data that was signed.
  ///   - signature: The signature to verify.
  /// - Returns: A boolean value indicating whether the signature is valid.
  /// - Throws: An error if the verification process fails.
  public func verify(
    _ data: Data,
    _ signature: Signature
  ) throws -> Bool {
    return try self.publicKey.verify(
      data: data,
      signature: signature
    )
  }

  /// Signs the given bytes with a specified intent using the private key.
  ///
  /// - Parameters:
  ///   - bytes: The data to sign.
  ///   - intent: The intent scope of the signing.
  /// - Returns: The resulting signature.
  /// - Throws: An error if the signing process fails.
  public func signWithIntent(
    _ bytes: [UInt8],
    _ intent: IntentScope
  ) throws -> Signature {
    return try self.privateKey.signWithIntent(bytes, intent)
  }

  /// Signs the transaction block using the private key.
  ///
  /// - Parameters:
  ///   - bytes: The transaction block to sign.
  /// - Returns: The resulting signature.
  /// - Throws: An error if the signing process fails.
  public func signTransactionBlock(
    _ bytes: [UInt8]
  ) throws -> Signature {
    return try self.privateKey.signTransactionBlock(bytes)
  }

  /// Signs a personal message using the private key.
  ///
  /// - Parameters:
  ///   - bytes: The personal message to sign.
  /// - Returns: The resulting signature.
  /// - Throws: An error if the signing process fails.
  public func signPersonalMessage(
    _ bytes: [UInt8]
  ) throws -> Signature {
    return try self.privateKey.signPersonalMessage(bytes)
  }

  /// Verifies the signature of a transaction block using the public key.
  ///
  /// - Parameters:
  ///   - transactionBlock: The transaction block that was signed.
  ///   - signature: The signature to verify.
  /// - Returns: A boolean value indicating whether the signature is valid.
  /// - Throws: An error if the verification process fails.
  public func verifyTransactionBlock(
    _ transactionBlock: [UInt8],
    _ signature: Signature
  ) throws -> Bool {
    return try self.publicKey.verifyTransactionBlock(
      transactionBlock, signature
    )
  }

  /// Verifies the signature of the given bytes with a specified intent using the public key.
  ///
  /// - Parameters:
  ///   - bytes: The data that was signed.
  ///   - signature: The signature to verify.
  ///   - intent: The intent scope of the verification.
  /// - Returns: A boolean value indicating whether the signature is valid.
  /// - Throws: An error if the verification process fails.
  public func verifyWithIntent(
    _ bytes: [UInt8],
    _ signature: Signature,
    _ intent: IntentScope
  ) throws -> Bool {
    return try self.publicKey.verifyWithIntent(
      bytes,
      signature,
      intent
    )
  }

  /// Verifies the signature of a personal message using the public key.
  ///
  /// - Parameters:
  ///   - message: The personal message that was signed.
  ///   - signature: The signature to verify.
  /// - Returns: A boolean value indicating whether the signature is valid.
  /// - Throws: An error if the verification process fails.
  public func verifyPersonalMessage(
    _ message: [UInt8],
    _ signature: Signature
  ) throws -> Bool {
    return try self.publicKey.verifyPersonalMessage(
      message,
      signature
    )
  }

  /// Serializes the given signature to a string.
  ///
  /// - Parameter signature: The signature to serialize.
  /// - Returns: The serialized signature as a string.
  /// - Throws: An error if the serialization process fails.
  public func toSerializedSignature(_ signature: Signature) throws -> String {
    return try self.publicKey.toSerializedSignature(
      signature: signature
    )
  }

  /// Exports the account to an `ExportedAccount` representation.
  ///
  /// - Returns: The exported account representation.
  /// - Throws: `AccountError.cannotBeExported` if the account's private key type is unsupported for export.
  public func export() throws -> ExportedAccount {
    return ExportedAccount(
      schema: self.accountType,
      privateKey: (privateKey.key as! Data).base64EncodedString()
    )
  }
}
