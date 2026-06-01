import Foundation

struct AppSessionStore {
  private enum Key {
    static let didCompleteOnboarding = "nearby.didCompleteOnboarding"
    static let isAuthenticated = "nearby.isAuthenticated"
    static let userName = "nearby.userName"
  }

  private let defaults: UserDefaults

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  func didCompleteOnboarding() -> Bool {
    defaults.bool(forKey: Key.didCompleteOnboarding)
  }

  func isAuthenticated() -> Bool {
    defaults.bool(forKey: Key.isAuthenticated)
  }

  func userName() -> String {
    defaults.string(forKey: Key.userName) ?? "Nearby user"
  }

  func completeOnboarding() {
    defaults.set(true, forKey: Key.didCompleteOnboarding)
  }

  func saveAuthenticatedSession(userName: String) {
    defaults.set(true, forKey: Key.isAuthenticated)
    defaults.set(userName, forKey: Key.userName)
  }

  func clearSession() {
    defaults.set(false, forKey: Key.isAuthenticated)
    defaults.removeObject(forKey: Key.userName)
  }
}
