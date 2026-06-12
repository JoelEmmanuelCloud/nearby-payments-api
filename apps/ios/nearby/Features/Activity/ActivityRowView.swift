import LeanSuiApi
import SwiftUI
import UI

/// One activity row: direction glyph, title + counterparty, signed amount, and relative time.
struct ActivityRowView: View {
  let activity: SuiActivity

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: iconName)
        .font(.system(size: 18, weight: .semibold))
        .foregroundColor(isReceived ? .green : .primary)
        .frame(width: 40, height: 40)
        .background(Color(.secondarySystemBackground))
        .clipShape(Circle())

      VStack(alignment: .leading, spacing: 2) {
        Text(isReceived ? "Received" : "Sent")
          .font(.body.weight(.medium))

        if let counterparty = activity.counterparty {
          Text("\(isReceived ? "From" : "To") \(shortSuiAddress(counterparty))")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 2) {
        Text("\(isReceived ? "+" : "-")\(activity.amount) \(activity.coinSymbol)")
          .font(.body.weight(.semibold))
          .foregroundColor(isReceived ? .green : .primary)

        if !activity.succeeded {
          Text("Failed")
            .font(.caption2.weight(.semibold))
            .foregroundColor(.red)
        } else if let timestamp = activity.timestamp {
          Text(timestamp, format: .relative(presentation: .named))
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }
    }
    .padding(.vertical, 6)
    .contentShape(Rectangle())
  }

  private var isReceived: Bool {
    activity.direction == .received
  }

  private var iconName: String {
    isReceived ? "arrow.down.left" : "arrow.up.right"
  }
}
