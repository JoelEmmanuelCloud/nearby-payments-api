import Foundation

@testable import Gateway

final class MockHTTPClient: HTTPClient, @unchecked Sendable {

  private(set) var capturedRequest: URLRequest?
  var responseBody: Data
  var statusCode: Int
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

extension GatewayConfiguration {
  static let test = GatewayConfiguration(
    baseURL: URL(string: "http://localhost:8080")!
  )
}
