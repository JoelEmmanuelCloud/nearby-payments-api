import Foundation

public enum JSONCoders {

  public static let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }()

  public static let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()

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
