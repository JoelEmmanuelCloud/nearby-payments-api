//
//  MoveNormalized+Mapping.swift
//  LeanSuiApi
//
//  Conversions from the `RPC_MOVE_FUNCTION_FIELDS` / `RPC_MOVE_STRUCT_FIELDS` /
//  `RPC_MOVE_MODULE_FIELDS` fragments to the normalized-Move domain DTOs.
//  Module nodes reuse the standalone function/struct fragments, so the
//  function/struct mappings serve both the standalone and module-nested cases.
//

import ApolloAPI
import Foundation

private func mapAbilities(_ raw: [GraphQLEnum<SuiGraphQL.MoveAbility>]?) -> [SuiMoveAbility] {
  (raw ?? []).compactMap { $0.value.flatMap { SuiMoveAbility(rawValue: $0.rawValue) } }
}

extension SuiMoveVisibility {
  init?(graphql v: GraphQLEnum<SuiGraphQL.MoveVisibility>?) {
    guard let raw = v?.value?.rawValue, let mapped = SuiMoveVisibility(rawValue: raw.lowercased())
    else { return nil }
    self = mapped
  }
}

extension SuiMoveNormalizedFunction {
  init(graphql f: RPC_MOVE_FUNCTION_FIELDS) {
    self.init(
      name: f.name,
      visibility: SuiMoveVisibility(graphql: f.visibility),
      isEntry: f.isEntry,
      parameters: (f.parameters ?? []).map { $0.signature.string },
      typeParameters: (f.typeParameters ?? []).map { tp in
        SuiMoveFunctionTypeParameter(
          constraints: tp.constraints.compactMap {
            $0.value.flatMap { SuiMoveAbility(rawValue: $0.rawValue) }
          }
        )
      },
      returns: (f.return ?? []).map { $0.signature.string }
    )
  }
}

extension SuiMoveNormalizedStruct {
  init(graphql s: RPC_MOVE_STRUCT_FIELDS) {
    self.init(
      name: s.name,
      abilities: mapAbilities(s.abilities),
      fields: (s.fields ?? []).map {
        SuiMoveNormalizedField(name: $0.name, signature: $0.type?.signature.string)
      },
      typeParameters: (s.typeParameters ?? []).map { tp in
        SuiMoveStructTypeParameter(
          isPhantom: tp.isPhantom,
          constraints: tp.constraints.compactMap {
            $0.value.flatMap { SuiMoveAbility(rawValue: $0.rawValue) }
          }
        )
      }
    )
  }
}

extension SuiMoveNormalizedModule {
  init(graphql m: RPC_MOVE_MODULE_FIELDS) {
    self.init(
      name: m.name,
      fileFormatVersion: m.fileFormatVersion,
      functions: (m.functions?.nodes ?? []).map {
        SuiMoveNormalizedFunction(graphql: $0.fragments.rPC_MOVE_FUNCTION_FIELDS)
      },
      structs: (m.structs?.nodes ?? []).map {
        SuiMoveNormalizedStruct(graphql: $0.fragments.rPC_MOVE_STRUCT_FIELDS)
      }
    )
  }
}
