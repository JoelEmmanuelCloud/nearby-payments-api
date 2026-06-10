//
//  HSMPrivateKey.swift
//  LeanSui
//

import Crypto
import Foundation
import HSM
import LeanSuiBCS

/// A private key facade that delegates signing to a platform HSM.
public struct HSMPrivateKey: PrivateKeyProtocol {
  public typealias DataValue = SuiData
  public typealias PublicKeyType = HSMPublicKey

  private let signer: HSMSignerBox
  public let key: DataValue

  public init(hsm: any HardwareSecurityModule) throws {
    let publicKey = try hsm.getPublicKey() ?? hsm.generateKey()
    let publicKeyData = HSMKeyUtilities.data(from: publicKey)

    self.signer = HSMSignerBox(hsm)
    self.key = try HSMPublicKey(derData: publicKeyData.suiData).key
  }

  public static func == (lhs: HSMPrivateKey, rhs: HSMPrivateKey) -> Bool {
    return lhs.key == rhs.key
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.key)
  }

  public var description: String {
    return self.hex()
  }

  public func hex() -> String {
    return "0x\(self.key.data.hexEncodedString())"
  }

  public func base64() -> String {
    return self.key.data.base64EncodedString()
  }

  public func publicKey() throws -> PublicKeyType {
    return try HSMPublicKey(data: self.key)
  }

  public func sign(data: SuiData) throws -> Signature {
    let signatureItem = try signer.module.sign(HSMKeyUtilities.signedBytes(from: data.data))
    let derSignature = HSMKeyUtilities.data(from: signatureItem)
    let signature = try P256.Signing.ECDSASignature(derRepresentation: derSignature)

    return Signature(
      // Normalize to low-S — Sui rejects high-S secp256r1 signatures as malleable,
      // and the HSM does not guarantee low-S.
      signature: HSMKeyUtilities.normalizeLowS(signature.rawRepresentation).suiData,
      publickey: self.key,
      signatureScheme: .secp256r1
    )
  }

  public func signWithIntent(_ bytes: SuiData, _ intent: IntentScope) throws -> Signature {
    let intentMessage = IntentHelper.messageWithIntent(intent, bytes.data)
    let digest = try BLAKE2b.hash(data: intentMessage, digestLength: 32)
    return try self.sign(data: digest.suiData)
  }

  public func signTransactionBlock(_ bytes: SuiData) throws -> Signature {
    return try self.signWithIntent(bytes, .TransactionData)
  }

  public func signPersonalMessage(_ bytes: SuiData) throws -> Signature {
    let ser = Serializer()
    try ser.sequence(bytes.bytes, Serializer.u8)
    return try self.signWithIntent(ser.output(), .PersonalMessage)
  }

  public static func deserialize(from deserializer: Deserializer) throws -> HSMPrivateKey {
    _ = deserializer
    throw AccountError.cannotBeDeserialized
  }

  public func serialize(_ serializer: Serializer) throws {
    _ = serializer
    throw AccountError.cannotBeSerialized
  }
}
