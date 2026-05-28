import Testing

@testable import Storage

@Test func storagePackageLoads() async throws {
  _ = KeychainProvider(service: "com.variance.nearby.storage.tests")
}
