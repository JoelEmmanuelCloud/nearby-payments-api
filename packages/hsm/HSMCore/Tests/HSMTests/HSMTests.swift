// packages/hsm/HSMCore/Tests/HSMTests/HSMTests.swift
import Foundation
import Testing

@testable import HSM

struct HSMTests {

  @Test("Mock HSM generates a mock key and signs correctly")
  func testMockHSM() throws {
    let hsm: any HardwareSecurityModule = MockHSM()

    let expectedKey = DEREncodedItem(
      value: Array("mock-public-key".utf8).map { Int8(bitPattern: $0) })
    let expectedSig = DEREncodedItem(
      value: Array("mock-signature".utf8).map { Int8(bitPattern: $0) })

    let publicKey = try hsm.generateKey()
    #expect(publicKey == expectedKey)

    let fetchedKey = try hsm.getPublicKey()
    #expect(fetchedKey == publicKey)
    #expect(try hsm.validateKeyForSigning())

    let payload = Array("payload".utf8).map { Int8(bitPattern: $0) }
    let signature = try hsm.sign(payload)
    #expect(signature == expectedSig)

    try hsm.deleteKey()

    let afterDelete = try hsm.getPublicKey()
    #expect(afterDelete == nil)
    #expect(try !hsm.validateKeyForSigning())
  }
}

final class MockHSM: HardwareSecurityModule, @unchecked Sendable {
  private let lock = NSLock()
  private var hasKey = false

  func generateKey() throws -> DEREncodedItem {
    lock.withLock {
      hasKey = true
      return DEREncodedItem(value: Array("mock-public-key".utf8).map { Int8(bitPattern: $0) })
    }
  }

  func getPublicKey() throws -> DEREncodedItem? {
    lock.withLock {
      if hasKey {
        return DEREncodedItem(value: Array("mock-public-key".utf8).map { Int8(bitPattern: $0) })
      }
      return nil
    }
  }

  func sign(_ data: [Int8]) throws -> DEREncodedItem {
    try lock.withLock {
      guard hasKey else {
        struct NoKeyError: Error {}
        throw NoKeyError()
      }
      return DEREncodedItem(value: Array("mock-signature".utf8).map { Int8(bitPattern: $0) })
    }
  }

  func validateKeyForSigning() throws -> Bool {
    lock.withLock {
      hasKey
    }
  }

  func deleteKey() throws {
    lock.withLock {
      hasKey = false
    }
  }
}
