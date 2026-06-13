import Foundation

// MARK: - Me / Profile Models

/// Request payload to bind a derived Sui address to the user account.
public struct BindWalletRequest: Codable, Sendable, Equatable {
  /// The zkLogin-derived Sui address to bind.
  public let suiAddress: String

  /// Initializes a new `BindWalletRequest`.
  public init(suiAddress: String) {
    self.suiAddress = suiAddress
  }
}

/// User profile metadata returned by the backend.
public struct UserProfileResponse: Codable, Sendable, Equatable {
  /// The user's unique identifier.
  public let userId: String
  /// The current account status (e.g. "active").
  public let status: String
  /// The decentralized storage URL of the user's avatar.
  public let avatarUrl: String?
  /// Epoch timestamp in seconds indicating when the account was created.
  public let createdAt: Int64

  /// Initializes a new `UserProfileResponse`.
  public init(userId: String, status: String, avatarUrl: String? = nil, createdAt: Int64) {
    self.userId = userId
    self.status = status
    self.avatarUrl = avatarUrl
    self.createdAt = createdAt
  }
}

/// Response returned after successfully uploading an avatar.
public struct AvatarUploadResponse: Codable, Sendable, Equatable {
  /// The public URL to the uploaded avatar blob.
  public let avatarUrl: String

  /// Initializes a new `AvatarUploadResponse`.
  public init(avatarUrl: String) {
    self.avatarUrl = avatarUrl
  }
}

// MARK: - Names / Naming Service Models

/// Response indicating the availability of a requested leaf name.
public struct NameAvailabilityResponse: Codable, Sendable, Equatable {
  /// The fully-qualified name (e.g., "alice.nearby").
  public let name: String
  /// Whether the name is available for registration.
  public let available: Bool

  /// Initializes a new `NameAvailabilityResponse`.
  public init(name: String, available: Bool) {
    self.name = name
    self.available = available
  }
}

/// Request parameters to register a new leaf name under nearby.sui.
public struct RegisterLeafRequest: Codable, Sendable, Equatable {
  /// The leaf name to register (e.g., "alice").
  public let leafName: String

  /// Initializes a new `RegisterLeafRequest`.
  public init(leafName: String) {
    self.leafName = leafName
  }
}

/// Response returned when a leaf name registration task is successfully scheduled.
public struct RegisterLeafResponse: Codable, Sendable, Equatable {
  /// The unique identifier of the background queue task.
  public let taskId: String
  /// The cryptographic hash of the name.
  public let nameHash: String
  /// The action type being executed.
  public let action: String
  /// The initial status of the task.
  public let status: String
  /// Epoch expiration timestamp in seconds.
  public let expiresAt: Int64

  /// Initializes a new `RegisterLeafResponse`.
  public init(taskId: String, nameHash: String, action: String, status: String, expiresAt: Int64) {
    self.taskId = taskId
    self.nameHash = nameHash
    self.action = action
    self.status = status
    self.expiresAt = expiresAt
  }
}

/// Status payload returned when querying a name registration background task.
public struct NameTaskStatusResponse: Codable, Sendable, Equatable {
  /// The background queue task identifier.
  public let taskId: String
  /// The cryptographic hash of the name.
  public let nameHash: String
  /// The task action.
  public let action: String
  /// The current state of the task (e.g., "pending", "confirmed", "failed").
  public let status: String
  /// Epoch creation timestamp in seconds.
  public let createdAt: Int64
  /// Epoch last update timestamp in seconds.
  public let updatedAt: Int64
  /// Epoch expiration timestamp in seconds.
  public let expiresAt: Int64

  /// Initializes a new `NameTaskStatusResponse`.
  public init(
    taskId: String,
    nameHash: String,
    action: String,
    status: String,
    createdAt: Int64,
    updatedAt: Int64,
    expiresAt: Int64
  ) {
    self.taskId = taskId
    self.nameHash = nameHash
    self.action = action
    self.status = status
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.expiresAt = expiresAt
  }
}
