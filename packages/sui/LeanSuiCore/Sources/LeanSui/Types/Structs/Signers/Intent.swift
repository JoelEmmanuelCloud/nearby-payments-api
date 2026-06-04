//
//  Intent.swift
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

public typealias Intent = (IntentScope, IntentVersion, AppId)

public enum IntentHelper {
  public static func intentWithScope(_ scope: IntentScope) -> Intent {
    return (scope, .V0, .Sui)
  }

  public static func intentData(_ intent: Intent) -> [UInt8] {
    return [
      UInt8(intent.0.rawValue),
      UInt8(intent.1.rawValue),
      UInt8(intent.2.rawValue),
    ]
  }

  public static func messageWithIntent(_ scope: IntentScope, _ message: Data) -> Data {
    let intent = intentWithScope(scope)
    let intentData = intentData(intent)
    var intentMessage = Data(capacity: intentData.count + message.count)
    intentMessage.append(Data(intentData))
    intentMessage.append(message)
    return intentMessage
  }

  public static func toSerializedSignature(
    _ signature: Signature,
    _ signatureScheme: KeyType,
    _ pubKey: String
  ) throws -> String {
    guard let pubKeyData = Data(base64Encoded: pubKey) else {
      throw SuiError.customError(message: "Failed data")
    }
    guard
      let encryptionType = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG[signatureScheme.rawValue]
    else {
      throw SuiError.customError(
        message: "Cannot find signature type for \(signatureScheme.rawValue)")
    }
    var serializedSignature = Data(count: signature.signature.count + pubKeyData.count)
    serializedSignature[0] = encryptionType
    serializedSignature[1..<signature.signature.count] = signature.signature
    serializedSignature[
      1 + signature.signature.count..<1 + signature.signature.count + pubKeyData.count] = pubKeyData

    return serializedSignature.base64EncodedString()
  }
}
