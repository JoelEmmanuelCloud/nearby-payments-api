import Foundation

/// Resolves a Sui address to its default Sui Name Service (SuiNS) domain name. `GraphQLSuiProvider`
/// conforms natively below, so the abstraction is owned by the module that owns the type — no
/// retroactive conformance in consuming layers (which breaks swift-java's Java generation).
public protocol SuiNSResolverProtocol: Sendable {
  /// Resolves a 32-byte hex address to its default domain name.
  func resolveNameServiceNames(address: String) async throws -> String?
  /// Resolves a domain name to its 32-byte hex address.
  func resolveNameServiceAddress(name: String) async throws -> String?
}
