//
//  MoveNormalized.swift
//  LeanSuiApi
//
//  Owned normalized-Move domain DTOs (function / struct / module signatures).
//  Type signatures are surfaced as their raw `OpenMoveTypeSignature` JSON
//  strings; callers that need a parsed type tree can decode them.
//

import Foundation

/// Visibility of a Move function.
public enum SuiMoveVisibility: String, Sendable, Equatable {
  case `public`
  case `private`
  case friend
}

/// A Move ability.
public enum SuiMoveAbility: String, Sendable, Equatable {
  case copy
  case drop
  case key
  case store
}

/// A type parameter of a Move function: its ability constraints.
///
/// Wraps the inner ability list in a named struct (rather than a nested array)
/// so the type bridges cleanly to Java via swift-java/jextract.
public struct SuiMoveFunctionTypeParameter: Sendable, Equatable {
  public let constraints: [SuiMoveAbility]

  public init(constraints: [SuiMoveAbility]) {
    self.constraints = constraints
  }
}

/// A normalized Move function signature.
public struct SuiMoveNormalizedFunction: Sendable, Equatable {
  public let name: String
  public let visibility: SuiMoveVisibility?
  public let isEntry: Bool?
  /// Parameter type signatures (raw `OpenMoveTypeSignature` JSON strings).
  public let parameters: [String]
  /// Per-type-parameter ability constraints.
  public let typeParameters: [SuiMoveFunctionTypeParameter]
  /// Return type signatures (raw JSON strings).
  public let returns: [String]

  public init(
    name: String,
    visibility: SuiMoveVisibility?,
    isEntry: Bool?,
    parameters: [String],
    typeParameters: [SuiMoveFunctionTypeParameter],
    returns: [String]
  ) {
    self.name = name
    self.visibility = visibility
    self.isEntry = isEntry
    self.parameters = parameters
    self.typeParameters = typeParameters
    self.returns = returns
  }
}

/// A field of a Move struct.
public struct SuiMoveNormalizedField: Sendable, Equatable {
  public let name: String?
  /// Field type signature (raw `OpenMoveTypeSignature` JSON string).
  public let signature: String?

  public init(name: String?, signature: String?) {
    self.name = name
    self.signature = signature
  }
}

/// A type parameter of a Move struct.
public struct SuiMoveStructTypeParameter: Sendable, Equatable {
  public let isPhantom: Bool
  public let constraints: [SuiMoveAbility]

  public init(isPhantom: Bool, constraints: [SuiMoveAbility]) {
    self.isPhantom = isPhantom
    self.constraints = constraints
  }
}

/// A normalized Move struct.
public struct SuiMoveNormalizedStruct: Sendable, Equatable {
  public let name: String
  public let abilities: [SuiMoveAbility]
  public let fields: [SuiMoveNormalizedField]
  public let typeParameters: [SuiMoveStructTypeParameter]

  public init(
    name: String,
    abilities: [SuiMoveAbility],
    fields: [SuiMoveNormalizedField],
    typeParameters: [SuiMoveStructTypeParameter]
  ) {
    self.name = name
    self.abilities = abilities
    self.fields = fields
    self.typeParameters = typeParameters
  }
}

/// A normalized Move module.
public struct SuiMoveNormalizedModule: Sendable, Equatable {
  public let name: String
  public let fileFormatVersion: Int?
  public let functions: [SuiMoveNormalizedFunction]
  public let structs: [SuiMoveNormalizedStruct]

  public init(
    name: String,
    fileFormatVersion: Int?,
    functions: [SuiMoveNormalizedFunction],
    structs: [SuiMoveNormalizedStruct]
  ) {
    self.name = name
    self.fileFormatVersion = fileFormatVersion
    self.functions = functions
    self.structs = structs
  }
}
