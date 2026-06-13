//
//  Event.swift
//  LeanSuiApi
//
//  Owned event domain DTO + filter. Mirrors the Sui Move event model.
//

import Foundation

/// A Move event emitted by a transaction.
public struct SuiEvent: Sendable, Equatable {
  /// Package address of the module that emitted the event.
  public let packageId: String?
  /// Module name that emitted the event.
  public let transactionModule: String?
  /// Sender address.
  public let sender: String?
  /// Fully-qualified Move type of the event, e.g. `0x2::foo::BarEvent`.
  public let type: String?
  /// Parsed JSON of the event contents (raw JSON scalar string).
  public let json: String?
  /// Base64-encoded BCS of the event contents.
  public let bcs: String?
  public let timestamp: Date?

  public init(
    packageId: String?,
    transactionModule: String?,
    sender: String?,
    type: String?,
    json: String?,
    bcs: String?,
    timestamp: Date?
  ) {
    self.packageId = packageId
    self.transactionModule = transactionModule
    self.sender = sender
    self.type = type
    self.json = json
    self.bcs = bcs
    self.timestamp = timestamp
  }
}

/// Filter for ``GraphQLSuiProvider/queryEvents(filter:limit:cursor:order:)``.
///
/// At least one field should be set; an empty filter is generally rejected by
/// the node (the GraphQL `EventFilter` is required).
public struct SuiEventFilter: Sendable, Equatable {
  public var sender: String?
  public var transactionModule: String?
  /// Fully-qualified Move event type, e.g. `0x2::foo::BarEvent`.
  public var eventType: String?
  public var afterCheckpoint: UInt64?
  public var atCheckpoint: UInt64?
  public var beforeCheckpoint: UInt64?

  public init(
    sender: String? = nil,
    transactionModule: String? = nil,
    eventType: String? = nil,
    afterCheckpoint: UInt64? = nil,
    atCheckpoint: UInt64? = nil,
    beforeCheckpoint: UInt64? = nil
  ) {
    self.sender = sender
    self.transactionModule = transactionModule
    self.eventType = eventType
    self.afterCheckpoint = afterCheckpoint
    self.atCheckpoint = atCheckpoint
    self.beforeCheckpoint = beforeCheckpoint
  }
}
