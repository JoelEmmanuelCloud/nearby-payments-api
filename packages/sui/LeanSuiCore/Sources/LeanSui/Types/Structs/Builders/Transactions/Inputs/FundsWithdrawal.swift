//
//  FundsWithdrawal.swift
//  SuiKit
//
//  Address Balances — gasless stablecoin transfers (Sui protocol v125, 2026).
//
//  A `CallArg::FundsWithdrawal` is a third programmable-transaction input kind (alongside
//  `Pure` and `Object`). It declares — inline in the `TransactionData` — a reservation to
//  withdraw funds from an address balance. At execution the validator converts it into a
//  `sui::funds_accumulator::Withdrawal<T>` Move value, which `0x2::balance::redeem_funds`
//  turns into a `Balance<T>` for `0x2::balance::send_funds`.
//
//  The BCS layout mirrors `sui-types::transaction` byte-for-byte (the canonical source the
//  @mysten/sui TypeScript BCS is generated from):
//
//    FundsWithdrawalArg { reservation: Reservation, type_arg: WithdrawalTypeArg, withdraw_from: WithdrawFrom }
//    Reservation       = MaxAmountU64(u64)                 // variant 0
//    WithdrawalTypeArg = Balance(TypeTag)                  // variant 0
//    WithdrawFrom      = Sender | Sponsor                  // variant 0 | 1
//

import Foundation
import LeanSuiBCS

/// How much of an address balance a withdrawal reserves. The amount is an upper bound the
/// transaction may withdraw, not necessarily the exact amount moved.
public enum Reservation: SuiBCSBridged {
  /// Reserve up to a specific amount of the balance.
  case maxAmountU64(UInt64)

  public func serialize(_ serializer: Serializer) throws {
    switch self {
    case .maxAmountU64(let amount):
      try serializer.uleb128(UInt(0))
      try Serializer.u64(serializer, amount)
    }
  }

  public static func deserialize(from deserializer: Deserializer) throws -> Reservation {
    switch try deserializer.uleb128() {
    case 0:
      return .maxAmountU64(try Deserializer.u64(deserializer))
    default:
      throw SuiError.customError(message: "Unable to Deserialize Reservation")
    }
  }
}

/// The accumulator type a withdrawal targets. Currently only `Balance<T>`, carrying the inner
/// coin type `T` as a `TypeTag` (e.g. `0x…::usdc::USDC`).
public enum WithdrawalTypeArg: SuiBCSBridged {
  case balance(TypeTag)

  public func serialize(_ serializer: Serializer) throws {
    switch self {
    case .balance(let typeTag):
      try serializer.uleb128(UInt(0))
      try Serializer._struct(serializer, value: typeTag)
    }
  }

  public static func deserialize(from deserializer: Deserializer) throws -> WithdrawalTypeArg {
    switch try deserializer.uleb128() {
    case 0:
      return .balance(try Deserializer._struct(deserializer))
    default:
      throw SuiError.customError(message: "Unable to Deserialize WithdrawalTypeArg")
    }
  }
}

/// Whose address balance the funds are withdrawn from.
public enum WithdrawFrom: SuiBCSBridged {
  /// Withdraw from the transaction sender.
  case sender
  /// Withdraw from the sponsor (gas owner) of the transaction.
  case sponsor

  public func serialize(_ serializer: Serializer) throws {
    switch self {
    case .sender: try serializer.uleb128(UInt(0))
    case .sponsor: try serializer.uleb128(UInt(1))
    }
  }

  public static func deserialize(from deserializer: Deserializer) throws -> WithdrawFrom {
    switch try deserializer.uleb128() {
    case 0: return .sender
    case 1: return .sponsor
    default: throw SuiError.customError(message: "Unable to Deserialize WithdrawFrom")
    }
  }
}

/// Parameters a `TransactionBlock` needs to pay gas from an address balance (gasless): the
/// 32-byte chain identifier and a per-transaction nonce that together (with the epoch bounds)
/// provide replay protection in the `ValidDuring` expiration.
public struct GaslessTransactionConfig {
  public let chainIdentifier: [UInt8]
  public let nonce: UInt32

  public init(chainIdentifier: [UInt8], nonce: UInt32) {
    self.chainIdentifier = chainIdentifier
    self.nonce = nonce
  }
}

/// The inline reservation carried by a `CallArg::FundsWithdrawal` input.
public struct FundsWithdrawalArg: SuiBCSBridged {
  public let reservation: Reservation
  public let typeArg: WithdrawalTypeArg
  public let withdrawFrom: WithdrawFrom

  public init(reservation: Reservation, typeArg: WithdrawalTypeArg, withdrawFrom: WithdrawFrom) {
    self.reservation = reservation
    self.typeArg = typeArg
    self.withdrawFrom = withdrawFrom
  }

  /// Withdraw up to `amount` from `Balance<balanceType>` in the **sender's** address balance.
  /// `balanceType` is the inner coin type, e.g. `0x…::usdc::USDC`.
  public static func balanceFromSender(amount: UInt64, balanceType: String) throws
    -> FundsWithdrawalArg
  {
    FundsWithdrawalArg(
      reservation: .maxAmountU64(amount),
      typeArg: .balance(try TypeTag(stringValue: balanceType)),
      withdrawFrom: .sender
    )
  }

  public func serialize(_ serializer: Serializer) throws {
    try Serializer._struct(serializer, value: self.reservation)
    try Serializer._struct(serializer, value: self.typeArg)
    try Serializer._struct(serializer, value: self.withdrawFrom)
  }

  public static func deserialize(from deserializer: Deserializer) throws -> FundsWithdrawalArg {
    FundsWithdrawalArg(
      reservation: try Deserializer._struct(deserializer),
      typeArg: try Deserializer._struct(deserializer),
      withdrawFrom: try Deserializer._struct(deserializer)
    )
  }
}
