import Foundation
import LeanSui

/// Sends the balance coin gaslessly from the sender's **address balance** to a recipient, via
/// `0x2::balance::send_funds` (#6d).
///
/// Intentionally single-purpose: it draws only from the address balance. Value still held as
/// `Coin<T>` objects (the "pending" balance) is surfaced on Home and moved into the address balance
/// by `ConsolidateService` — a separate, also-gasless action.
struct SendService {
  enum SendError: LocalizedError {
    case invalidAmount

    var errorDescription: String? {
      switch self {
      case .invalidAmount: return "Invalid amount."
      }
    }
  }

  private let runner: GaslessTransactionRunner
  private let coinType: String
  private let coinDecimals: Int

  init(
    coinType: String = AppConstants.usdSuiCoinType,
    coinDecimals: Int = AppConstants.balanceCoinDecimals,
    signerProvider: @escaping () async throws -> ZkLoginSigner
  ) {
    self.runner = GaslessTransactionRunner(signerProvider: signerProvider)
    self.coinType = coinType
    self.coinDecimals = coinDecimals
  }

  /// Sends `amount` (human units, e.g. `12.5`) to `recipient` (a `0x` address). Returns the digest.
  func send(amount: Decimal, recipient: String) async throws -> String {
    let baseUnits = try baseUnits(amount)
    return try await runner.run { tx, _ in
      try tx.gaslessSendFunds(coinType: coinType, amount: baseUnits, recipient: recipient)
    }
  }

  /// Converts a human amount to integer base units (`amount × 10^decimals`). The amount entry caps
  /// fraction digits at `coinDecimals`, so the scaled value is integral; we still floor defensively.
  private func baseUnits(_ amount: Decimal) throws -> UInt64 {
    let handler = NSDecimalNumberHandler(
      roundingMode: .down,
      scale: 0,
      raiseOnExactness: false,
      raiseOnOverflow: false,
      raiseOnUnderflow: false,
      raiseOnDivideByZero: false
    )
    let scaled = (amount as NSDecimalNumber)
      .multiplying(byPowerOf10: Int16(coinDecimals))
      .rounding(accordingToBehavior: handler)

    guard scaled.compare(NSDecimalNumber.zero) == .orderedDescending,
      scaled.compare(NSDecimalNumber(value: UInt64.max)) != .orderedDescending
    else {
      throw SendError.invalidAmount
    }
    return scaled.uint64Value
  }
}
