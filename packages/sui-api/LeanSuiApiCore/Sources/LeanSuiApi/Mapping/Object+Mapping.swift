//
//  Object+Mapping.swift
//  LeanSuiApi
//
//  Conversions from the object fragments to the object domain DTOs.
//  `getObject` / `multiGetObjects` use `RPC_OBJECT_FIELDS` (contents nested
//  under `asMoveObject`); `getOwnedObjects` uses `RPC_MOVE_OBJECT_FIELDS`
//  (contents at top level). Owner shape is shared via `RPC_OBJECT_OWNER_FIELDS`.
//

import Foundation

extension ObjectOwner {
  init(graphql o: RPC_OBJECT_OWNER_FIELDS) {
    if let a = o.asAddressOwner?.address?.address {
      self = .address(a)
    } else if let obj = o.asObjectOwner?.address?.address {
      self = .object(obj)
    } else if let consensus = o.asConsensusAddressOwner?.address?.address {
      self = .address(consensus)
    } else if let shared = o.asShared {
      let v = (try? Scalars.uInt64(shared.initialSharedVersion ?? "0")) ?? 0
      self = .shared(initialSharedVersion: v)
    } else if o.asImmutable != nil {
      self = .immutable
    } else {
      self = .unknown
    }
  }
}

extension PageInfo {
  init(graphql p: GetOwnedObjectsQuery.Data.Address.Objects.PageInfo) {
    self.init(
      hasNextPage: p.hasNextPage, hasPreviousPage: false, startCursor: nil, endCursor: p.endCursor)
  }
}

extension SuiObjectData {
  /// From `RPC_OBJECT_FIELDS` (getObject / multiGetObjects).
  init(graphql f: RPC_OBJECT_FIELDS) throws {
    let mo = f.asMoveObject
    let type =
      mo?.ifShowType?.contents?.type?.repr
      ?? mo?.ifShowContent?.contents?.type?.repr
      ?? mo?.ifShowBcs?.contents?.type?.repr
    let hasPublicTransfer = mo?.ifShowContent?.hasPublicTransfer ?? mo?.ifShowBcs?.hasPublicTransfer
    let bcs = mo?.ifShowBcs?.contents?.bcs
    let display = mo?.ifShowContent?.contents?.display?.output?.string
    let version = try Scalars.uInt64(require(f.version, "object.version"), field: "object.version")
    let storageRebate = try f.storageRebate.map {
      try Scalars.uInt64($0, field: "object.storageRebate")
    }

    self.init(
      objectId: f.objectId,
      version: version,
      digest: f.digest,
      type: type,
      hasPublicTransfer: hasPublicTransfer,
      owner: f.owner.map { ObjectOwner(graphql: $0.fragments.rPC_OBJECT_OWNER_FIELDS) },
      bcs: bcs,
      previousTransaction: f.previousTransaction?.digest,
      storageRebate: storageRebate,
      display: display
    )
  }

  /// From `RPC_MOVE_OBJECT_FIELDS` (getOwnedObjects).
  init(graphql f: RPC_MOVE_OBJECT_FIELDS) throws {
    let c = f.contents
    let type =
      c?.ifShowType?.type?.repr
      ?? c?.ifShowContent?.type?.repr
      ?? c?.ifShowBcs?.type?.repr
    let bcs = c?.ifShowBcs?.bcs
    let display = c?.ifShowContent?.display?.output?.string
    let version = try Scalars.uInt64(require(f.version, "object.version"), field: "object.version")
    let storageRebate = try f.storageRebate.map {
      try Scalars.uInt64($0, field: "object.storageRebate")
    }

    self.init(
      objectId: f.objectId,
      version: version,
      digest: f.digest,
      type: type,
      hasPublicTransfer: f.hasPublicTransfer,
      owner: f.owner.map { ObjectOwner(graphql: $0.fragments.rPC_OBJECT_OWNER_FIELDS) },
      bcs: bcs,
      previousTransaction: f.previousTransaction?.digest,
      storageRebate: storageRebate,
      display: display
    )
  }
}
