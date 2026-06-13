// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

@_spi(Internal) @_spi(Execution) import ApolloAPI
import Foundation

extension SuiGraphQL {
  /// The signature of a concrete Move Type (a type with all its type parameters instantiated with concrete types, that contains no references), corresponding to the following recursive type:
  ///
  /// type MoveTypeSignature =
  ///     "address"
  ///   | "bool"
  ///   | "u8" | "u16" | ... | "u256"
  ///   | { vector: MoveTypeSignature }
  ///   | {
  ///       datatype: {
  ///         package: string,
  ///         module: string,
  ///         type: string,
  ///         typeParameters: [MoveTypeSignature],
  ///       }
  ///     }
  ///
  /// Like `OpenMoveTypeSignature`, the server returns a *structured* object here,
  /// not a string. The default `typealias = String` would fail to decode object
  /// type signatures (e.g. when reading object contents). This is a real custom
  /// scalar capturing the raw value and exposing a `string` accessor with the
  /// canonical JSON text.
  struct MoveTypeSignature: CustomScalarType, Hashable, @unchecked Sendable {
    let rawValue: JSONValue

    init(_jsonValue value: JSONValue) throws {
      self.rawValue = value
    }

    init(_ value: JSONValue) {
      self.rawValue = value
    }

    var _jsonValue: JSONValue { rawValue }
    var _jsonEncodableValue: (any JSONEncodable)? { string }

    var string: String {
      if let s = rawValue as? String { return s }
      guard JSONSerialization.isValidJSONObject(rawValue),
        let data = try? JSONSerialization.data(withJSONObject: rawValue, options: [.sortedKeys]),
        let text = String(data: data, encoding: .utf8)
      else {
        return String(describing: rawValue)
      }
      return text
    }

    static func == (lhs: MoveTypeSignature, rhs: MoveTypeSignature) -> Bool {
      AnyHashable(lhs.rawValue) == AnyHashable(rhs.rawValue)
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(AnyHashable(rawValue))
    }
  }
}
