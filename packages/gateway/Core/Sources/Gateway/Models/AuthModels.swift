import Foundation

// MARK: - Provider

/// Identity providers supported by the backend's OAuth flow.
///
/// Adding a new provider requires backend support — this enum acts as a
/// compile-time gate preventing the client from sending unsupported values.
public enum OAuthProvider: String, Codable, Sendable, CaseIterable {
  case google = "google"
  case apple = "apple"
}

// MARK: - Server Public Key

/// Response from `GET /v1/auth/server-public-key`.
///
/// The server exposes its Ed25519 public key so the client can verify
/// signed payloads (e.g. attestation challenges) originated from the backend.
public struct ServerPublicKeyResponse: Codable, Sendable, Equatable {
  public let publicKey: String

  public init(publicKey: String) {
    self.publicKey = publicKey
  }
}

// MARK: - OAuth Begin

/// Request body for `POST /v1/auth/oauth/begin`.
///
/// The client generates PKCE and zkLogin cryptographic parameters locally
/// and hands them to the backend. The backend injects its own `client_id`,
/// `redirect_uri`, and CSRF `state`, then returns the fully-formed OAuth URL.
///
/// - Important: `codeChallenge` is the SHA-256 hash of the locally-held
///   `codeVerifier`. The verifier itself is never sent during `begin` —
///   it is transmitted during `complete` so the backend can forward it
///   to Google's token endpoint.
public struct OAuthBeginRequest: Codable, Sendable, Equatable {
  public let provider: OAuthProvider
  public let codeChallenge: String
  public let codeChallengeMethod: String
  public let zkLoginNonce: String

  public init(
    provider: OAuthProvider,
    codeChallenge: String,
    codeChallengeMethod: String = "S256",
    zkLoginNonce: String
  ) {
    self.provider = provider
    self.codeChallenge = codeChallenge
    self.codeChallengeMethod = codeChallengeMethod
    self.zkLoginNonce = zkLoginNonce
  }
}

/// Response from `POST /v1/auth/oauth/begin`.
///
/// The backend constructs the full OAuth authorization URL including
/// the client's PKCE challenge and zkLogin nonce, plus its own CSRF state.
/// The client opens `authURL` in a browser and holds `state` for validation.
public struct OAuthBeginResponse: Codable, Sendable, Equatable {
  public let authURL: String
  public let state: String

  public init(authURL: String, state: String) {
    self.authURL = authURL
    self.state = state
  }
}

// MARK: - OAuth Complete

/// Device integrity proof attached to sensitive requests.
///
/// On iOS this carries an App Attest assertion; on Android a Play Integrity token.
/// During development the backend accepts `"stub"` as the provider to bypass
/// real attestation verification.
public struct DeviceIntegrity: Codable, Sendable, Equatable {
  public let provider: String
  public let keyId: String?
  public let assertion: String?
  public let token: String?
  public let clientDataHash: String?

  public init(
    provider: String,
    keyId: String? = nil,
    assertion: String? = nil,
    token: String? = nil,
    clientDataHash: String? = nil
  ) {
    self.provider = provider
    self.keyId = keyId
    self.assertion = assertion
    self.token = token
    self.clientDataHash = clientDataHash
  }

  /// Convenience initialiser for development/testing with the stub provider.
  public static let stub = DeviceIntegrity(provider: "stub")
}

public enum AuthFlowPayload: Sendable, Equatable {
  case web(code: String, state: String, codeVerifier: String)
  case native(idToken: String, authorizationCode: String?)
}

/// Request body for `POST /v1/auth/oauth/complete`.
public struct OAuthCompleteRequest: Encodable, Sendable, Equatable {
  public let platform: String
  public let osVersion: String
  public let appBundleId: String
  public let deviceIntegrity: DeviceIntegrity
  public let payload: AuthFlowPayload

  public init(
    platform: String,
    osVersion: String,
    appBundleId: String,
    deviceIntegrity: DeviceIntegrity,
    payload: AuthFlowPayload
  ) {
    self.platform = platform
    self.osVersion = osVersion
    self.appBundleId = appBundleId
    self.deviceIntegrity = deviceIntegrity
    self.payload = payload
  }

  enum CodingKeys: String, CodingKey {
    case platform, osVersion, appBundleId, deviceIntegrity
    case flowType = "flow_type"
    // Web keys
    case code, state, codeVerifier
    // Native keys
    case idToken, authorizationCode
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(platform, forKey: .platform)
    try container.encode(osVersion, forKey: .osVersion)
    try container.encode(appBundleId, forKey: .appBundleId)
    try container.encode(deviceIntegrity, forKey: .deviceIntegrity)

    switch payload {
    case .web(let code, let state, let codeVerifier):
      try container.encode("web", forKey: .flowType)
      try container.encode(code, forKey: .code)
      try container.encode(state, forKey: .state)
      try container.encode(codeVerifier, forKey: .codeVerifier)
    case .native(let idToken, let authorizationCode):
      try container.encode("native", forKey: .flowType)
      try container.encode(idToken, forKey: .idToken)
      try container.encodeIfPresent(authorizationCode, forKey: .authorizationCode)
    }
  }
}

/// Response from `POST /v1/auth/oauth/complete`.
///
/// Contains the session credentials. The `accessToken` is short-lived
/// and used as a bearer token for subsequent API calls. The `refreshToken`
/// is long-lived and used to obtain new access tokens without re-authentication.
public struct OAuthCompleteResponse: Codable, Sendable, Equatable {
  public let accessToken: String
  public let refreshToken: String
  public let userId: String
  public let suiAddress: String
  public let jwt: String
  public let salt: String

  public init(
    accessToken: String,
    refreshToken: String,
    userId: String,
    suiAddress: String,
    jwt: String,
    salt: String
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.userId = userId
    self.suiAddress = suiAddress
    self.jwt = jwt
    self.salt = salt
  }
}

// MARK: - Refresh

/// Request body for `POST /v1/auth/refresh`.
///
/// Exchanges a valid refresh token for a new access/refresh token pair.
/// The old refresh token is invalidated (rotation).
public struct RefreshRequest: Codable, Sendable, Equatable {
  public let refreshToken: String

  public init(refreshToken: String) {
    self.refreshToken = refreshToken
  }
}

/// Response from `POST /v1/auth/refresh`.
public struct RefreshResponse: Codable, Sendable, Equatable {
  public let accessToken: String
  public let refreshToken: String

  public init(accessToken: String, refreshToken: String) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
}

// MARK: - Integrity

/// Request body for `POST /v1/auth/integrity`.
///
/// Submits a device attestation proof for server-side verification.
/// The backend validates the proof against Apple/Google and records
/// the device's trust level for subsequent request authorization.
public struct IntegrityRequest: Codable, Sendable, Equatable {
  public let deviceIntegrity: DeviceIntegrity
  public let timestampMs: Int64

  public init(deviceIntegrity: DeviceIntegrity, timestampMs: Int64) {
    self.deviceIntegrity = deviceIntegrity
    self.timestampMs = timestampMs
  }
}

// MARK: - Credential

/// Request body for `POST /v1/auth/credential`.
///
/// Registers a local proof public key with the backend. This key is generated
/// in the device's hardware security module (Secure Enclave / StrongBox) and
/// used to sign future sensitive requests for non-repudiation.
public struct CredentialRequest: Codable, Sendable, Equatable {
  public let localProofPublicKey: String

  public init(localProofPublicKey: String) {
    self.localProofPublicKey = localProofPublicKey
  }
}
