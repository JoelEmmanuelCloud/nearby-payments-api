//
//  GraphQLSuiProvider+Activity.swift
//  LeanSuiApi
//
//  Account activity feed: fetch the address's transactions through a lean, cost-bounded list query,
//  fold each into a display-ready `SuiActivity` for one coin, and page through them. The only
//  client-facing entry point for the Activity screen on every platform.
//

import Apollo
import ApolloAPI
import Foundation

extension GraphQLSuiProvider {
  /// Lean transaction-list query, newest-first by default. Same pagination shape as
  /// `queryTransactionBlocks`, but the `ACCOUNT_ACTIVITY_FIELDS` fragment selects only what a row
  /// needs — crucially *not* `events`/`objectChanges`, whose deep selections make the GraphQL cost
  /// estimator reject normal page sizes (it counts those fields even when `@skip`-ped). Fetch full
  /// per-transaction detail on demand via `getTransactionBlock(digest:)`.
  public func queryAccountActivity(
    limit: Int? = nil,
    cursor: String? = nil,
    order: SortOrder = .descending,
    affectedAddress: String? = nil
  ) async throws -> SuiTransactionBlockResponsePage {
    let limit32 = limit.map { Int32($0) }
    let first: GraphQLNullable<Int32>
    let last: GraphQLNullable<Int32>
    let before: GraphQLNullable<String>
    let after: GraphQLNullable<String>
    switch order {
    case .descending:
      first = .null
      last = limit32.map { .some($0) } ?? .null
      before = cursor.map { .some($0) } ?? .null
      after = .null
    case .ascending:
      first = limit32.map { .some($0) } ?? .null
      last = .null
      before = .null
      after = cursor.map { .some($0) } ?? .null
    }

    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: QueryAccountActivityQuery(
        first: first,
        last: last,
        before: before,
        after: after,
        filter: affectedAddress.map { .some(TransactionFilter(affectedAddress: .some($0))) }
          ?? .null
      )
    )
    let txs = try require(result.data?.transactions, "transactions")
    return Page(
      data: try txs.nodes.map {
        try SuiTransactionBlockResponse(activity: $0.fragments.aCCOUNT_ACTIVITY_FIELDS)
      },
      pageInfo: PageInfo(activity: txs.pageInfo)
    )
  }

  /// A page of the address's activity for `coinType`, newest first.
  ///
  /// Scoped to a single coin (the one shown as the account balance): each transaction that moved
  /// `coinType` for `address` becomes one row; unrelated/gas-only transactions surfaced by the
  /// affected-address filter are dropped.
  ///
  /// Infinite scroll: pass `cursor` = nil for the first page, then re-call with the returned
  /// `pageInfo.endCursor` while `pageInfo.hasNextPage` is true.
  ///
  /// - Parameters:
  ///   - address: the account whose activity to fetch.
  ///   - coinType: the coin to scope and scale to (fully-qualified `0x…::module::Struct`).
  ///   - cursor: opaque continuation cursor from a previous page, or nil for the newest page.
  ///   - limit: max transactions to scan per page (rows returned may be fewer after coin filtering).
  public func getActivity(
    address: String,
    coinType: String,
    cursor: String? = nil,
    limit: Int = 25
  ) async throws -> SuiActivityFeed {
    let metadata = try? await getCoinMetadata(coinType: coinType)
    let decimals = metadata?.decimals ?? 6
    let symbol = metadata?.symbol ?? Self.fallbackSymbol(coinType: coinType)

    let page = try await queryAccountActivity(
      limit: limit,
      cursor: cursor,
      order: .descending,
      affectedAddress: address
    )

    let items = page.data.compactMap {
      SuiActivity.make(
        from: $0,
        owner: address,
        coinType: coinType,
        coinSymbol: symbol,
        decimals: decimals
      )
    }

    // The descending query pages backward (`last`/`before`), so "more older rows" is `hasPreviousPage`
    // and the next cursor is `startCursor` — re-exposed as intuitive forward fields, so the client just
    // continues with `nextCursor` while `hasMore`.
    return SuiActivityFeed(
      items: items,
      nextCursor: page.pageInfo.startCursor,
      hasMore: page.pageInfo.hasPreviousPage
    )
  }

  /// Last `::`-segment of the coin type as a display symbol, when on-chain metadata has none.
  private static func fallbackSymbol(coinType: String) -> String {
    coinType.components(separatedBy: "::").last ?? coinType
  }
}
