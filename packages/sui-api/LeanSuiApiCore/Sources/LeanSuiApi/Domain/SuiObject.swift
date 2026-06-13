//
//  SuiObject.swift
//  LeanSuiApi
//
//  Owned object domain DTOs. Mirrors the canonical Sui object model
//  (SuiObjectResponse / SuiObjectData / ObjectOwner), the same shape used by
//  ksui, SuiKit, and the TS SDK. Version is `u64`; storageRebate is `u64`.
//

import Foundation

/// On-chain ownership of an object.
public enum ObjectOwner: Sendable, Equatable {
  /// Owned by an account address.
  case address(String)
  /// Owned by another object (dynamic field / wrapped), identified by parent address.
  case object(String)
  /// A shared object, with the version it became shared at.
  case shared(initialSharedVersion: UInt64)
  /// An immutable (frozen) object.
  case immutable
  /// Owner present on-chain but not one of the known shapes.
  case unknown
}

/// Options controlling which optional fields the object queries fetch.
public struct SuiObjectDataOptions: Sendable, Equatable {
  public var showBcs: Bool
  public var showOwner: Bool
  public var showPreviousTransaction: Bool
  public var showContent: Bool
  public var showType: Bool
  public var showDisplay: Bool
  public var showStorageRebate: Bool

  public init(
    showBcs: Bool = false,
    showOwner: Bool = false,
    showPreviousTransaction: Bool = false,
    showContent: Bool = false,
    showType: Bool = false,
    showDisplay: Bool = false,
    showStorageRebate: Bool = false
  ) {
    self.showBcs = showBcs
    self.showOwner = showOwner
    self.showPreviousTransaction = showPreviousTransaction
    self.showContent = showContent
    self.showType = showType
    self.showDisplay = showDisplay
    self.showStorageRebate = showStorageRebate
  }

  /// Convenience requesting all fields.
  public static var all: SuiObjectDataOptions {
    SuiObjectDataOptions(
      showBcs: true, showOwner: true, showPreviousTransaction: true,
      showContent: true, showType: true, showDisplay: true, showStorageRebate: true
    )
  }
}

/// Data for a single on-chain object.
public struct SuiObjectData: Sendable, Equatable {
  public let objectId: String
  public let version: UInt64
  public let digest: String?
  /// Fully-qualified Move type of the object's contents, e.g. `0x2::coin::Coin<...>`.
  public let type: String?
  public let hasPublicTransfer: Bool?
  public let owner: ObjectOwner?
  /// Base64-encoded BCS of the object contents.
  public let bcs: String?
  public let previousTransaction: String?
  public let storageRebate: UInt64?
  /// Raw JSON of the object's display output (Sui object display standard), if requested.
  public let display: String?

  public init(
    objectId: String,
    version: UInt64,
    digest: String?,
    type: String?,
    hasPublicTransfer: Bool?,
    owner: ObjectOwner?,
    bcs: String?,
    previousTransaction: String?,
    storageRebate: UInt64?,
    display: String?
  ) {
    self.objectId = objectId
    self.version = version
    self.digest = digest
    self.type = type
    self.hasPublicTransfer = hasPublicTransfer
    self.owner = owner
    self.bcs = bcs
    self.previousTransaction = previousTransaction
    self.storageRebate = storageRebate
    self.display = display
  }
}

/// Response wrapper for an object lookup (data or error).
public struct SuiObjectResponse: Sendable, Equatable {
  public let data: SuiObjectData?
  public let error: String?

  public init(data: SuiObjectData?, error: String?) {
    self.data = data
    self.error = error
  }
}
