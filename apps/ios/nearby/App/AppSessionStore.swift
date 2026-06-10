import Foundation
import Identity

struct AppSessionStore {
  private enum Key {
    static let didCompleteOnboarding = "nearby.didCompleteOnboarding"
    static let didCompleteProfileSetup = "nearby.didCompleteProfileSetup"
    static let userName = "nearby.userName"
    static let balanceHidden = "nearby.balanceHidden"
    static let lastBalance = "nearby.lastUsdSuiBalance"
    static func profile(_ userId: String) -> String { "nearby.profile.\(userId)" }
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

  /// Whether the user has finished first-run profile setup (e.g. registered a SuiNS name).
  /// Used to route post-login to Home vs the setup flow, since `suiAddress` is now always present.
  func didCompleteProfileSetup() -> Bool {
    defaults.bool(forKey: Key.didCompleteProfileSetup)
  }

  func completeProfileSetup() {
    defaults.set(true, forKey: Key.didCompleteProfileSetup)
  }

  func saveUserName(_ userName: String) {
    defaults.set(userName, forKey: Key.userName)
  }

  func clearUserName() {
    defaults.removeObject(forKey: Key.userName)
  }

  /// Whether the account balance is hidden on Home (global, persisted across launches).
  func balanceHidden() -> Bool {
    defaults.bool(forKey: Key.balanceHidden)
  }

  func setBalanceHidden(_ hidden: Bool) {
    defaults.set(hidden, forKey: Key.balanceHidden)
  }

  /// The last fetched USDsui balance, so Home shows it immediately on re-entry (silent refetch, no
  /// skeleton flip). Stored as a string to preserve `Decimal` precision.
  func lastUsdSuiBalance() -> Decimal? {
    guard let string = defaults.string(forKey: Key.lastBalance) else { return nil }
    return Decimal(string: string)
  }

  func setLastUsdSuiBalance(_ value: Decimal) {
    defaults.set("\(value)", forKey: Key.lastBalance)
  }

  // MARK: - Identity profile cache
  //
  // Non-secret profile metadata for instant display + offline fallback. Lives in UserDefaults
  // (not the Keychain) now that the identity core no longer caches; avatar *images* are not stored
  // here — they're rendered from `avatarUrl` by the image loader.

  func cacheProfile(_ profile: IdentityProfile) {
    guard let data = try? JSONEncoder().encode(profile) else { return }
    defaults.set(data, forKey: Key.profile(profile.userId))
  }

  func cachedProfile(userId: String) -> IdentityProfile? {
    guard let data = defaults.data(forKey: Key.profile(userId)) else { return nil }
    return try? JSONDecoder().decode(IdentityProfile.self, from: data)
  }
}
