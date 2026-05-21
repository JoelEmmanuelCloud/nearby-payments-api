import SwiftUI

public struct UIButton: View {
  private let title: String
  private let action: () -> Void

  public init(
    _ title: String,
    action: @escaping () -> Void
  ) {
    self.title = title
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
  }
}
