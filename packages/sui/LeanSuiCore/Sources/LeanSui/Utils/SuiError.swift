//
//  SuiError.swift
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

/// Error type for SuiKit errors.
public struct SuiError: Error, CustomStringConvertible {
  /// The error code.
  public let code: Code

  /// The underlying error, if any.
  public let underlyingError: Error?

  /// Creates a new error with the given code.
  /// - Parameter code: The error code.
  /// - Returns: A new SuiError instance.
  public static func error(code: Code) -> SuiError {
    SuiError(code: code)
  }

  /// Creates a new error with the given code and underlying error.
  /// - Parameters:
  ///   - code: The error code.
  ///   - error: The underlying error.
  /// - Returns: A new SuiError instance.
  public static func error(code: Code, error: Error) -> SuiError {
    SuiError(code: code, underlyingError: error)
  }

  /// Creates a custom error with the given message.
  /// - Parameter message: The error message.
  /// - Returns: A new SuiError instance.
  public static func customError(message: String) -> SuiError {
    SuiError(code: .customError(message: message))
  }

  /// Indicates that a feature or operation is not yet implemented.
  public static let notImplemented = SuiError(code: .notImplementedError)

  /// Human-readable detail. The `description` carries the stable `errorCode` for bridge identification.
  public var message: String {
    switch code {
    case .error(let message):
      return message
    case .notImplementedError:
      return "Not implemented"
    case .customError(let message):
      return message
    case .invalidTransaction:
      return "Invalid transaction"
    case .objectNotFound:
      return "Object not found"
    case .keyChainError:
      return "Keychain operation failed"
    case .missingKeyItem:
      return "Failed to retrieve key from keychain"
    case .dataEncodingFailed:
      return "Failed to encode data as string"
    case .saltMissing:
      return "Salt is missing"
    case .failedToGenerateRandomData:
      return "Failed to generate random data"
    case .missingProofService:
      return "No proof service has been configured"
    case .keychainOperationFailed:
      return "Keychain operation failed"
    case .unsupportedSignatureScheme:
      return "The signature scheme is not supported"
    case .proofServiceError:
      return "The proof service returned an error"
    case .invalidProofServiceResponse:
      return "The proof service returned an invalid response"
    case .missingGraphQLData:
      return "Missing GraphQL data"
    case .missingJWTClaim:
      return "Missing JWT claim in token"
    case .saltServiceError:
      return "Salt service returned an error"
    case .invalidSaltServiceResponse:
      return "Invalid response from salt service"
    }
  }

  /// String form is the stable `errorCode`, so the exact code survives the swift-java bridge
  /// (human-readable detail is available via `message`).
  public var description: String { errorCode }

  /// Stable, globally-unique, machine-readable code identifying this error's kind.
  public var errorCode: String {
    switch code {
    case .error: "sui.error"
    case .notImplementedError: "sui.not_implemented"
    case .customError: "sui.custom_error"
    case .invalidTransaction: "sui.invalid_transaction"
    case .objectNotFound: "sui.object_not_found"
    case .unsupportedSignatureScheme: "sui.unsupported_signature_scheme"
    case .saltMissing: "sui.salt_missing"
    case .failedToGenerateRandomData: "sui.failed_to_generate_random_data"
    case .missingProofService: "sui.missing_proof_service"
    case .missingKeyItem: "sui.missing_key_item"
    case .dataEncodingFailed: "sui.data_encoding_failed"
    case .keyChainError: "sui.keychain_error"
    case .keychainOperationFailed: "sui.keychain_operation_failed"
    case .proofServiceError: "sui.proof_service_error"
    case .invalidProofServiceResponse: "sui.invalid_proof_service_response"
    case .missingGraphQLData: "sui.missing_graphql_data"
    case .missingJWTClaim: "sui.missing_jwt_claim"
    case .saltServiceError: "sui.salt_service_error"
    case .invalidSaltServiceResponse: "sui.invalid_salt_service_response"
    }
  }

  /// The underlying error description, if any.
  public var errorDescription: String? {
    underlyingError?.localizedDescription
  }

  /// Type representing possible error codes.
  public enum Code: Equatable, Sendable {
    /// A generic error with a message.
    case error(message: String)

    /// Indicates that a feature or operation is not yet implemented.
    case notImplementedError

    /// A custom error with a message.
    case customError(message: String)

    /// The transaction is invalid and cannot be processed.
    case invalidTransaction

    /// The requested object could not be found.
    case objectNotFound

    /// The signature scheme is not supported.
    case unsupportedSignatureScheme

    /// The salt or other data is missing for zkLogin
    case saltMissing

    /// Failed to generate random data for the nonce
    case failedToGenerateRandomData

    /// No proof service has been configured
    case missingProofService

    /// Failed to retrieve a key from the keychain
    case missingKeyItem

    /// Failed to encode data as a string
    case dataEncodingFailed

    /// Error when interacting with the keychain
    case keyChainError

    /// A keychain operation failed
    case keychainOperationFailed

    /// The proof service returned an error
    case proofServiceError

    /// The proof service returned an invalid response
    case invalidProofServiceResponse

    /// Missing GraphQL data
    case missingGraphQLData

    /// Missing JWT claim in token
    case missingJWTClaim

    /// Salt service returned an error
    case saltServiceError

    /// Invalid response from salt service
    case invalidSaltServiceResponse
  }

  /// Creates a new error with the given code.
  /// - Parameter code: The error code.
  public init(code: Code, underlyingError: Error? = nil) {
    self.code = code
    self.underlyingError = underlyingError
  }
}
