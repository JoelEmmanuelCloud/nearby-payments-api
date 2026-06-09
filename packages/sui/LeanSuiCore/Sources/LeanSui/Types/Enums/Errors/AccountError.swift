//
//  AccountError.swift
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

/// `AccountError` represents a set of errors that can occur while dealing with accounts, keys, or cryptographic operations.
public enum AccountError: Error, Equatable {
  /// Indicates that the provided public key is invalid.
  case invalidPublicKey

  /// Indicates that there is a mismatch in the expected length for certain data.
  case lengthMismatch

  /// Indicates that the length of the provided data is invalid.
  case invalidLength

  /// Indicates that the provided signature is invalid.
  case invalidSignature

  /// Indicates that the serialized signature is invalid.
  case invalidSerializedSignature

  /// Indicates that the parsed signature is invalid.
  case invalidParsedSignature

  /// Indicates that the parsed public key is invalid.
  case invalidParsedPublicKey

  /// Indicates that the provided data is invalid.
  case invalidData

  /// Indicates that the provided context for the operation is invalid.
  case invalidContext

  /// Indicates that the public key could not be created.
  case invalidPubKeyCreation

  /// Indicates that the generated key is invalid.
  case invalidGeneratedKey

  /// Indicates that the provided derivation path is invalid.
  case invalidDerivationPath

  /// Indicates that the provided mnemonic seed is invalid.
  case invalidMnemonicSeed

  /// Indicates that the HD (Hierarchical Deterministic) node is invalid.
  case invalidHDNode

  /// Indicates that the hardened path provided is invalid.
  case invalidHardenedPath

  /// Indicates that the curve data is invalid.
  case invalidCurveData

  /// Indicates that the number of keys is out of the allowable range. Takes minimum and maximum allowed values as associated values.
  case keysCountOutOfRange(min: Int, max: Int)

  /// Indicates that the threshold value is out of the allowable range. Takes minimum and maximum allowed values as associated values.
  case thresholdOutOfRange(min: Int, max: Int)

  /// Indicates that there is no content present in the key.
  case noContentInKey

  /// Indicates that the operation failed due to some unspecified data issue.
  case failedData

  /// Indicates that the data cannot be deserialized.
  case cannotBeDeserialized

  /// Indicates that the data cannot be serialized.
  case cannotBeSerialized

  /// Indicates that the data or key cannot be exported.
  case cannotBeExported

  /// This error is thrown if, by using CryptoKit, initializing the P256 Key throws an error.
  /// Check the key to make sure it's valid.
  case cannotCreateP256Key

  case incompatibleOS

  case keychainReadFail(message: String)
}

extension AccountError {
  /// Stable, globally-unique, machine-readable code for each case (the case kind, not its payload).
  public enum Code: String, Sendable, CaseIterable {
    case invalidPublicKey = "account.invalid_public_key"
    case lengthMismatch = "account.length_mismatch"
    case invalidLength = "account.invalid_length"
    case invalidSignature = "account.invalid_signature"
    case invalidSerializedSignature = "account.invalid_serialized_signature"
    case invalidParsedSignature = "account.invalid_parsed_signature"
    case invalidParsedPublicKey = "account.invalid_parsed_public_key"
    case invalidData = "account.invalid_data"
    case invalidContext = "account.invalid_context"
    case invalidPubKeyCreation = "account.invalid_pub_key_creation"
    case invalidGeneratedKey = "account.invalid_generated_key"
    case invalidDerivationPath = "account.invalid_derivation_path"
    case invalidMnemonicSeed = "account.invalid_mnemonic_seed"
    case invalidHDNode = "account.invalid_hd_node"
    case invalidHardenedPath = "account.invalid_hardened_path"
    case invalidCurveData = "account.invalid_curve_data"
    case keysCountOutOfRange = "account.keys_count_out_of_range"
    case thresholdOutOfRange = "account.threshold_out_of_range"
    case noContentInKey = "account.no_content_in_key"
    case failedData = "account.failed_data"
    case cannotBeDeserialized = "account.cannot_be_deserialized"
    case cannotBeSerialized = "account.cannot_be_serialized"
    case cannotBeExported = "account.cannot_be_exported"
    case cannotCreateP256Key = "account.cannot_create_p256_key"
    case incompatibleOS = "account.incompatible_os"
    case keychainReadFail = "account.keychain_read_fail"
  }

  /// The stable code identifying this error's kind.
  public var code: Code {
    switch self {
    case .invalidPublicKey: .invalidPublicKey
    case .lengthMismatch: .lengthMismatch
    case .invalidLength: .invalidLength
    case .invalidSignature: .invalidSignature
    case .invalidSerializedSignature: .invalidSerializedSignature
    case .invalidParsedSignature: .invalidParsedSignature
    case .invalidParsedPublicKey: .invalidParsedPublicKey
    case .invalidData: .invalidData
    case .invalidContext: .invalidContext
    case .invalidPubKeyCreation: .invalidPubKeyCreation
    case .invalidGeneratedKey: .invalidGeneratedKey
    case .invalidDerivationPath: .invalidDerivationPath
    case .invalidMnemonicSeed: .invalidMnemonicSeed
    case .invalidHDNode: .invalidHDNode
    case .invalidHardenedPath: .invalidHardenedPath
    case .invalidCurveData: .invalidCurveData
    case .keysCountOutOfRange: .keysCountOutOfRange
    case .thresholdOutOfRange: .thresholdOutOfRange
    case .noContentInKey: .noContentInKey
    case .failedData: .failedData
    case .cannotBeDeserialized: .cannotBeDeserialized
    case .cannotBeSerialized: .cannotBeSerialized
    case .cannotBeExported: .cannotBeExported
    case .cannotCreateP256Key: .cannotCreateP256Key
    case .incompatibleOS: .incompatibleOS
    case .keychainReadFail: .keychainReadFail
    }
  }
}

extension AccountError: CustomStringConvertible {
  /// String form is the `code` raw value, so the exact code survives the swift-java bridge.
  public var description: String { code.rawValue }
}
