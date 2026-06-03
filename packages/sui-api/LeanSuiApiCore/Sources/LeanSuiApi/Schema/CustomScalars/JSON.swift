// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

@_spi(Internal) @_spi(Execution) import ApolloAPI
import Foundation

extension SuiGraphQL {
  /// Arbitrary JSON data.
  ///
  /// Sui's `JSON` scalar can be any JSON value — most often a structured object
  /// or array (e.g. `MoveValue.json`), not a string. The default generated
  /// `typealias JSON = String` fails to decode those, so this is a real custom
  /// scalar that captures the raw decoded value and exposes a `string`
  /// accessor that re-serializes it to canonical JSON text.
  struct JSON: CustomScalarType, Hashable, @unchecked Sendable {
    /// The raw decoded JSON value (`String`, number, `Bool`, `[Any]`, `[String: Any]`, or null).
    let rawValue: JSONValue
    init(_jsonValue value: JSONValue) throws {
      self.rawValue = value
    }

    init(_ value: JSONValue) {
      self.rawValue = value
    }
    var _jsonValue: JSONValue { rawValue }
    var _jsonEncodableValue: (any JSONEncodable)? {
      string
    }

    /// The value re-serialized as a JSON string. For a value that is already a
    /// string scalar, returns it verbatim; otherwise serializes via `JSONSerialization`.
    var string: String {
      if let s = rawValue as? String { return s }
      guard JSONSerialization.isValidJSONObject(rawValue),
        let data = try? JSONSerialization.data(
          withJSONObject: rawValue, options: [.sortedKeys]),
        let text = String(data: data, encoding: .utf8)
      else {
        return String(describing: rawValue)
      }
      return text
    }

    static func == (lhs: JSON, rhs: JSON) -> Bool {
      AnyHashable(lhs.rawValue) == AnyHashable(rhs.rawValue)
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(AnyHashable(rawValue))
    }
  }
}
