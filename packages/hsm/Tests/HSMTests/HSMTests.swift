import Foundation
import Testing

@testable import HSMShared

struct HSMTests {

  @Test("Mock HSM generates a mock key and signs correctly")
  func testMockHSM() async throws {
    let hsm: any HardwareSecurityModule = MockHSM()

    let publicKey = try await hsm.generateKey()
    #expect(publicKey == Data("mock-public-key".utf8))

    let fetchedKey = try await hsm.getPublicKey()
    #expect(fetchedKey == publicKey)

    let signature = try await hsm.sign(Data("payload".utf8))
    #expect(signature == Data("mock-signature".utf8))

    try await hsm.deleteKey()

    let afterDelete = try await hsm.getPublicKey()
    #expect(afterDelete == nil)
  }
}

actor MockHSM: HardwareSecurityModule {

  private var hasKey = false

  func generateKey() async throws -> Data {
    hasKey = true
    return Data("mock-public-key".utf8)
  }

  func getPublicKey() async throws -> Data? {
    if hasKey {
      return Data("mock-public-key".utf8)
    }
    return nil
  }

  func sign(_ data: Data) async throws -> Data {
    guard hasKey else {
      struct NoKeyError: Error {}
      throw NoKeyError()
    }
    return Data("mock-signature".utf8)
  }

  func deleteKey() async throws {
    hasKey = false
  }
}
