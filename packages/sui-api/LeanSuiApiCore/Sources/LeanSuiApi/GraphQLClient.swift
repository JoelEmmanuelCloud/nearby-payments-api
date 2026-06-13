//
//  GraphQLClient.swift
//  LeanSuiApi
//
//  Thin wrapper over the (forked) Apollo async API. This Apollo version
//  exposes `fetch`/`perform` as `async throws -> GraphQLResponse<Operation>`,
//  so the old callback + `GraphQLResult` bridging is gone.
//

import Apollo
import ApolloAPI
import Foundation

/// A wrapper for querying data from the GraphQL node.
internal enum GraphQLClient {
  /// Fetch a query and return its response (`data` / `errors`).
  ///
  /// Defaults to `.networkOnly`: this is a wallet reading mutable on-chain state (balances, coins,
  /// activity), so a cached response would mean a user sees stale data after a transaction — exactly
  /// what cache-first reads produce on a re-fetch / pull-to-refresh. Network-only still updates the
  /// normalized cache; it just never *serves* a stale read.
  internal static func fetchQuery<T: GraphQLQuery>(
    client: ApolloClient,
    query: T,
    cachePolicy: CachePolicy.Query.SingleResponse = .networkOnly
  ) async throws -> GraphQLResponse<T> where T.ResponseFormat == SingleResponseFormat {
    try await client.fetch(query: query, cachePolicy: cachePolicy)
  }

  /// Perform a mutation and return its response (`data` / `errors`).
  internal static func performMutation<T: GraphQLMutation>(
    client: ApolloClient,
    mutation: T
  ) async throws -> GraphQLResponse<T> where T.ResponseFormat == SingleResponseFormat {
    try await client.perform(mutation: mutation)
  }
}
