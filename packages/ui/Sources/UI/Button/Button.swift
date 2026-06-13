import SwiftUI

public struct UIButton: View {
  private let title: String
  private let action: () -> Void
  private let isDisabled: Bool

  public init(
    _ title: String,
    isDisabled: Bool = false,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.isDisabled = isDisabled
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      Text(title)
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
    .buttonStyle(.borderedProminent)
    .disabled(isDisabled)
  }
}

#Preview {
  VStack(spacing: 12) {
    UIButton("Continue") {}
    UIButton("Disabled", isDisabled: true) {}
  }
  .padding()
}
