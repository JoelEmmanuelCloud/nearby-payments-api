public final class DEREncodedItem: Sendable, Equatable {
  public let value: [Int8]

  public init(value: [Int8]) {
    self.value = value
  }

  public static func == (lhs: DEREncodedItem, rhs: DEREncodedItem) -> Bool {
    return lhs.value == rhs.value
  }
}
