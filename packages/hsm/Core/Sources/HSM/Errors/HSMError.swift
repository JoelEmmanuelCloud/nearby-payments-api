import Foundation

/// Errors thrown by the HSM package.
public enum HSMError: Error, LocalizedError, Equatable {
  case keyNotFound
  case keyGenerationFailed(status: Int)
  case keyRetrievalFailed(status: Int)
  case keyDeletionFailed(status: Int)

  public var errorDescription: String? {
    switch self {
    case .keyNotFound:
      return "The requested cryptographic key was not found."
    case .keyGenerationFailed(let status):
      return "Cryptographic key generation failed with status code: \(status)"
    case .keyRetrievalFailed(let status):
      return "Cryptographic key retrieval failed with status code: \(status)"
    case .keyDeletionFailed(let status):
      return "Cryptographic key deletion failed with status code: \(status)"
    }
  }
}
