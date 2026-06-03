//
//  Pagination.swift
//  LeanSuiApi
//
//  Owned pagination DTOs. Mirrors the GraphQL `PageInfo` connection shape.
//

import Foundation

/// Cursor pagination info, mirroring GraphQL Relay-style `PageInfo`.
public struct PageInfo: Sendable, Equatable {
  public let hasNextPage: Bool
  public let hasPreviousPage: Bool
  public let startCursor: String?
  public let endCursor: String?

  public init(
    hasNextPage: Bool = false,
    hasPreviousPage: Bool = false,
    startCursor: String? = nil,
    endCursor: String? = nil
  ) {
    self.hasNextPage = hasNextPage
    self.hasPreviousPage = hasPreviousPage
    self.startCursor = startCursor
    self.endCursor = endCursor
  }
}

/// A generic page of `T` plus its pagination cursor.
///
/// swift-java/jextract only exports generics through concrete, named
/// instantiations (see the typealiases below), never as an open `Page<T>`.
public struct Page<T: Sendable>: Sendable {
  public let data: [T]
  public let pageInfo: PageInfo

  public init(data: [T], pageInfo: PageInfo) {
    self.data = data
    self.pageInfo = pageInfo
  }
}

// Concrete page instantiations exposed to Java. Each provider method that
// returns a page uses one of these named typealiases so the bridge sees a
// concrete type rather than an open generic.
public typealias CoinBalancePage = Page<CoinBalance>
public typealias CoinStructPage = Page<CoinStruct>
public typealias CheckpointPage = Page<Checkpoint>
public typealias SuiObjectResponsePage = Page<SuiObjectResponse>
public typealias SuiTransactionBlockResponsePage = Page<SuiTransactionBlockResponse>
public typealias SuiEventPage = Page<SuiEvent>
public typealias DynamicFieldPage = Page<DynamicFieldInfo>
