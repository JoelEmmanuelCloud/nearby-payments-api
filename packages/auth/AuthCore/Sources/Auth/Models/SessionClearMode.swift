import Foundation

/// Manages the current session clearance scope.
public enum SessionClearMode: String, Sendable {
  /// Clear persisted auth/session values for the active user.
  case current
  /// Clear all secure storage and rotate/delete device keys.
  case all
}
