import Foundation

/// Holds the configuration details required to connect to the authentication API gateway,
/// including the base URL and targeted version.
public struct GatewayConfiguration: Sendable {
  /// The root server URL.
  public let baseURL: URL
  /// The specific API version suffix (e.g. "v1").
  public let apiVersion: String

  /// Initializes a new `GatewayConfiguration`.
  ///
  /// - Parameters:
  ///   - baseURL: The root server URL of the backend.
  ///   - apiVersion: The target API version path. Defaults to `APIConstants.apiVersion`.
  public init(baseURL: URL, apiVersion: String = APIConstants.apiVersion) {
    self.baseURL = baseURL
    self.apiVersion = apiVersion
  }

  /// Appends version and subpath to construct a fully qualified endpoint URL.
  ///
  /// - Parameter path: The relative subpath.
  /// - Returns: A fully-formed `URL` or `nil` if construction fails.
  func url(for path: String) -> URL? {
    baseURL
      .appendingPathComponent(apiVersion)
      .appendingPathComponent(path)
  }
}
