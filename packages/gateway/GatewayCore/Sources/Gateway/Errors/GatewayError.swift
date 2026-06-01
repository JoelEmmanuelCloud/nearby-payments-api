import Foundation

public enum GatewayError: Error, Sendable, Equatable {
  case invalidURL(path: String)
  case encodingFailed(description: String)
  case networkFailure(description: String)
  case serverError(statusCode: Int, body: String)
  case decodingFailed(description: String)
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
