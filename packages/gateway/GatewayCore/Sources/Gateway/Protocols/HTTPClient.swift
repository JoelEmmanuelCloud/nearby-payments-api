import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol HTTPClient: Sendable {
  func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public struct URLSessionHTTPClient: HTTPClient {
  private let session: URLSession

  public init() {
    self.session = .shared
  }

  public init(session: URLSession) {
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
