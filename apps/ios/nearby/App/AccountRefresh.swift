import Foundation

/// App-wide signal that the account's on-chain state changed (a send or consolidation executed), so
/// balance- and activity-backed screens should refresh. Posted by the gasless write actions and
/// observed by the Home and Activity view models.
enum AccountRefresh {
  static let didChange = Notification.Name("nearby.accountDidChange")

  /// Announce that the account changed.
  static func post() {
    NotificationCenter.default.post(name: didChange, object: nil)
  }

  /// An async stream of change events, for view models to `for await` in their lifecycle task.
  static var events: NotificationCenter.Notifications {
    NotificationCenter.default.notifications(named: didChange)
  }
}
