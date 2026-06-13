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

extension HSMError {
  /// Stable, globally-unique, machine-readable code for each case (the case kind, not its payload).
  public enum Code: String, Sendable, CaseIterable {
    case keyNotFound = "hsm.key_not_found"
    case keyGenerationFailed = "hsm.key_generation_failed"
    case keyRetrievalFailed = "hsm.key_retrieval_failed"
    case keyDeletionFailed = "hsm.key_deletion_failed"
  }

  /// The stable code identifying this error's kind.
  public var code: Code {
    switch self {
    case .keyNotFound: .keyNotFound
    case .keyGenerationFailed: .keyGenerationFailed
    case .keyRetrievalFailed: .keyRetrievalFailed
    case .keyDeletionFailed: .keyDeletionFailed
    }
  }
}

extension HSMError: CustomStringConvertible {
  /// String form is the `code` raw value, so the exact code survives the swift-java bridge.
  public var description: String { code.rawValue }
}
