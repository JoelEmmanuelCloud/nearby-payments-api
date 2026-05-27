import Foundation

/// Exhaustive error catalog for the Gateway layer.
///
/// Errors are split into semantic categories so callers can pattern-match
/// on the domain (network, encoding, server) without inspecting raw status codes.
/// The ``serverError`` case preserves the HTTP status and the backend's error body
/// to enable precise error handling in the Auth and Attest packages.
public enum GatewayError: Error, Sendable, Equatable {

  // MARK: - Request Construction

  /// The base URL or path components produced an invalid URL.
  /// This is a programmer error — the route constant is malformed.
  case invalidURL(path: String)

  /// The request body could not be encoded to JSON.
  /// Wraps the underlying `EncodingError` description for diagnostics.
  case encodingFailed(description: String)

  // MARK: - Network Transport

  /// The underlying transport (URLSession or mock) threw an error.
  /// Wraps the localised description to remain `Sendable`.
  case networkFailure(description: String)

  // MARK: - Response Handling

  /// The server returned a non-2xx HTTP status code.
  ///
  /// - Parameters:
  ///   - statusCode: The raw HTTP status (e.g. 401, 403, 422, 500).
  ///   - body: The raw response body as UTF-8 text for logging/debugging.
  case serverError(statusCode: Int, body: String)

  /// The response body could not be decoded into the expected `Decodable` type.
  /// Wraps the underlying `DecodingError` description for diagnostics.
  case decodingFailed(description: String)

  /// The server returned a response without a recognisable `HTTPURLResponse`.
  case invalidResponse
}

extension GatewayError: LocalizedError {
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
