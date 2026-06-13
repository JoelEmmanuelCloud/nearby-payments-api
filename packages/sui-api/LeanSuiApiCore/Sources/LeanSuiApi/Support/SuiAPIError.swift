//
//  SuiAPIError.swift
//  LeanSuiApi
//
//  Owned error type for the GraphQL provider. Replaces SuiKit's sprawling
//  SuiError so this package has no dependency on the legacy core.
//

import Foundation

/// Errors thrown by ``GraphQLSuiProvider`` and the conversion layer.
public enum SuiAPIError: Error, Sendable, Equatable {
  /// The GraphQL response carried no `data` payload.
  case missingData

  /// A required field was absent from an otherwise-valid response.
  /// - Parameter field: Dotted path of the missing field, e.g. `"object.asMoveObject.contents"`.
  case missingField(_ field: String)

  /// The GraphQL endpoint returned one or more errors.
  case graphQL(messages: [String])

  /// A scalar string could not be parsed into its domain type
  /// (e.g. a `BigInt` scalar that wasn't a valid integer).
  case scalarDecoding(field: String, raw: String)

  /// The requested provider method has not been implemented yet.
  case notImplemented(_ method: String)

  /// Catch-all for everything else.
  case custom(message: String)
}

extension SuiAPIError {
  /// Stable, globally-unique, machine-readable code for each case (the case kind, not its payload).
  public enum Code: String, Sendable, CaseIterable {
    case missingData = "sui_api.missing_data"
    case missingField = "sui_api.missing_field"
    case graphQL = "sui_api.graphql"
    case scalarDecoding = "sui_api.scalar_decoding"
    case notImplemented = "sui_api.not_implemented"
    case custom = "sui_api.custom"
  }

  /// The stable code identifying this error's kind.
  public var code: Code {
    switch self {
    case .missingData: .missingData
    case .missingField: .missingField
    case .graphQL: .graphQL
    case .scalarDecoding: .scalarDecoding
    case .notImplemented: .notImplemented
    case .custom: .custom
    }
  }
}

extension SuiAPIError: LocalizedError {
  /// Human-readable detail (the `description` carries the stable `code` for bridge identification).
  public var errorDescription: String? {
    switch self {
    case .missingData:
      return "GraphQL response contained no data."
    case .missingField(let field):
      return "Missing required field: \(field)."
    case .graphQL(let messages):
      return "GraphQL errors: \(messages.joined(separator: ", "))."
    case .scalarDecoding(let field, let raw):
      return "Failed to decode scalar at \(field) from value '\(raw)'."
    case .notImplemented(let method):
      return "Not implemented: \(method)."
    case .custom(let message):
      return message
    }
  }
}

extension SuiAPIError: CustomStringConvertible {
  /// String form is the `code` raw value, so the exact code survives the swift-java bridge.
  public var description: String { code.rawValue }
}
