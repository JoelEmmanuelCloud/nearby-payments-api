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
  internal static func fetchQuery<T: GraphQLQuery>(
    client: ApolloClient,
    query: T
  ) async throws -> GraphQLResponse<T> where T.ResponseFormat == SingleResponseFormat {
    try await client.fetch(query: query)
  }

  /// Perform a mutation and return its response (`data` / `errors`).
  internal static func performMutation<T: GraphQLMutation>(
    client: ApolloClient,
    mutation: T
  ) async throws -> GraphQLResponse<T> where T.ResponseFormat == SingleResponseFormat {
    try await client.perform(mutation: mutation)
  }
}
