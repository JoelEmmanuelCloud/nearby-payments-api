import Foundation

/// Errors that can occur during secure storage operations.
public enum StorageError: Error, LocalizedError, Equatable {
  /// An unhandled platform storage error occurred (e.g. security keychain status code).
  case unhandledError(status: Int)

  /// The retrieved data was not in the expected format.
  case unexpectedDataFormat

  /// An Android-specific exception message passed back via the JNI bridge.
  case androidException(String)

  /// A localized description explaining the cause of the storage error.
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

extension StorageError {
  /// Stable, globally-unique, machine-readable code for each case (the case kind, not its payload).
  public enum Code: String, Sendable, CaseIterable {
    case unhandledError = "storage.unhandled_error"
    case unexpectedDataFormat = "storage.unexpected_data_format"
    case androidException = "storage.android_exception"
  }

  /// The stable code identifying this error's kind.
  public var code: Code {
    switch self {
    case .unhandledError: .unhandledError
    case .unexpectedDataFormat: .unexpectedDataFormat
    case .androidException: .androidException
    }
  }
}

extension StorageError: CustomStringConvertible {
  /// String form is the `code` raw value, so the exact code survives the swift-java bridge.
  public var description: String { code.rawValue }
}
