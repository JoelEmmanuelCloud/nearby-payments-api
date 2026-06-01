import Foundation

/// Supported OAuth 2.0 identity providers.
public enum OAuthProvider: String, Codable, Sendable, CaseIterable {
  /// Google Identity Service provider.
  case google = "google"
  /// Apple ID Identity provider.
  case apple = "apple"
}

/// The response model carrying the backend server's public key.
public struct ServerPublicKeyResponse: Codable, Sendable, Equatable {
  /// The base64-encoded server public key.
  public let publicKey: String

  /// Initializes a new server public key response.
  public init(publicKey: String) {
    self.publicKey = publicKey
  }
}

/// Request parameters submitted to begin the authentication flow.
public struct OAuthBeginRequest: Codable, Sendable, Equatable {
  /// The selected authentication provider.
  public let provider: OAuthProvider
  /// The cryptographic code challenge derived from client PKCE verifier.
  public let codeChallenge: String
  /// The method utilized to hash the verifier (typically "S256" or "Exclude").
  public let codeChallengeMethod: String
  /// The zkLogin nonce parameter verifying signature proof constraints.
  public let zkLoginNonce: String

  /// Initializes a begin OAuth request.
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

/// Response returned when beginning the OAuth flow, directing the client to login.
public struct OAuthBeginResponse: Codable, Sendable, Equatable {
  /// The target URL to navigate the user's browser/redirect view for authorization.
  public let authURL: String
  /// The verification state token mapping the local session.
  public let state: String

  /// Initializes a begin OAuth response.
  public init(authURL: String, state: String) {
    self.authURL = authURL
    self.state = state
  }
}

/// Hardware and platform-specific device integrity assertion payload.
///
/// This structure bridges to Java via JNI. Optional fields (`keyId`, `assertion`, `token`, `clientDataHash`)
/// are exposed as `java.util.Optional` types in Kotlin/Java.
public struct DeviceIntegrity: Codable, Sendable, Equatable {
  /// The integrity provider scheme utilized (e.g. "apple_app_attest", "play_integrity", "stub").
  public let provider: String
  /// The unique key identifier registered by Apple App Attest.
  public let keyId: String?
  /// The hardware attestation statement or assertion signature payload.
  public let assertion: String?
  /// The Play Integrity token returned from Google Play Services.
  public let token: String?
  /// The client data hash bound within the device attestation statement.
  public let clientDataHash: String?

  /// Initializes a new device integrity proof.
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
  public static let stub: DeviceIntegrity = DeviceIntegrity(provider: "stub")
}

/// Specifies the payload of the chosen OAuth authentication channel flow.
public enum AuthFlowPayload: Sendable, Equatable {
  /// Web-redirect based flow carrying OAuth auth code and verifiers.
  case web(code: String, state: String, codeVerifier: String)
  /// Native platform SDK sign-in carrying identity tokens.
  case native(idToken: String, state: String, authorizationCode: String?)
}

/// Request parameters to complete the sign-in flow and issue user session tokens.
public struct OAuthCompleteRequest: Encodable, Sendable, Equatable {
  /// The native device OS platform.
  public let platform: String
  /// The platform OS release version string.
  public let osVersion: String
  /// The bundle identifier or package name.
  public let appBundleId: String
  /// The device integrity proof details.
  public let deviceIntegrity: DeviceIntegrity
  /// The selected flow-specific payload.
  public let payload: AuthFlowPayload

  /// Initializes a complete OAuth request structure.
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

  /// Coding keys map custom JSON properties for server endpoint compatibility.
  enum CodingKeys: String, CodingKey {
    case platform, osVersion, appBundleId, deviceIntegrity
    case flowType = "flow_type"
    case code, state, codeVerifier, idToken, authorizationCode
  }

  /// Encodes the request fields dynamically based on the flow payload type.
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
    case .native(let idToken, let state, let authorizationCode):
      try container.encode("native", forKey: .flowType)
      try container.encode(idToken, forKey: .idToken)
      try container.encode(state, forKey: .state)
      try container.encodeIfPresent(authorizationCode, forKey: .authorizationCode)
    }
  }
}

