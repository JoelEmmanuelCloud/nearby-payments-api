import Foundation

@testable import Gateway

/// Deterministic HTTP client for unit testing.
///
/// Captures the outgoing `URLRequest` for assertion and returns a
/// pre-configured response. This eliminates network dependencies and
/// makes tests fully synchronous and reproducible.
///
/// ## Usage
///
/// ```swift
/// let mock = MockHTTPClient(
///     responseBody: try JSONCoders.encoder.encode(expected),
///     statusCode: 200
/// )
/// let gateway = APIGateway(configuration: .test, httpClient: mock)
/// let result = try await gateway.beginOAuth(request: ...)
/// #expect(mock.capturedRequest?.httpMethod == "POST")
/// ```
final class MockHTTPClient: HTTPClient, @unchecked Sendable {

  /// The last request passed to ``execute(_:)``.
  /// Inspect this to verify URL, method, headers, and body.
  private(set) var capturedRequest: URLRequest?

  /// The canned response data to return.
  var responseBody: Data

  /// The HTTP status code to return.
  var statusCode: Int

  /// Optional error to throw instead of returning a response.
  /// When set, ``execute(_:)`` throws this error before returning.
  var errorToThrow: Error?

  init(
    responseBody: Data = Data(),
    statusCode: Int = 200,
    errorToThrow: Error? = nil
  ) {
    self.responseBody = responseBody
    self.statusCode = statusCode
    self.errorToThrow = errorToThrow
  }

  func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    capturedRequest = request

    if let error = errorToThrow {
      throw error
    }

    let response = HTTPURLResponse(
      url: request.url!,
      statusCode: statusCode,
      httpVersion: nil,
      headerFields: nil
    )!

    return (responseBody, response)
  }
}

// MARK: - Test Configuration Helpers

extension GatewayConfiguration {
  /// Canonical test configuration pointing to a non-routable localhost.
  static let test = GatewayConfiguration(
    baseURL: URL(string: "http://localhost:8080")!
  )
}
