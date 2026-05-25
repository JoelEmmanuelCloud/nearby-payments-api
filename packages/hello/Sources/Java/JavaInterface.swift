import Foundation
import SwiftJava

public protocol HelloShared {
  func greeting(name: String) -> String

  func timesTwo(value: Int32) -> Int32
}

public struct HelloGateway {
  private let provider: any HelloShared

  public init(provider: any HelloShared) {
    self.provider = provider
  }

  public func runRoundTrip(name: String) -> String {
    let greeting = provider.greeting(name: name)
    let doubled = provider.timesTwo(value: 21)

    return "\(greeting); doubled=\(doubled)"
  }
}
