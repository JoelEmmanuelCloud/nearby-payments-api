import Foundation

/// Immutable configuration for the Gateway's base URL and API version.
///
/// Injected at initialisation time so the same Gateway type can target
/// different environments (local dev, staging, production) without
/// conditional compilation.
public struct GatewayConfiguration: Sendable {
  public let baseURL: URL
  public let apiVersion: String

  public init(baseURL: URL, apiVersion: String = APIConstants.apiVersion) {
    self.baseURL = baseURL
    self.apiVersion = apiVersion
  }

  /// Resolves a route path (e.g. `"auth/oauth/begin"`) to a full URL.
  ///
  /// Produces: `<baseURL>/<apiVersion>/<path>`
  func url(for path: String) -> URL? {
    baseURL
      .appendingPathComponent(apiVersion)
      .appendingPathComponent(path)
  }
}
