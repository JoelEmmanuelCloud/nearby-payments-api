import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Defines a simple networking abstraction to execute HTTP requests asynchronously.
public protocol HTTPClient: Sendable {
  /// Executes a given `URLRequest` and returns the resulting binary data and HTTP URL response.
  ///
  /// - Parameter request: The HTTP URL request to perform.
  /// - Returns: A tuple containing the response body `Data` and the received `HTTPURLResponse`.
  /// - Throws: An error if transport fails.
  func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

/// A standard `HTTPClient` implementation utilizing Apple's default `URLSession`.
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public struct URLSessionHTTPClient: HTTPClient {
  private let session: URLSession

  /// Initializes a `URLSessionHTTPClient` using the shared URL session.
  public init() {
    self.session = .shared
  }

  /// Initializes a `URLSessionHTTPClient` using a custom URL session.
  ///
  /// - Parameter session: The custom URL session to run requests.
  public init(session: URLSession) {
    self.session = session
  }

  /// Executes the request using URLSession's asynchronous data transfer method.
  ///
  /// - Parameter request: The HTTP request to perform.
  /// - Returns: A tuple containing response body `Data` and `HTTPURLResponse`.
  /// - Throws: `GatewayError.invalidResponse` if response is not an HTTP URL response type, or standard URLSession errors.
  public func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw GatewayError.invalidResponse
    }
    return (data, httpResponse)
  }
}
