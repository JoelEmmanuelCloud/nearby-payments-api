import Foundation

struct AppSessionStore {
  private enum Key {
    static let didCompleteOnboarding = "nearby.didCompleteOnboarding"
    static let userName = "nearby.userName"
  }

  private let defaults: UserDefaults

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  func didCompleteOnboarding() -> Bool {
    defaults.bool(forKey: Key.didCompleteOnboarding)
  }

  func userName() -> String {
    defaults.string(forKey: Key.userName) ?? "Nearby user"
  }

  func completeOnboarding() {
    defaults.set(true, forKey: Key.didCompleteOnboarding)
  }

  func saveUserName(_ userName: String) {
    defaults.set(userName, forKey: Key.userName)
  }

  func clearUserName() {
    defaults.removeObject(forKey: Key.userName)
  }
}
