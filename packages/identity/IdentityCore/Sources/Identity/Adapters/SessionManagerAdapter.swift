import Auth

/// A read-only view over an active session, for consumers that only need a valid access token and
/// the current session (e.g. the identity layer). `SessionManager` conforms natively below, so the
/// abstraction is owned by the module that owns the type — no retroactive conformance elsewhere.
public protocol SessionTokenProvider {
  /// Fetches the active access token, refreshing it automatically if expired.
  func getAccessToken() async throws -> String?

  /// Returns the current active session, if any.
  func getCurrentSession() throws -> AuthSession?
}

public final class SessionManagerAdapter: SessionTokenProvider {
  private let sessionManager: SessionManager

  init(sessionManager: SessionManager) {
    self.sessionManager = sessionManager
  }

  public func getAccessToken() async throws -> String? {
    return try await sessionManager.getAccessToken()
  }

  public func getCurrentSession() throws -> AuthSession? {
    return try sessionManager.getCurrentSession()
  }
}
