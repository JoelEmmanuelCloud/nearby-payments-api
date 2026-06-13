//
//  Activity.swift
//  LeanSuiApi
//
//  Higher-level "account activity" DTOs: a transaction folded into a single, display-ready row from
//  one address's perspective (direction, counterparty, scaled amount), plus the full per-coin detail.
//  Produced by `GraphQLSuiProvider.getActivity`; consumed verbatim by each client UI.
//

import Foundation

/// Which way value moved, from the queried address's perspective.
public enum SuiActivityDirection: String, Codable, Sendable, Equatable {
  case sent
  case received
}

/// One party's net delta of a single coin in a transaction, scaled to human units and pre-formatted.
public struct SuiActivityCoinChange: Codable, Sendable, Equatable {
  public let owner: String?
  public let coinType: String
  public let coinSymbol: String
  /// Signed, scaled display amount, e.g. "+12.50" or "-12.50".
  public let amount: String

  public init(owner: String?, coinType: String, coinSymbol: String, amount: String) {
    self.owner = owner
    self.coinType = coinType
    self.coinSymbol = coinSymbol
    self.amount = amount
  }
}

/// The expanded detail behind a `SuiActivity` row (for a tap-through detail screen).
public struct SuiActivityDetail: Codable, Sendable, Equatable {
  public let digest: String
  public let sender: String?
  public let succeeded: Bool
  public let executionError: String?
  public let timestamp: Date?
  /// Every party's change of the activity's coin in this transaction (scaled).
  public let coinChanges: [SuiActivityCoinChange]

  public init(
    digest: String,
    sender: String?,
    succeeded: Bool,
    executionError: String?,
    timestamp: Date?,
    coinChanges: [SuiActivityCoinChange]
  ) {
    self.digest = digest
    self.sender = sender
    self.succeeded = succeeded
    self.executionError = executionError
    self.timestamp = timestamp
    self.coinChanges = coinChanges
  }
}

/// A single account-activity row for one coin, ready to render.
public struct SuiActivity: Codable, Sendable, Equatable {
  public let digest: String
  public let direction: SuiActivityDirection
  /// Magnitude, scaled + formatted to a fixed 2 fraction digits, e.g. "12.50".
  public let amount: String
  public let coinType: String
  public let coinSymbol: String
  /// The other party — recipient when `sent`, sender when `received` — if resolvable.
  public let counterparty: String?
  public let succeeded: Bool
  public let timestamp: Date?
  public let details: SuiActivityDetail

  public init(
    digest: String,
    direction: SuiActivityDirection,
    amount: String,
    coinType: String,
    coinSymbol: String,
    counterparty: String?,
    succeeded: Bool,
    timestamp: Date?,
    details: SuiActivityDetail
  ) {
    self.digest = digest
    self.direction = direction
    self.amount = amount
    self.coinType = coinType
    self.coinSymbol = coinSymbol
    self.counterparty = counterparty
    self.succeeded = succeeded
    self.timestamp = timestamp
    self.details = details
  }
}

/// A page of activity rows plus its forward-scroll cursor.
///
/// A concrete type, not `Page<SuiActivity>`: swift-java can't bridge a generic `Page`'s `[T]` array
/// (only `pageInfo` crosses), so the Android client could never read the rows. A concrete struct with
/// a concrete `[SuiActivity]` array bridges cleanly. Continue with `nextCursor` while `hasMore`.
public struct SuiActivityFeed: Codable, Sendable, Equatable {
  public let items: [SuiActivity]
  public let nextCursor: String?
  public let hasMore: Bool

  public init(items: [SuiActivity], nextCursor: String?, hasMore: Bool) {
    self.items = items
    self.nextCursor = nextCursor
    self.hasMore = hasMore
  }
}
