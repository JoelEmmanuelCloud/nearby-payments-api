/// The Gateway package provides a strictly-typed, protocol-oriented Swift client
/// for the Nearby Payments backend API.
///
/// ## Architecture
///
/// The package is structured around dependency injection to enable full
/// testability without network access:
///
/// - ``AuthGateway``: Protocol defining the auth endpoint contract.
/// - ``APIGateway``: Concrete implementation backed by an ``HTTPClient``.
/// - ``HTTPClient``: Transport abstraction (inject ``URLSessionHTTPClient``
///   in production, or a mock in tests).
///
/// ## Quick Start
///
/// ```swift
/// let config = GatewayConfiguration(
///     baseURL: URL(string: "https://api.nearby.com")!
/// )
/// let gateway = APIGateway(configuration: config)
///
/// let response = try await gateway.beginOAuth(
///     request: OAuthBeginRequest(
///         provider: "google",
///         codeChallenge: challenge,
///         zkLoginNonce: nonce
///     )
/// )
/// ```
///
/// ## Extending for New Domains
///
/// To add endpoints beyond auth (e.g. Payments, Names), define a new
/// protocol (e.g. `PaymentsGateway`), add conformance to ``APIGateway``,
/// and drop the new models into `Models/`.
