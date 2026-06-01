public final class StorageItem: Sendable {
  public let value: [Int8]

  public init(value: [Int8]) {
    self.value = value
  }
}
