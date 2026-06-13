//
//  SuiNetwork.swift
//  LeanSuiApi
//
//  Replaces SuiKit's `ConnectionProtocol`. The provider only ever needs a
//  GraphQL endpoint URL, so the configuration surface is just that.
//

import Foundation

/// A well-known Sui network. Carries no associated values so it bridges
/// cleanly to Java; a custom endpoint is expressed via ``SuiNetwork``'s
/// convenience initializer instead.
public enum SuiNetworkKind: Sendable, Equatable {
  case mainnet
  case testnet
  case devnet

  /// The default GraphQL endpoint for this network.
  var graphQLEndpoint: URL {
    switch self {
    case .mainnet: return URL(string: "https://graphql.mainnet.sui.io/graphql")!
    case .testnet: return URL(string: "https://graphql.testnet.sui.io/graphql")!
    case .devnet: return URL(string: "https://graphql.devnet.sui.io/graphql")!
    }
  }
}

/// The Sui network a ``GraphQLSuiProvider`` talks to.
///
/// Construct with a ``SuiNetworkKind`` and, optionally, an `endpoint` string
/// that overrides the kind's default GraphQL endpoint.
public final class SuiNetwork: Sendable {
  /// The well-known network kind.
  public let kind: SuiNetworkKind

  /// The GraphQL endpoint this network resolves to.
  let graphQLEndpoint: URL

  /// The GraphQL endpoint as a bridge-friendly string (a `URL` doesn't cross the swift-java
  /// boundary). Use this when constructing clients that take a URL string (e.g. `SuiGraphQLClient`).
  public var graphQLEndpointString: String { graphQLEndpoint.absoluteString }

  /// - Parameters:
  ///   - kind: The well-known network.
  ///   - endpoint: An optional GraphQL endpoint URL string that overrides the
  ///     kind's default. Ignored if `nil` or not a valid URL.
  public init(kind: SuiNetworkKind, endpoint: String? = nil) {
    self.kind = kind
    if let endpoint, let url = URL(string: endpoint) {
      self.graphQLEndpoint = url
    } else {
      self.graphQLEndpoint = kind.graphQLEndpoint
    }
  }

  /// Convenience accessors for the well-known networks.
  public static var mainnet: SuiNetwork { SuiNetwork(kind: .mainnet) }
  public static var testnet: SuiNetwork { SuiNetwork(kind: .testnet) }
  public static var devnet: SuiNetwork { SuiNetwork(kind: .devnet) }
}

/// Sort order for paginated queries.
public enum SortOrder: Sendable, Equatable {
  case ascending
  case descending
}
