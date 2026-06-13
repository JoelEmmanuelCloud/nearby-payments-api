import Auth
import Gateway
import HSM
import Storage

extension ZkLoginService {
  /// A throwaway instance for SwiftUI previews. It wires the real dependency graph against a dummy
  /// endpoint; previews never initiate signing, so the network is never touched. Kept unconditional
  /// (not `#if DEBUG`) so it resolves under every build configuration the previews compile in.
  static var preview: ZkLoginService {
    let gateway = try! APIGateway(baseURLString: "https://example.com", apiVersion: "v1")
    return ZkLoginService(
      hsm: SecureEnclaveHSM(),
      sessionManager: SessionManager(
        storage: KeychainProvider(),
        hsm: SecureEnclaveHSM(),
        gateway: gateway
      )
    )
  }
}
