import Foundation

/// Errors that can occur during API Gateway requests, including request encoding,
/// network transport, server responses, and response parsing.
public enum GatewayError: Error, Sendable, Equatable {
  /// The request URL could not be constructed for the given relative subpath.
  case invalidURL(path: String)

  /// The JSON encoder failed to encode the request payload structure.
  case encodingFailed(description: String)

  /// The network client encountered a transport or connectivity error.
  case networkFailure(description: String)

  /// The server returned an HTTP error status code.
  case serverError(statusCode: Int, body: String)

  /// The JSON decoder failed to parse the server's response.
  case decodingFailed(description: String)

  /// The network client did not receive a valid HTTP response type (e.g. non-HTTP protocols).
  case invalidResponse
}

extension GatewayError: LocalizedError {
  /// A localized description of the gateway error.
  public var errorDescription: String? {
    switch self {
    case .invalidURL(let path):
      "Gateway: failed to construct URL for path '\(path)'"
    case .encodingFailed(let description):
      "Gateway: JSON encoding failed — \(description)"
    case .networkFailure(let description):
      "Gateway: network transport error — \(description)"
    case .serverError(let statusCode, let body):
      "Gateway: server returned HTTP \(statusCode) — \(body)"
    case .decodingFailed(let description):
      "Gateway: JSON decoding failed — \(description)"
    case .invalidResponse:
      "Gateway: response was not a valid HTTPURLResponse"
    }
  }
}

extension GatewayError {
  /// Stable, globally-unique, machine-readable code for each case (the case kind, not its payload).
  public enum Code: String, Sendable, CaseIterable {
    case invalidURL = "gateway.invalid_url"
    case encodingFailed = "gateway.encoding_failed"
    case networkFailure = "gateway.network_failure"
    case serverError = "gateway.server_error"
    case decodingFailed = "gateway.decoding_failed"
    case invalidResponse = "gateway.invalid_response"
  }

  /// The stable code identifying this error's kind.
  public var code: Code {
    switch self {
    case .invalidURL: .invalidURL
    case .encodingFailed: .encodingFailed
    case .networkFailure: .networkFailure
    case .serverError: .serverError
    case .decodingFailed: .decodingFailed
    case .invalidResponse: .invalidResponse
    }
  }
}

extension GatewayError: CustomStringConvertible {
  /// String form is the `code` raw value, so the exact code survives the swift-java bridge.
  /// (Human-readable detail remains available via `errorDescription`.)
  public var description: String { code.rawValue }
}
