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

extension SuiAPIError: CustomStringConvertible {
  public var description: String {
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
