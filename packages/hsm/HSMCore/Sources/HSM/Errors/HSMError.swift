import Foundation

/// Errors thrown by the HSM package.
public enum HSMError: Error, LocalizedError, Equatable {
  /// The requested cryptographic key reference was not found in secure storage.
  case keyNotFound
  /// Cryptographic key generation failed.
  case keyGenerationFailed(status: Int)
  /// Cryptographic key retrieval from secure storage failed.
  case keyRetrievalFailed(status: Int)
  /// Cryptographic key deletion from secure storage failed.
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
