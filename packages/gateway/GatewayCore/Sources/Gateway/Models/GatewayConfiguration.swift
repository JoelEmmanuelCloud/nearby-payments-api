import Foundation

public struct GatewayConfiguration: Sendable {
  public let baseURL: URL
  public let apiVersion: String

  public init(baseURL: URL, apiVersion: String = APIConstants.apiVersion) {
    self.baseURL = baseURL
    self.apiVersion = apiVersion
  }

  func url(for path: String) -> URL? {
    baseURL
      .appendingPathComponent(apiVersion)
      .appendingPathComponent(path)
  }
}
