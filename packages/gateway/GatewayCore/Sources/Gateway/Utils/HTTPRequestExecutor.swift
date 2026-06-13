import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// An internal helper structure that executes HTTP GET and POST requests, configures
/// headers and authorization tokens, and decodes JSON responses.
struct HTTPRequestExecutor: Sendable {

  /// The configuration containing base URL and target API version.
  let configuration: GatewayConfiguration
  /// The underlying HTTP request execution transport client.
  let httpClient: HTTPClient

  /// Executes a GET request to a relative path and decodes the JSON response.
  ///
  /// - Parameters:
  ///   - path: The target relative subpath.
  ///   - accessToken: An optional bearer token to authorize the request.
  ///   - deviceHeaders: Optional platform-specific device integrity headers.
  /// - Returns: A decoded model of the generic `Response` type.
  /// - Throws: `GatewayError` if URL construction, network transport, or decoding fails.
  func get<Response: Decodable>(
    path: String,
    accessToken: String? = nil,
    deviceHeaders: DeviceHeaders? = nil
  ) async throws -> Response {
    let urlRequest = try buildRequest(
      method: "GET",
      path: path,
      accessToken: accessToken,
      deviceHeaders: deviceHeaders
    )
    return try await execute(urlRequest)
  }

  /// Executes a POST request to a relative path, encoding the JSON body and decoding the response.
  ///
  /// - Parameters:
  ///   - path: The target relative subpath.
  ///   - body: The model payload to serialize into the request body.
  ///   - accessToken: Optional bearer authorization token.
  ///   - deviceHeaders: Optional platform-specific device integrity headers.
  /// - Returns: A decoded model of the generic `Response` type.
  /// - Throws: `GatewayError` if encoding, execution, or decoding fails.
  func post<Body: Encodable, Response: Decodable>(
    path: String,
    body: Body,
    accessToken: String? = nil,
    deviceHeaders: DeviceHeaders? = nil
  ) async throws -> Response {
    var urlRequest = try buildRequest(
      method: "POST",
      path: path,
      accessToken: accessToken,
      deviceHeaders: deviceHeaders
    )
    urlRequest.httpBody = try JSONCoders.encode(body)
    return try await execute(urlRequest)
  }

  /// Executes a PUT request to a relative path, encoding the JSON body and decoding the response.
  ///
  /// - Parameters:
  ///   - path: The target relative subpath.
  ///   - body: The model payload to serialize into the request body.
  ///   - accessToken: Optional bearer authorization token.
  /// - Returns: A decoded model of the generic `Response` type.
  /// - Throws: `GatewayError` if encoding, execution, or decoding fails.
  func put<Body: Encodable, Response: Decodable>(
    path: String,
    body: Body,
    accessToken: String? = nil
  ) async throws -> Response {
    var urlRequest = try buildRequest(
      method: "PUT",
      path: path,
      accessToken: accessToken
    )
    urlRequest.httpBody = try JSONCoders.encode(body)
    return try await execute(urlRequest)
  }

  /// Executes a PUT request with no returned response body.
  ///
  /// - Parameters:
  ///   - path: The target relative subpath.
  ///   - body: Optional body payload to serialize.
  ///   - accessToken: Optional bearer authorization token.
  /// - Throws: `GatewayError` if execution fails.
  func putVoid<Body: Encodable>(
    path: String,
    body: Body,
    accessToken: String? = nil
  ) async throws {
    var urlRequest = try buildRequest(
      method: "PUT",
      path: path,
      accessToken: accessToken
    )
    urlRequest.httpBody = try JSONCoders.encode(body)
    try await executeVoid(urlRequest)
  }

