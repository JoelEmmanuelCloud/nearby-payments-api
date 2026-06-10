//
//  SuiData.swift
//  LeanSuiBCS
//

public struct SuiData: EncodingProtocol, Hashable, RandomAccessCollection, Sendable {
  public let bytes: [UInt8]

  public init(_ bytes: [UInt8]) {
    self.bytes = bytes
  }

  init(_ buffer: UnsafeRawBufferPointer) {
    self.bytes = Array(buffer.bindMemory(to: UInt8.self))
  }

  public var count: Int {
    bytes.count
  }

  public var isEmpty: Bool {
    bytes.isEmpty
  }

  public typealias Index = Int
  public typealias Element = UInt8

  public var startIndex: Int {
    bytes.startIndex
  }

  public var endIndex: Int {
    bytes.endIndex
  }

  public subscript(index: Int) -> UInt8 {
    bytes[index]
  }

  public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
    try bytes.withUnsafeBytes(body)
  }

  public func subdata(in range: Range<Int>) -> SuiData {
    SuiData(Array(bytes[range]))
  }

  public func lexicographicallyPrecedes(_ other: SuiData) -> Bool {
    bytes.lexicographicallyPrecedes(other.bytes)
  }
}
