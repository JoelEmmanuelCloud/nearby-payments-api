//
//  HSMKeyUtilities.swift
//  LeanSui
//

import BigInt
import Foundation
import HSM

enum HSMKeyUtilities {
  /// The secp256r1 (P-256) curve order `n`.
  private static let curveOrder = BigInt(
    "FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551", radix: 16)!

  static func data(from item: DEREncodedItem) -> Data {
    return Data(item.value.map { UInt8(bitPattern: $0) })
  }

  static func signedBytes(from data: Data) -> [Int8] {
    return data.map { Int8(bitPattern: $0) }
  }

  /// Normalizes a 64-byte `r || s` ECDSA signature to **low-S** form.
  ///
  /// Sui/fastcrypto reject high-S secp256r1 signatures as malleable, and neither the
  /// Secure Enclave nor Android Keystore guarantee low-S. Mirrors SuiKit's
  /// `SECP256R1PrivateKey.normalizeSignature`: if `s > n/2`, replace `s` with `n - s`.
  static func normalizeLowS(_ rawSignature: Data) -> Data {
    guard rawSignature.count == HSMPublicKey.signatureLength else { return rawSignature }

    let r = rawSignature.prefix(32)
    var s = zkLoginNonce.toBigIntBE(bytes: Data(rawSignature.suffix(32)))
    if s > curveOrder / 2 {
      s = curveOrder - s
    }

    return Data(r) + Data(zkLoginUtilities.toBigEndianBytes(num: s, width: 32))
  }
}

final class HSMSignerBox: @unchecked Sendable {
  let module: any HardwareSecurityModule

  init(_ module: any HardwareSecurityModule) {
    self.module = module
  }
}
