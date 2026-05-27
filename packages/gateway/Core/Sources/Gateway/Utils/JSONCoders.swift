import Foundation

/// Shared JSON encoder/decoder configured to match the backend's conventions.
///
/// The backend uses camelCase JSON keys throughout (as seen in the Postman
/// collection), which aligns with Swift's default `JSONEncoder` key strategy.
/// These are exposed as a namespace so all Gateway code uses the same
/// configuration, preventing subtle serialisation mismatches.
public enum JSONCoders {

  /// Encoder matching the backend's expected JSON format.
  ///
  /// Uses default camelCase key encoding. Dates are encoded as ISO 8601
  /// if any date fields are added in the future.
  public static let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }()

  /// Decoder matching the backend's JSON response format.
  ///
  /// Uses default camelCase key decoding. Dates are decoded from ISO 8601.
  public static let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()

  // MARK: - Encoding / Decoding
  public static func encode(_ value: any Encodable) throws -> Data {
    do {
      return try JSONCoders.encoder.encode(value)
    } catch {
      throw GatewayError.encodingFailed(description: error.localizedDescription)
    }
  }

  public static func decode<T: Decodable>(type: T.Type, from data: Data) throws -> T {
    do {
      return try JSONCoders.decoder.decode(T.self, from: data)
    } catch {
      throw GatewayError.decodingFailed(description: error.localizedDescription)
    }
  }
}
