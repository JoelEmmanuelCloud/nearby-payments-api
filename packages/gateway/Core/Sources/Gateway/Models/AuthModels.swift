import Foundation

public enum OAuthProvider: String, Codable, Sendable, CaseIterable {
  case google = "google"
  case apple = "apple"
}

public struct ServerPublicKeyResponse: Codable, Sendable, Equatable {
  public let publicKey: String

  public init(publicKey: String) {
    self.publicKey = publicKey
  }
}

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

public struct OAuthBeginResponse: Codable, Sendable, Equatable {
  public let authURL: String
  public let state: String

  public init(authURL: String, state: String) {
    self.authURL = authURL
    self.state = state
  }
}

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

  public static let stub = DeviceIntegrity(provider: "stub")
}

public enum AuthFlowPayload: Sendable, Equatable {
  case web(code: String, state: String, codeVerifier: String)
  case native(idToken: String, authorizationCode: String?)
}

public struct OAuthCompleteRequest: Encodable, Sendable, Equatable {
  public let platform: String
  public let osVersion: String
  public let appBundleId: String
  public let deviceIntegrity: DeviceIntegrity
  public let suiAddress: String?
  public let payload: AuthFlowPayload

  public init(
    platform: String,
    osVersion: String,
    appBundleId: String,
    deviceIntegrity: DeviceIntegrity,
    suiAddress: String? = nil,
    payload: AuthFlowPayload
  ) {
    self.platform = platform
    self.osVersion = osVersion
    self.appBundleId = appBundleId
    self.deviceIntegrity = deviceIntegrity
    self.suiAddress = suiAddress
    self.payload = payload
  }

  enum CodingKeys: String, CodingKey {
    case platform, osVersion, appBundleId, deviceIntegrity, suiAddress
    case flowType = "flow_type"
    case code, state, codeVerifier
    case idToken, authorizationCode
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(platform, forKey: .platform)
    try container.encode(osVersion, forKey: .osVersion)
    try container.encode(appBundleId, forKey: .appBundleId)
    try container.encode(deviceIntegrity, forKey: .deviceIntegrity)
    try container.encodeIfPresent(suiAddress, forKey: .suiAddress)

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

public struct RefreshRequest: Codable, Sendable, Equatable {
  public let refreshToken: String

  public init(refreshToken: String) {
    self.refreshToken = refreshToken
  }
}

public struct RefreshResponse: Codable, Sendable, Equatable {
  public let accessToken: String
  public let refreshToken: String

  public init(accessToken: String, refreshToken: String) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
}

public struct IntegrityRequest: Codable, Sendable, Equatable {
  public let deviceIntegrity: DeviceIntegrity
  public let timestampMs: Int64

  public init(deviceIntegrity: DeviceIntegrity, timestampMs: Int64) {
    self.deviceIntegrity = deviceIntegrity
    self.timestampMs = timestampMs
  }
}

public struct CredentialRequest: Codable, Sendable, Equatable {
  public let localProofPublicKey: String
  public let suinsName: String?
  public let nearbyAssist: Bool

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

public struct DeviceCredentialCapabilities: Codable, Sendable, Equatable {
  public let nearbyPayments: Bool
  public let nearbyAssist: Bool
}

public struct DeviceCredential: Codable, Sendable, Equatable {
  public let version: Int
  public let userId: String
  public let deviceId: String
  public let platform: String
  public let appBundleId: String
  public let integrityProvider: String
  public let localProofPublicKey: String
  public let suiAddress: String
  public let suinsName: String
  public let capabilities: DeviceCredentialCapabilities
  public let issuedAt: Int64
  public let expiresAt: Int64
  public let issuer: String
  public let signature: String
}
