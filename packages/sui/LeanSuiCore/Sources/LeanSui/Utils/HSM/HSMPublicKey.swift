//
//  HSMPublicKey.swift
//  LeanSui
//

import Crypto
import Foundation
import LeanSuiBCS

/// Represents a P-256 public key backed by a platform HSM private key.
public struct HSMPublicKey: Equatable, PublicKeyProtocol {
  public typealias DataValue = SuiData

  public static let compressedLength: Int = 33
  public static let signatureLength: Int = 64

  public var key: DataValue

  public init(derData: SuiData) throws {
    let publicKey = try P256.Signing.PublicKey(derRepresentation: derData.data)
    self.key = publicKey.compressedRepresentation.suiData
  }

  public init(data: SuiData) throws {
    guard data.count == Self.compressedLength else {
      throw AccountError.invalidPublicKey
    }

    _ = try P256.Signing.PublicKey(compressedRepresentation: data.data)
    self.key = data
  }

  public init(hexString: String) throws {
    var hexValue = hexString
    if hexString.hasPrefix("0x") {
      hexValue = String(hexString.dropFirst(2))
    }

    try self.init(data: Data(hex: hexValue).suiData)
  }

  public init(value: String) throws {
    guard let result = Data.fromBase64(value) else {
      throw AccountError.invalidData
    }

    try self.init(data: result.suiData)
  }

  public var description: String {
    return self.hex()
  }

  public func base64() -> String {
    return self.key.data.base64EncodedString()
  }

  public func hex() -> String {
    return "0x\(self.key.data.hexEncodedString())"
  }

  public func verify(data: SuiData, signature: Signature) throws -> Bool {
    guard signature.signature.count == Self.signatureLength else {
      throw AccountError.invalidSignature
    }

    let publicKey = try P256.Signing.PublicKey(compressedRepresentation: self.key.data)
    let signature = try P256.Signing.ECDSASignature(rawRepresentation: signature.signature.data)
    return publicKey.isValidSignature(signature, for: data.data)
  }

  public func toSuiAddress() throws -> String {
    let bytes = try self.toSuiBytes()
    let digest = try BLAKE2b.hash(data: bytes.data, digestLength: 32)
    return try Inputs.normalizeSuiAddress(
      value: String(digest.hexEncodedString().prefix(64))
    )
  }

  public func toSuiPublicKey() throws -> String {
    return try self.toSuiBytes().bytes.toBase64()
  }

  public func toSuiBytes() throws -> SuiData {
    guard
      let signatureFlag = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG[
        SignatureScheme.secp256r1.rawValue]
    else {
      throw AccountError.cannotBeSerialized
    }

    return SuiData([signatureFlag] + self.key.bytes)
  }

  public func toSerializedSignature(signature: Signature) throws -> String {
    guard
      let signatureFlag = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG[
        SignatureScheme.secp256r1.rawValue]
    else {
      throw AccountError.cannotBeSerialized
    }

    var serializedSignature = Data(capacity: 1 + signature.signature.count + self.key.count)
    serializedSignature.append(signatureFlag)
    serializedSignature.append(signature.signature.data)
    serializedSignature.append(self.key.data)

    return serializedSignature.base64EncodedString()
  }

  public func verifyTransactionBlock(_ transactionBlock: SuiData, _ signature: Signature) throws
    -> Bool
  {
    return try self.verifyWithIntent(transactionBlock, signature, .TransactionData)
  }

  public func verifyWithIntent(_ bytes: SuiData, _ signature: Signature, _ intent: IntentScope)
    throws -> Bool
  {
    let intentMessage = IntentHelper.messageWithIntent(intent, bytes.data)
    let digest = try BLAKE2b.hash(data: intentMessage, digestLength: 32)
    return try self.verify(data: digest.suiData, signature: signature)
  }

  public func verifyPersonalMessage(_ message: SuiData, _ signature: Signature) throws -> Bool {
    let ser = Serializer()
    try ser.sequence(message.bytes, Serializer.u8)
    return try self.verifyWithIntent(ser.output(), signature, .PersonalMessage)
  }

  public static func deserialize(from deserializer: Deserializer) throws -> HSMPublicKey {
    let key = try Deserializer.toBytes(deserializer)
    return try HSMPublicKey(data: key)
  }

  public func serialize(_ serializer: Serializer) throws {
    try Serializer.toBytes(serializer, self.key)
  }
}
