/// A bridged model wrapping a DER-encoded byte array, representing cryptographic keys or signatures.
///
/// This class is bridged via JNI/JExtract. The underlying byte array uses signed 8-bit integers (`[Int8]`)
/// for binary layout compatibility with Java's signed `byte` type.
public final class DEREncodedItem: Sendable, Equatable {
  /// The underlying DER-encoded byte array values.
  public let value: [Int8]

  /// Initializes a new `DEREncodedItem`.
  ///
  /// - Parameter value: The raw signed byte array representation.
  public init(value: [Int8]) {
    self.value = value
  }

  /// Equates two `DEREncodedItem` instances by comparing their underlying byte arrays.
  public static func == (lhs: DEREncodedItem, rhs: DEREncodedItem) -> Bool {
    return lhs.value == rhs.value
  }
}
