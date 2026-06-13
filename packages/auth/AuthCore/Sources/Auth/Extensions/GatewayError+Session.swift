import Gateway

extension GatewayError {
  var isTerminalSessionFailure: Bool {
    switch self {
    case .serverError(let statusCode, _):
      return statusCode == 400 || statusCode == 401 || statusCode == 403 || statusCode == 409
    case .invalidURL, .encodingFailed, .networkFailure, .decodingFailed, .invalidResponse:
      return false
    }
  }
}
