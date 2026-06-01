import Foundation

public enum StorageError: Error, LocalizedError, Equatable {
  case unhandledError(status: Int)
  case unexpectedDataFormat
  case androidException(String)

  public var errorDescription: String? {
    switch self {
    case .unhandledError(let status):
      return "An unhandled storage error occurred with status code: \(status)"
    case .unexpectedDataFormat:
      return "The data retrieved from storage was in an unexpected format."
    case .androidException(let message):
      return "Android storage exception: \(message)"
    }
  }
}
