import Foundation

/// Abstraction over the HTTP transport layer.
///
/// By injecting this protocol instead of depending on `URLSession` directly,
/// the Gateway becomes fully testable with synchronous, deterministic mocks.
/// Production code injects ``URLSessionHTTPClient``; tests inject a mock
/// that returns canned `(Data, HTTPURLResponse)` tuples.
///
/// - Concurrency: Conformers must be `Sendable` to satisfy Swift 6 strict
///   concurrency requirements when shared across isolation domains.
public protocol HTTPClient: Sendable {

  /// Executes the given `URLRequest` and returns the raw response.
  ///
  /// - Parameter request: A fully-formed request including URL, method,
  ///   headers, and optional body.
  /// - Returns: A tuple of the response body data and the HTTP response metadata.
  /// - Throws: Any transport-level error (timeout, DNS failure, etc.).
  func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

/// Production implementation that delegates to `URLSession.shared`.
///
/// This is the default transport injected by ``APIGateway`` when no
/// custom ``HTTPClient`` is provided. It is intentionally stateless —
/// cookie storage and caching are left to the system defaults.
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public struct URLSessionHTTPClient: HTTPClient {
  private let session: URLSession

  public init(session: URLSession = .shared) {
    self.session = session
  }

  public func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw GatewayError.invalidResponse
    }
    return (data, httpResponse)
  }
}
