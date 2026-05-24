import Foundation
import Security

/// Errors thrown by the HSM package.
public enum HSMError: Error, Equatable {
  case keyNotFound
  case keyGenerationFailed(OSStatus)
  case keyRetrievalFailed(OSStatus)
  case keyDeletionFailed(OSStatus)
}
