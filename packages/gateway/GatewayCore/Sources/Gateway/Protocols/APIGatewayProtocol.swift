import Foundation

/// Defines a protocol for communicating with the backend API service.
///
/// Implementations of this protocol are responsible for server-side key retrieval, OAuth handshakes,
/// token rotations, session revocation, integrity verification, and secure credential issuance.
public protocol APIGatewayProtocol: Sendable {

  /// Fetches the public key used by the backend to sign device credentials.
  ///
  /// - Returns: A response containing the server public key string.
  /// - Throws: An error if fetching or decoding fails.
  func serverPublicKey() async throws -> ServerPublicKeyResponse

  /// Begins the OAuth flow by registering a challenge and nonce.
  ///
  /// - Parameter request: The oauth initialization parameters.
  /// - Returns: A response containing the authorization URL and state token.
  /// - Throws: An error if the request fails.
  func beginOAuth(request: OAuthBeginRequest) async throws -> OAuthBeginResponse

  /// Completes the sign-in sequence, exchanging proof details for session credentials.
  ///
  /// - Parameter request: Completed sign-in parameters and device integrity proof.
  /// - Returns: Session response containing OAuth access and refresh tokens.
  /// - Throws: An error if verification fails.
  func completeOAuth(request: OAuthCompleteRequest) async throws -> OAuthCompleteResponse

  /// Renews an expired access token using an active refresh token.
  ///
  /// - Parameters:
  ///   - request: Token refresh request details.
  ///   - accessToken: The current authorization token.
  /// - Returns: The response containing rotated token strings.
  /// - Throws: An error if refresh fails.
  func refresh(
    request: RefreshRequest,
    accessToken: String
  ) async throws -> RefreshResponse

  /// Revokes an active session token, logging the user out server-side.
  ///
  /// - Parameter accessToken: The token to revoke.
  /// - Throws: An error if revocation fails.
  func revoke(accessToken: String) async throws

  /// Submits device integrity attestation assertions for separate validation.
  ///
  /// - Parameters:
  ///   - request: Integrity assertion and request timestamp.
  ///   - accessToken: Active access token.
  ///   - deviceProvider: The name of the device provider (e.g. apple_app_attest, play_integrity).
  ///   - requestNonce: The verification nonce challenge.
  ///   - requestTimestamp: Current time indicating assertion timestamp.
  /// - Throws: An error if verification fails.
  func assertIntegrity(
    request: IntegrityRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws

  /// Requests the issuance of a signed device credential linked to a client proof key.
  ///
  /// - Parameters:
  ///   - request: The credential request parameters.
  ///   - accessToken: Active access token.
  ///   - deviceProvider: The name of the device integrity provider.
  ///   - requestNonce: The verification nonce challenge.
  ///   - requestTimestamp: Current timestamp.
  /// - Returns: The issued and signed `DeviceCredential` structure.
  /// - Throws: An error if credential generation or validation fails.
  func issueCredential(
    request: CredentialRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws -> DeviceCredential

  /// Binds a zkLogin-derived Sui address to the authenticated user.
  ///
  /// - Parameters:
  ///   - request: The bind wallet request details.
  ///   - accessToken: The active authorization access token.
  /// - Throws: `GatewayError` if the request fails.
  func bindWallet(request: BindWalletRequest, accessToken: String) async throws

  /// Retrieves the user profile metadata.
  ///
  /// - Parameter accessToken: The active authorization access token.
  /// - Returns: The user's profile metadata.
  /// - Throws: `GatewayError` if the request fails.
  func getProfile(accessToken: String) async throws -> UserProfileResponse

  /// Uploads a binary avatar image for the user.
  ///
  /// - Parameters:
  ///   - data: The raw binary data of the image.
  ///   - contentType: The MIME type of the image (e.g. "image/jpeg").
  ///   - accessToken: The active authorization access token.
  /// - Returns: The response containing the public URL to the uploaded avatar.
  /// - Throws: `GatewayError` if the upload fails.
  func uploadAvatar(
    data: Data,
    contentType: String,
    accessToken: String
  ) async throws -> AvatarUploadResponse

  /// Checks the availability of a leaf name under nearby.sui.
  ///
  /// - Parameters:
  ///   - leafName: The leaf name string to verify.
  ///   - accessToken: The active authorization access token.
  /// - Returns: The availability details response.
  /// - Throws: `GatewayError` if the request fails.
  func checkNameAvailability(leafName: String, accessToken: String) async throws
    -> NameAvailabilityResponse

  /// Schedules a background queue task to register a leaf name under nearby.sui.
  ///
  /// - Parameters:
  ///   - request: The registration parameters containing the leaf name.
  ///   - accessToken: The active authorization access token.
  ///   - deviceProvider: The name of the device integrity provider.
  ///   - requestNonce: The verification nonce challenge.
  ///   - requestTimestamp: Current ISO or millisecond timestamp.
  /// - Returns: The details of the scheduled task.
  /// - Throws: `GatewayError` if the registration request fails.
  func registerLeafName(
    request: RegisterLeafRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws -> RegisterLeafResponse

  /// Retrieves the current status of an asynchronous name registration task.
  ///
  /// - Parameters:
  ///   - taskId: The task identifier to query.
  ///   - accessToken: The active authorization access token.
  ///   - deviceProvider: The name of the device integrity provider.
  ///   - requestNonce: The verification nonce challenge.
  ///   - requestTimestamp: Current ISO or millisecond timestamp.
  /// - Returns: The current status of the task.
  /// - Throws: `GatewayError` if the query fails.
  func getNameTask(
    taskId: String,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws -> NameTaskStatusResponse
}
