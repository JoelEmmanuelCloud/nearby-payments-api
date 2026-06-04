//
//  Signature.swift
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

import Foundation
import LeanSuiBCS

/// Represents a cryptographic signature.
public struct Signature: Equatable, SuiBCSBridged {
  /// A constant defining the length of the signature in bytes.
  public let LENGTH: Int

  /// The actual cryptographic signature.
  public var signature: Data

  /// The public key associated with the signature.
  public var publicKey: Data

  /// The signature scheme used for creating the signature.
  public var signatureScheme: SignatureScheme

  /// Initializes a new `Signature`.
  public init(signature: Data, publickey: Data, signatureScheme: SignatureScheme = .zkLogin) {
    self.signature = signature
    self.publicKey = publickey
    self.signatureScheme = signatureScheme
    self.LENGTH = 64
  }

  public static func == (lhs: Signature, rhs: Signature) -> Bool {
    return lhs.signature == rhs.signature
  }

  /// Converts the signature to a hexadecimal string.
  public func hex() throws -> String {
    return try self.data().hexEncodedString()
  }

  /// Converts the signature to `Data`.
  public func data() throws -> Data {
    return self.signature
  }

  public static func deserialize(from deserializer: Deserializer) throws -> Signature {
    let signatureBytes = try Deserializer.toBytes(deserializer)

    if signatureBytes.count != 64 {
      throw AccountError.lengthMismatch
    }

    guard let stringSignature = String(data: signatureBytes, encoding: .utf8) else {
      throw AccountError.failedData
    }

    guard let bytes = Data.fromBase64(stringSignature) else { throw AccountError.invalidData }

    let schemeStr = SignatureSchemeFlags.SIGNATURE_FLAG_TO_SCHEME[bytes[0]]
    guard schemeStr == "zkLogin" else {
      throw AccountError.cannotBeDeserialized
    }

    return Signature(
      signature: bytes.subdata(in: 1..<bytes.count),
      publickey: Data(),
      signatureScheme: .zkLogin
    )
  }

  public func serialize(_ serializer: Serializer) throws {
    var serializedSignature = Data(capacity: 1 + signature.count + publicKey.count)

    guard
      let signatureFlag = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG[signatureScheme.rawValue]
    else {
      throw AccountError.cannotBeSerialized
    }

    serializedSignature.append(signatureFlag)
    serializedSignature.append(contentsOf: self.signature)
    serializedSignature.append(contentsOf: self.publicKey)

    try Serializer.str(serializer, serializedSignature.base64EncodedString())
  }
}
