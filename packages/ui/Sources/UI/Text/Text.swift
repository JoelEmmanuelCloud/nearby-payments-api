import SwiftUI

public struct Title: View {
  private let value: String

  public init(_ value: String) {
    self.value = value
  }

  public var body: some View {
    Text(value)
      .font(.title2.weight(.semibold))
      .foregroundStyle(.primary)
  }
}
