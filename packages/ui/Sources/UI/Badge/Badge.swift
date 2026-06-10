import SwiftUI

public enum BadgeTone {
  case success
  case neutral
  case warning
  case danger

  var foreground: Color {
    switch self {
    case .success: .green
    case .neutral: .secondary
    case .warning: .orange
    case .danger: .red
    }
  }

  var background: Color {
    foreground.opacity(0.15)
  }
}

/// A small labeled pill, e.g. a "Registered" status tag. Generic — the caller supplies the text/tone.
public struct Badge: View {
  private let title: String
  private let tone: BadgeTone

  public init(_ title: String, tone: BadgeTone = .neutral) {
    self.title = title
    self.tone = tone
  }

  public var body: some View {
    Text(title)
      .font(.caption.weight(.semibold))
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .background(tone.background)
      .foregroundColor(tone.foreground)
      .clipShape(Capsule())
  }
}

#Preview {
  VStack(spacing: 8) {
    Badge("Registered", tone: .success)
    Badge("Pending", tone: .warning)
    Badge("Neutral")
  }
  .padding()
}