/// The session response payload issued by the backend after successful OAuth verification.
public struct OAuthCompleteResponse: Codable, Sendable, Equatable {
  /// The authorization access token.
  public let accessToken: String
  /// The authorization refresh token used to renew expired access tokens.
  public let refreshToken: String
  /// The identifier representing the user.
  public let userId: String
  /// The JWT payload verifying user signature attributes.
  public let jwt: String
  /// The cryptographic salt value linked to the user's zkLogin account.
  public let salt: String

  /// Initializes a complete OAuth response.
  public init(
    accessToken: String,
    refreshToken: String,
    userId: String,
    jwt: String,
    salt: String
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.userId = userId
    self.jwt = jwt
    self.salt = salt
  }
}

/// Request parameters to refresh an expired access token.
public struct RefreshRequest: Codable, Sendable, Equatable {
  /// The active refresh token.
  public let refreshToken: String

  /// Initializes a token refresh request.
  public init(refreshToken: String) {
    self.refreshToken = refreshToken
  }
}

/// Response carrying the rotated access and refresh token credentials.
public struct RefreshResponse: Codable, Sendable, Equatable {
  /// The newly generated access token.
  public let accessToken: String
  /// The newly generated refresh token.
  public let refreshToken: String

  /// Initializes a token refresh response.
  public init(accessToken: String, refreshToken: String) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
}

/// Request parameters to submit standalone device integrity assertions.
public struct IntegrityRequest: Codable, Sendable, Equatable {
  /// The device integrity proof details.
  public let deviceIntegrity: DeviceIntegrity
  /// Current epoch timestamp in milliseconds.
  public let timestampMs: Int64

  /// Initializes an integrity verification request.
  public init(deviceIntegrity: DeviceIntegrity, timestampMs: Int64) {
    self.deviceIntegrity = deviceIntegrity
    self.timestampMs = timestampMs
  }
}

/// Request parameters to issue a signed cryptographic device credential.
public struct CredentialRequest: Codable, Sendable, Equatable {
  /// The public key representing local client-side signing proofs (SubjectPublicKeyInfo).
  public let localProofPublicKey: String
  /// Optional user identifier name resolved via Sui Name Service.
  public let suinsName: String?
  /// Set to `true` to request Nearby Assist service capabilities.
  public let nearbyAssist: Bool

  /// Initializes a credential issuance request.
  public init(
    localProofPublicKey: String,
    suinsName: String? = nil,
    nearbyAssist: Bool = false
  ) {
    self.localProofPublicKey = localProofPublicKey
    self.suinsName = suinsName
    self.nearbyAssist = nearbyAssist
  }
}

/// The system access capability scopes granted to the credential.
public struct DeviceCredentialCapabilities: Codable, Sendable, Equatable {
  /// Access scope authorizing nearby transaction payments.
  public let nearbyPayments: Bool
  /// Access scope authorizing nearby user assistance.
  public let nearbyAssist: Bool
}

/// A structured cryptographic identity credential returned and signed by the backend.
public struct DeviceCredential: Codable, Sendable, Equatable {
  /// Schema format version number.
  public let version: Int
  /// The credential subject user identifier.
  public let userId: String
  /// The unique device identifier.
  public let platform: String
  /// The application package bundle identifier.
  public let appBundleId: String
  /// The hardware integrity scheme used during issuance.
  public let integrityProvider: String
  /// The client public key authorized to issue local verification signatures.
  public let localProofPublicKey: String
  /// The user's derived zkLogin public address on the Sui blockchain.
  public let suiAddress: String
  /// The user's resolved SuiNS domain name.
  public let suinsName: String
  /// Granted credential access permissions.
  public let capabilities: DeviceCredentialCapabilities
  /// Epoch timestamp in milliseconds indicating when the credential was issued.
  public let issuedAt: Int64
  /// Epoch timestamp in milliseconds indicating when the credential expires.
  public let expiresAt: Int64
  /// The backend server issuer identifier URI.
  public let issuer: String
  /// The backend server authority signature verifying the credential fields.
  public let signature: String
}
