import Foundation

/// Centralized JSON encoder and decoder configuration namespace, enforcing ISO8601 date encoding/decoding.
public enum JSONCoders {

  /// Shared static JSON encoder instance configured with ISO8601 date formatting.
  public static let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }()

  /// Shared static JSON decoder instance configured with ISO8601 date formatting.
  public static let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()

  /// Encodes an Encodable model into JSON data bytes.
  ///
  /// - Parameter value: The object to serialize.
  /// - Returns: The serialized JSON `Data`.
  /// - Throws: `GatewayError.encodingFailed` if serialization fails.
  public static func encode(_ value: any Encodable) throws -> Data {
    do {
      return try JSONCoders.encoder.encode(value)
    } catch {
      throw GatewayError.encodingFailed(description: error.localizedDescription)
    }
  }

  /// Decodes JSON data bytes into a model of the specified generic Type.
  ///
  /// - Parameters:
  ///   - type: The target Decodable type class.
  ///   - data: The source JSON `Data` bytes.
  /// - Returns: The deserialized instance of the generic type.
  /// - Throws: `GatewayError.decodingFailed` if parsing fails.
  public static func decode<T: Decodable>(type: T.Type, from data: Data) throws -> T {
    do {
      return try JSONCoders.decoder.decode(T.self, from: data)
    } catch {
      throw GatewayError.decodingFailed(description: error.localizedDescription)
    }
  }
}
