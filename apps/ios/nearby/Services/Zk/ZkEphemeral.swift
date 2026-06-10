import Foundation
import LeanSui

/// Data model representing an active ephemeral cryptographic session for zkLogin.
///
/// `ZkEphemeral` holds the secure hardware-backed signing account and metadata
/// required to construct and verify the zero-knowledge login signature.
struct ZkEphemeral {
  /// The local hardware-bound ephemeral signing account (held in the Secure Enclave).
  let account: Account

  /// The maximum blockchain epoch for which this session key remains valid.
  let maxEpoch: UInt64

  /// Cryptographic salt/randomness generated for nonce blinding.
  let randomness: [UInt8]

  /// The base64URL-encoded zkLogin nonce bound to this session's parameters.
  let nonce: String
}
