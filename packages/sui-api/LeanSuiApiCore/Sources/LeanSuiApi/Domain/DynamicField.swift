//
//  DynamicField.swift
//  LeanSuiApi
//
//  Owned dynamic-field DTO.
//

import Foundation

/// A dynamic field owned by an object.
public struct DynamicFieldInfo: Sendable, Equatable {
  /// Fully-qualified Move type of the field name.
  public let nameType: String?
  /// Raw JSON of the field name.
  public let nameJSON: String?
  /// Base64-encoded BCS of the field name.
  public let nameBcs: String?
  /// Fully-qualified Move type of the value.
  public let valueType: String?
  /// Raw JSON of the value (for `MoveValue` dynamic fields).
  public let valueJSON: String?
  /// Object id of the value (for `MoveObject` dynamic object fields).
  public let objectId: String?
  public let objectDigest: String?
  public let objectVersion: UInt64?

  public init(
    nameType: String?,
    nameJSON: String?,
    nameBcs: String?,
    valueType: String?,
    valueJSON: String?,
    objectId: String?,
    objectDigest: String?,
    objectVersion: UInt64?
  ) {
    self.nameType = nameType
    self.nameJSON = nameJSON
    self.nameBcs = nameBcs
    self.valueType = valueType
    self.valueJSON = valueJSON
    self.objectId = objectId
    self.objectDigest = objectDigest
    self.objectVersion = objectVersion
  }
}
