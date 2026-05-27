import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Reusable HTTP request executor for the Gateway layer.
///
/// Owns all request construction, header injection, JSON encoding/decoding,
/// and error wrapping. Gateway endpoint methods delegate here so they remain
/// thin one-liners that map protocol requirements to HTTP calls.
///
/// This type is internal — consumers interact through ``AuthGateway``,
/// never with the executor directly.
struct HTTPRequestExecutor: Sendable {

  let configuration: GatewayConfiguration
  let httpClient: HTTPClient

  // MARK: - High-Level Verbs

  /// Executes a GET request and decodes the JSON response.
  func get<Response: Decodable>(
    path: String,
    accessToken: String? = nil
  ) async throws -> Response {
    let urlRequest = try buildRequest(
      method: "GET",
      path: path,
      accessToken: accessToken
    )
    return try await execute(urlRequest)
  }

  /// Executes a POST request with a JSON body and decodes the response.
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

  /// Executes a POST request where the response body is discarded (e.g. revoke).
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

  // MARK: - Request Construction

  /// Constructs a `URLRequest` with method, path, and layered headers.
  ///
  /// Header injection order:
  /// 1. Content-Type (JSON for POST)
  /// 2. Authorization bearer token
  /// 3. Device integrity headers
  private func buildRequest(
    method: String,
    path: String,
    accessToken: String? = nil,
    deviceHeaders: DeviceHeaders? = nil
  ) throws -> URLRequest {
    guard let url = configuration.url(for: path) else {
      throw GatewayError.invalidURL(path: path)
    }

    var request = URLRequest(url: url)
    request.httpMethod = method

    if method == "POST" {
      request.setValue(
        APIConstants.ContentType.json,
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

  /// Executes and decodes a JSON response. Non-2xx → ``GatewayError/serverError``.
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

  /// Executes a request where the response body is ignored.
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

  /// Single delegation point to the injected ``HTTPClient``.
  /// Wraps transport errors into ``GatewayError/networkFailure``.
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

/// Bundles device-integrity header values to avoid parameter bloat.
struct DeviceHeaders: Sendable {
  let provider: String
  let nonce: String
  let timestamp: String
}
