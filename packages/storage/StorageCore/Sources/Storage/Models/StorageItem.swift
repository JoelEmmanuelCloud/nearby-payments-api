/// A JNI-bridged model wrapping a raw binary payload stored securely in persistent storage.
///
/// This class is bridged via JNI/JExtract. The underlying byte array uses signed 8-bit integers (`[Int8]`)
/// to align with Java's signed `byte` type representation.
public final class StorageItem: Sendable {
  /// The raw signed byte array values stored.
  public let value: [Int8]

  /// Initializes a new `StorageItem`.
  ///
  /// - Parameter value: The raw signed byte array values.
  public init(value: [Int8]) {
    self.value = value
  }
}
