import Auth
import Foundation
import Gateway
import LeanSuiApi

/// Coordinates wallet binding, metadata updates, and name registration flows.
///
/// This layer is networking-only: it fetches profile/name data and returns owned DTOs. Caching
/// (profile DTO, avatar image) is an app-side concern — the app persists the DTO in normal storage
/// and renders `avatarUrl` through its image loader, so the identity core holds no `SecureStorage`.
public final class IdentityManager: @unchecked Sendable {
  private let gateway: any APIGatewayProtocol
  private let nsResolver: any SuiNSResolverProtocol
  private let tokenProvider: any SessionTokenProvider

  /// Initializes a new `IdentityManager`. Internal: the `any`-protocol seam is for Swift tests; the
  /// public bridged entry point is the concrete convenience init below.
  init(
    gateway: any APIGatewayProtocol,
    nsResolver: any SuiNSResolverProtocol,
    tokenProvider: any SessionTokenProvider
  ) {
    self.gateway = gateway
    self.nsResolver = nsResolver
    self.tokenProvider = tokenProvider
  }

  /// Convenience initializer for JNI bridging. The concrete types conform to the protocols natively
  /// in their home modules (`SessionManager: SessionTokenProvider` in Auth,
  /// `GraphQLSuiProvider: SuiNSResolverProtocol` in LeanSuiApi), so they're passed directly.
  public convenience init(
    gateway: APIGateway,
    nsResolver: GraphQLSuiProvider,
    sessionManager: SessionManager
  ) {
    self.init(
      gateway: gateway,
      nsResolver: nsResolver,
      tokenProvider: SessionManagerAdapter(sessionManager: sessionManager)
    )
  }

  /// Binds an explicit Sui address to the authenticated account on the backend.
  public func bindWallet(suiAddress: String) async throws {
    let token = try await getValidToken()
    do {
      let request = BindWalletRequest(suiAddress: suiAddress)
      try await gateway.bindWallet(request: request, accessToken: token)
    } catch {
      throw IdentityError.gatewayFailure
    }
  }

  /// Best-effort, idempotent re-bind of the session's (stable) Sui address to the backend.
  ///
  /// Safe to call on every app start: the backend bind is an idempotent upsert, so there is no local
  /// "bound" flag to track. The address is read from the session (written by the login/zkLogin layer);
  /// identity neither derives nor persists it. Errors propagate so the caller can route a forced
  /// logout (`SessionError.sessionExpired` from token refresh) — never swallowed here.
  public func rebind() async throws {
    guard let session = try tokenProvider.getCurrentSession(),
      let suiAddress = session.suiAddress, !suiAddress.isEmpty
    else {
      return
    }
    try await bindWallet(suiAddress: suiAddress)
  }

  /// Fetches a unified identity profile combining backend metadata and direct on-chain SuiNS domain lookups.
  public func fetchProfile(suiAddress: String) async throws -> IdentityProfile {
    let token = try await getValidToken()

    // Resolve SuiNS domain in parallel
    let domain: String?
    do {
      domain = try await nsResolver.resolveNameServiceNames(address: suiAddress)
    } catch {
      domain = nil
    }

    do {
      let profile = try await gateway.getProfile(accessToken: token)
      // Returns an owned DTO; the app persists it for offline display and renders `avatarUrl`
      // through its own image loader. No caching here.
      return IdentityProfile(
        userId: profile.userId,
        status: profile.status,
        avatarUrl: profile.avatarUrl,
        suiAddress: suiAddress,
        // On-chain SuiNS resolution is the only source of truth for the registered name. nil means
        // "no name registered" — never fall back to account status (that fabricated "active.nearby.sui").
        suinsName: domain,
        createdAt: profile.createdAt
      )
    } catch {
      throw IdentityError.gatewayFailure
    }
  }

  /// Uploads a binary avatar image for the user and updates backend record.
  public func updateAvatar(data: [UInt8], contentType: String) async throws -> String {
    let token = try await getValidToken()
    do {
      let response = try await gateway.uploadAvatar(
        data: data,
        contentType: contentType,
        accessToken: token
      )
      // Returns the new URL; the app refreshes its cached profile and image loader.
      return response.avatarUrl
    } catch {
      throw IdentityError.gatewayFailure
    }
  }

  /// Checks the availability of a leaf name under nearby.sui.
  public func checkNameAvailability(leafName: String) async throws -> NameAvailabilityResponse {
    let token = try await getValidToken()
    do {
      return try await gateway.checkNameAvailability(leafName: leafName, accessToken: token)
    } catch {
      throw IdentityError.gatewayFailure
    }
  }

  /// Triggers an asynchronous request to register a leaf name. The device-attestation nonce/timestamp
  /// are one-time and minted per request here — callers must not pass (or reuse) them.
  public func registerName(
    leafName: String,
    deviceProvider: String
  ) async throws -> RegisterLeafResponse {
    let token = try await getValidToken()
    do {
      let request = RegisterLeafRequest(leafName: leafName)
      return try await gateway.registerLeafName(
        request: request,
        accessToken: token,
        deviceProvider: deviceProvider,
        requestNonce: UUID().uuidString,
        requestTimestamp: Self.requestTimestamp()
      )
    } catch {
      throw IdentityError.gatewayFailure
    }
  }

  /// Polls the name registration task until it completes or fails. Each poll mints a **fresh**
  /// nonce/timestamp — the device-attestation nonce is one-time, so reusing it would be flagged as a
  /// replay by the backend.
  public func pollNameTask(
    taskId: String,
    deviceProvider: String,
    intervalSeconds: Double = 2.0,
    maxRetries: Int = 15
  ) async throws -> NameTaskStatusResponse {
    for _ in 0..<maxRetries {
      let token = try await getValidToken()
      let task = try await gateway.getNameTask(
        taskId: taskId,
        accessToken: token,
        deviceProvider: deviceProvider,
        requestNonce: UUID().uuidString,
        requestTimestamp: Self.requestTimestamp()
      )

      if task.status == "confirmed" {
        return task
      } else if task.status == "failed" {
        throw IdentityError.registrationFailed
      }

      try await Task.sleep(nanoseconds: UInt64(intervalSeconds * 1_000_000_000))
    }
    throw IdentityError.registrationFailed
  }

  // MARK: - Private Helpers

  private func getValidToken() async throws -> String {
    guard let token = try await tokenProvider.getAccessToken() else {
      throw IdentityError.unauthorized
    }
    return token
  }

  /// Current time as a millisecond epoch string, for the per-request device-attestation header.
  private static func requestTimestamp() -> String {
    String(Int64(Date().timeIntervalSince1970 * 1000))
  }
}
