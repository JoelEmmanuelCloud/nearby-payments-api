import SwiftUI

public struct MutedText: View {
  private let value: String

  public init(_ value: String) {
    self.value = value
  }

  public var body: some View {
    Text(value)
      .font(.subheadline)
      .foregroundStyle(.secondary)
      .fixedSize(horizontal: false, vertical: true)
  }
}

#Preview {
  MutedText("Secondary text keeps supporting content quieter than the main title.")
    .padding()
}
