import Foundation
import LeanSuiApi

/// IO boundary for SuiNS forward resolution (`name.sui` → address). Wraps a GraphQL provider.
actor RecipientService {
  private let provider: GraphQLSuiProvider

  init(network: SuiNetworkKind) {
    self.provider = GraphQLSuiProvider(network: SuiNetwork(kind: network))
  }

  /// The address a SuiNS name points at, or nil if the name is unregistered. Uses the non-optional
  /// `…OrEmpty` variant so iOS and Android share one bridge-safe path ("" = unregistered).
  func resolve(name: String) async throws -> String? {
    let address = try await provider.resolveNameServiceAddressOrEmpty(name: name)
    return address.isEmpty ? nil : address
  }
}