  /// Executes a PUT request with raw binary data and a custom Content-Type header.
  ///
  /// - Parameters:
  ///   - path: The target relative subpath.
  ///   - data: The binary data payload.
  ///   - contentType: The MIME content type header value.
  ///   - accessToken: Optional bearer authorization token.
  /// - Returns: A decoded model of the generic `Response` type.
  /// - Throws: `GatewayError` if execution or decoding fails.
  func putRaw<Response: Decodable>(
    path: String,
    data: Data,
    contentType: String,
    accessToken: String? = nil
  ) async throws -> Response {
    var urlRequest = try buildRequest(
      method: "PUT",
      path: path,
      accessToken: accessToken,
      contentType: contentType
    )
    urlRequest.httpBody = data
    return try await execute(urlRequest)
  }

  /// Executes a POST request with no returned response body.
  ///
  /// - Parameters:
  ///   - path: The target relative subpath.
  ///   - body: Optional body payload to serialize.
  ///   - accessToken: Optional bearer authorization token.
  ///   - deviceHeaders: Optional device integrity headers.
  /// - Throws: `GatewayError` if execution fails.
  func postVoid(
    path: String,
    body: (any Encodable)? = nil,
    accessToken: String? = nil,
    deviceHeaders: DeviceHeaders? = nil
  ) async throws {
    var urlRequest = try buildRequest(
      method: "POST",
      path: path,
      accessToken: accessToken,
      deviceHeaders: deviceHeaders
    )
    if let body {
      urlRequest.httpBody = try JSONCoders.encode(body)
    }
    try await executeVoid(urlRequest)
  }

  /// Helper to construct a URLRequest and set HTTP headers.
  private func buildRequest(
    method: String,
    path: String,
    accessToken: String? = nil,
    contentType: String? = nil,
    deviceHeaders: DeviceHeaders? = nil
  ) throws -> URLRequest {
    guard let url = configuration.url(for: path) else {
      throw GatewayError.invalidURL(path: path)
    }

    var request = URLRequest(url: url)
    request.httpMethod = method

    if method == "POST" || method == "PUT" {
      let ct = contentType ?? APIConstants.ContentType.json
      request.setValue(
        ct,
        forHTTPHeaderField: APIConstants.Headers.contentType
      )
    }

    if let accessToken {
      request.setValue(
        "Bearer \(accessToken)",
        forHTTPHeaderField: APIConstants.Headers.authorization
      )
    }

    if let deviceHeaders {
      request.setValue(
        deviceHeaders.provider,
        forHTTPHeaderField: APIConstants.Headers.deviceProvider
      )
      request.setValue(
        deviceHeaders.nonce,
        forHTTPHeaderField: APIConstants.Headers.requestNonce
      )
      request.setValue(
        deviceHeaders.timestamp,
        forHTTPHeaderField: APIConstants.Headers.requestTimestamp
      )
    }

    return request
  }

  /// Performs network execution and decodes the response body into JSON.
  private func execute<Response: Decodable>(
    _ request: URLRequest
  ) async throws -> Response {
    let (data, httpResponse) = try await performRequest(request)

    guard (200...299).contains(httpResponse.statusCode) else {
      let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
      throw GatewayError.serverError(
        statusCode: httpResponse.statusCode,
        body: body
      )
    }

    return try JSONCoders.decode(type: Response.self, from: data)
  }

  /// Performs network execution and verifies HTTP success status codes.
  private func executeVoid(_ request: URLRequest) async throws {
    let (data, httpResponse) = try await performRequest(request)

    guard (200...299).contains(httpResponse.statusCode) else {
      let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
      throw GatewayError.serverError(
        statusCode: httpResponse.statusCode,
        body: body
      )
    }
  }

  /// Executes request with retry or generic network error conversion.
  private func performRequest(
    _ request: URLRequest
  ) async throws -> (Data, HTTPURLResponse) {
    do {
      return try await httpClient.execute(request)
    } catch let error as GatewayError {
      throw error
    } catch {
      throw GatewayError.networkFailure(description: error.localizedDescription)
    }
  }
}

/// Structured representation of headers submitted during device integrity checks.
struct DeviceHeaders: Sendable {
  /// The integrity provider used (e.g. apple_app_attest, play_integrity).
  let provider: String
  /// The verification challenge nonce.
  let nonce: String
  /// Request timestamp.
  let timestamp: String
}
