// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

@_spi(Internal) @_spi(Execution) import ApolloAPI
import Foundation

extension SuiGraphQL {
  /// The shape of an abstract Move Type (a type that can contain free type parameters, and can optionally be taken by reference), corresponding to the following recursive type:
  ///
  /// type OpenMoveTypeSignature = {
  ///   ref: ("&" | "&mut")?,
  ///   body: OpenMoveTypeSignatureBody,
  /// }
  ///
  /// type OpenMoveTypeSignatureBody =
  ///     "address"
  ///   | "bool"
  ///   | "u8" | "u16" | ... | "u256"
  ///   | { vector: OpenMoveTypeSignatureBody }
  ///   | {
  ///       datatype {
  ///         package: string,
  ///         module: string,
  ///         type: string,
  ///         typeParameters: [OpenMoveTypeSignatureBody]
  ///       }
  ///     }
  ///   | { typeParameter: number }
  ///
  /// The server returns a *structured* object here, not a string. The default
  /// generated `typealias OpenMoveTypeSignature = String` fails to decode it
  /// (`JSONDecodingError.couldNotConvert(... to: Swift.String)`), which broke
  /// `getNormalizedMoveFunction` and arbitrary move-call argument resolution. This
  /// is a real custom scalar that captures the raw decoded value and exposes a
  /// `string` accessor re-serializing it to canonical JSON text — exactly the form
  /// the consumer (`SuiMoveNormalizedType.parseGraphQLSignature`) expects.
  struct OpenMoveTypeSignature: CustomScalarType, Hashable, @unchecked Sendable {
    /// The raw decoded value (`String` for primitive bodies, or a nested
    /// `[String: Any]` for `ref`/`body`/`datatype`/`vector`/`typeParameter`).
    let rawValue: JSONValue

    init(_jsonValue value: JSONValue) throws {
      self.rawValue = value
    }

    init(_ value: JSONValue) {
      self.rawValue = value
    }

    var _jsonValue: JSONValue { rawValue }
    var _jsonEncodableValue: (any JSONEncodable)? { string }

    /// The signature re-serialized as a JSON string. Primitive string bodies are
    /// returned verbatim; structured objects are serialized via `JSONSerialization`.
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

    static func == (lhs: OpenMoveTypeSignature, rhs: OpenMoveTypeSignature) -> Bool {
      AnyHashable(lhs.rawValue) == AnyHashable(rhs.rawValue)
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(AnyHashable(rawValue))
    }
  }
}
