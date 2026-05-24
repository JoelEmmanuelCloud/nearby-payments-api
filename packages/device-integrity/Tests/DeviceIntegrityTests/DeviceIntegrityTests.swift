import DeviceIntegrityShared
import Foundation
import Gateway
import Testing

@testable import DeviceIntegrity

struct DeviceIntegrityTests {

  @Test("Stub provider returns stub identity")
  func testStubProvider() async throws {
    let provider: any IntegrityProvider = StubIntegrityProvider()

    try await provider.prepare()
    let integrity = try await provider.attest(nonce: Data("test-nonce".utf8))

    #expect(integrity == Gateway.DeviceIntegrity.stub)
    #expect(integrity.provider == "stub")
  }
}
