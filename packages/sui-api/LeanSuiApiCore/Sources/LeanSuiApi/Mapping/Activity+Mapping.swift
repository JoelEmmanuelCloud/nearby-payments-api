//
//  Activity+Mapping.swift
//  LeanSuiApi
//
//  Pure folding of a transaction's balance changes into a single `SuiActivity` row, from one address's
//  perspective. No IO — fully unit-testable. Amount math is string-based (base-unit integer strings)
//  to stay precise and portable across the Apple and Android Foundation builds (no `FormatStyle`).
//

import Foundation

extension SuiActivity {
  /// Folds `tx`'s balance changes for `coinType` into one activity row from `owner`'s perspective.
  /// Returns nil when the transaction moved none of `coinType` for `owner` — e.g. a gas-only or
  /// otherwise unrelated transaction surfaced by the affected-address filter.
  static func make(
    from tx: SuiTransactionBlockResponse,
    owner: String,
    coinType: String,
    coinSymbol: String,
    decimals: Int
  ) -> SuiActivity? {
    let effects = tx.effects

    // Balance changes for the target coin only.
    let changes = (effects?.balanceChanges ?? []).filter {
      guard let changeCoin = $0.coinType else { return false }
      return sameCoin(changeCoin, coinType)
    }
    guard !changes.isEmpty else { return nil }

    // The queried address's own net change for this coin must be present and non-zero.
    guard let mine = changes.first(where: { sameAddress($0.owner, owner) }),
      let mineAmount = mine.amount
    else { return nil }
    let mineSigned = signedDigits(mineAmount)
    guard !isZero(mineSigned.digits) else { return nil }

    let direction: SuiActivityDirection = mineSigned.negative ? .sent : .received
    let counterparty = counterparty(for: direction, in: changes, owner: owner, sender: tx.sender)

    let coinChanges = changes.map { change in
      SuiActivityCoinChange(
        owner: change.owner,
        coinType: change.coinType ?? coinType,
        coinSymbol: coinSymbol,
        amount: signedDisplay(change.amount ?? "0", decimals: decimals)
      )
    }

    let succeeded = effects?.status == .success
    let detail = SuiActivityDetail(
      digest: tx.digest,
      sender: tx.sender,
      succeeded: succeeded,
      executionError: effects?.executionError,
      timestamp: effects?.timestamp,
      coinChanges: coinChanges
    )

    return SuiActivity(
      digest: tx.digest,
      direction: direction,
      amount: formatMagnitude(mineSigned.digits, decimals: decimals),
      coinType: coinType,
      coinSymbol: coinSymbol,
      counterparty: counterparty,
      succeeded: succeeded,
      timestamp: effects?.timestamp,
      details: detail
    )
  }

  // MARK: - Counterparty

  /// The other party for this coin: the opposite-signed owner (recipient when sent), or the tx sender
  /// when received.
  private static func counterparty(
    for direction: SuiActivityDirection,
    in changes: [BalanceChange],
    owner: String,
    sender: String?
  ) -> String? {
    switch direction {
    case .sent:
      return changes.first { change in
        !sameAddress(change.owner, owner) && !signedDigits(change.amount ?? "0").negative
          && !isZero(signedDigits(change.amount ?? "0").digits)
      }?.owner
    case .received:
      if let sender, !sameAddress(sender, owner) { return sender }
      return changes.first { change in
        !sameAddress(change.owner, owner) && signedDigits(change.amount ?? "0").negative
      }?.owner
    }
  }

  // MARK: - Coin / address identity

  /// Coin types match when their address segments are canonically equal and the module/struct match.
  private static func sameCoin(_ a: String, _ b: String) -> Bool {
    normalizeCoin(a) == normalizeCoin(b)
  }

  private static func normalizeCoin(_ coin: String) -> String {
    let parts = coin.components(separatedBy: "::")
    guard parts.count >= 3 else { return coin.lowercased() }
    let address = normalizeAddress(parts[0])
    let rest = parts[1...].map { $0.lowercased() }
    return ([address] + rest).joined(separator: "::")
  }

  private static func sameAddress(_ a: String?, _ b: String?) -> Bool {
    guard let a, let b else { return false }
    return normalizeAddress(a) == normalizeAddress(b)
  }

  /// Lowercase, drop `0x`, and trim leading zeros so differently-padded forms of the same Sui address
  /// compare equal.
  private static func normalizeAddress(_ raw: String) -> String {
    var address = raw.lowercased()
    if address.hasPrefix("0x") { address.removeFirst(2) }
    let trimmed = String(address.drop { $0 == "0" })
    return trimmed.isEmpty ? "0" : trimmed
  }

  // MARK: - Amount formatting (string-based, fixed 2 fraction digits)

  /// Splits a signed base-unit integer string into its sign and magnitude digits.
  private static func signedDigits(_ raw: String) -> (negative: Bool, digits: String) {
    if raw.hasPrefix("-") { return (true, String(raw.dropFirst())) }
    if raw.hasPrefix("+") { return (false, String(raw.dropFirst())) }
    return (false, raw)
  }

  private static func isZero(_ digits: String) -> Bool {
    digits.isEmpty || digits.allSatisfy { $0 == "0" }
  }

  /// A signed, scaled display string for one balance change, e.g. "+12.50" / "-12.50" / "0.00".
  private static func signedDisplay(_ raw: String, decimals: Int) -> String {
    let parsed = signedDigits(raw)
    let magnitude = formatMagnitude(parsed.digits, decimals: decimals)
    if isZero(parsed.digits) { return magnitude }
    return (parsed.negative ? "-" : "+") + magnitude
  }

  /// Scales unsigned base-unit `digits` by `decimals` to a fixed-`fractionDigits` decimal string
  /// (truncating, display-only), e.g. ("12500000", 6) -> "12.50".
  static func formatMagnitude(_ digits: String, decimals: Int, fractionDigits: Int = 2) -> String {
    let clean = digits.isEmpty ? "0" : digits
    let padded = String(repeating: "0", count: max(0, decimals + 1 - clean.count)) + clean
    let splitIndex = padded.index(padded.endIndex, offsetBy: -decimals)

    let integerPart = String(padded[..<splitIndex])
    let trimmedInteger = String(integerPart.drop { $0 == "0" })
    let integerDisplay = trimmedInteger.isEmpty ? "0" : trimmedInteger

    guard fractionDigits > 0 else { return integerDisplay }

    var fraction = decimals > 0 ? String(padded[splitIndex...]) : ""
    if fraction.count < fractionDigits {
      fraction += String(repeating: "0", count: fractionDigits - fraction.count)
    } else {
      fraction = String(fraction.prefix(fractionDigits))
    }
    return "\(integerDisplay).\(fraction)"
  }
}
