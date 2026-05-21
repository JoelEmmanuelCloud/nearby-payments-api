import SwiftUI

public enum ToastTone {
  case success
  case warning
  case danger
  case neutral

  var color: Color {
    switch self {
    case .success:
      .green
    case .warning:
      .orange
    case .danger:
      .red
    case .neutral:
      .secondary
    }
  }
}

public struct Toast: View {
  private let title: String
  private let tone: ToastTone

  public init(
    title: String,
    tone: ToastTone = .neutral
  ) {
    self.title = title
    self.tone = tone
  }

  public var body: some View {
    HStack(spacing: 10) {
      Circle()
        .fill(tone.color)
        .frame(width: 8, height: 8)

      Text(title)
        .font(.callout)
        .foregroundStyle(.primary)

      Spacer(minLength: 0)
    }
    .padding(12)
    .background(.thinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}
