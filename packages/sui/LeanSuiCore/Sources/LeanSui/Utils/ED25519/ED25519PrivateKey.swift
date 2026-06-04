//
//  ED25519PrivateKey.swift
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

/// Represents an ED25519 private key and provides functionality for signing and path derivation.
public struct ED25519PrivateKey: Equatable, PrivateKeyProtocol {
  public typealias DataValue = Data
  public typealias PublicKeyType = ED25519PublicKey

  /// Length of the private key.
  public static let LENGTH: Int = 32

  public var key: DataValue

  public init(key: Data) throws {
    guard key.count == Self.LENGTH else {
      throw AccountError.invalidLength
    }
    self.key = key
  }

  public init(hexString: String) {
    var hexValue = hexString
    if hexString.hasPrefix("0x") {
      hexValue = String(hexString.dropFirst(2))
    }
    self.key = Data(hex: hexValue)
  }

  public init() {
    let privateKey = Crypto.Curve25519.Signing.PrivateKey()
    self.key = privateKey.rawRepresentation
  }

  public init(value: String) throws {
    guard let data = Data.fromBase64(value) else { throw AccountError.invalidData }
    self.key = data
  }

  public static func == (lhs: ED25519PrivateKey, rhs: ED25519PrivateKey) -> Bool {
    return lhs.key == rhs.key
  }

  public var description: String {
    return self.hex()
  }

  public func hex() -> String {
    return "0x\(self.key.hexEncodedString())"
  }

  public func base64() -> String {
    return self.key.base64EncodedString()
  }

  public func publicKey() throws -> PublicKeyType {
    let privateKey = try Crypto.Curve25519.Signing.PrivateKey(rawRepresentation: self.key)
    return try ED25519PublicKey(data: privateKey.publicKey.rawRepresentation)
  }

  public func sign(data: Data) throws -> Signature {
    let privateKey = try Crypto.Curve25519.Signing.PrivateKey(rawRepresentation: self.key)
    let signedMessage = try privateKey.signature(for: data)
    return Signature(
      signature: Data(signedMessage),
      publickey: try self.publicKey().key,
      signatureScheme: .zkLogin
    )
  }

  public func signWithIntent(_ bytes: [UInt8], _ intent: IntentScope) throws -> Signature {
    let intentMessage = IntentHelper.messageWithIntent(intent, Data(bytes))
    let digest = try BLAKE2b.hash(data: intentMessage, digestLength: 32)

    let signature = try self.sign(data: digest)
    return signature
  }

  public func signTransactionBlock(_ bytes: [UInt8]) throws -> Signature {
    return try self.signWithIntent(bytes, .TransactionData)
  }

  public func signPersonalMessage(_ bytes: [UInt8]) throws -> Signature {
    let ser = Serializer()
    try ser.sequence(bytes, Serializer.u8)
    return try self.signWithIntent([UInt8](ser.output()), .PersonalMessage)
  }

  public static func deserialize(from deserializer: Deserializer) throws -> ED25519PrivateKey {
    let key = try Deserializer.toBytes(deserializer)
    if key.count != ED25519PrivateKey.LENGTH {
      throw AccountError.lengthMismatch
    }
    return try ED25519PrivateKey(key: key)
  }

  public func serialize(_ serializer: Serializer) throws {
    try Serializer.toBytes(serializer, self.key)
  }
}
