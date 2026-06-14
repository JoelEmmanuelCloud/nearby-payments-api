import LeanSuiApi
import SwiftUI
import UI

/// Tap-through detail for one activity: status, amount, parties, every coin change, and an explorer
/// link. Presented as a sheet from the Activity list.
struct ActivityDetailView: View {
  let activity: SuiActivity

  /// The signed-in address, so its appearances render as "You" rather than a raw hash.
  let currentAddress: String?

  @Environment(\.dismiss) private var dismiss

  @State private var digestCopied = false

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          header

          Card {
            VStack(alignment: .leading, spacing: 12) {
              detailRow("Status", value: activity.succeeded ? "Success" : "Failed")
              if let sender = activity.details.sender {
                detailRow(
                  "Sender", value: suiPartyLabel(sender, currentAddress: currentAddress), mono: true
                )
              }
              if let counterparty = activity.counterparty {
                detailRow(
                  activity.direction == .received ? "From" : "To",
                  value: suiPartyLabel(counterparty, currentAddress: currentAddress), mono: true)
              }
              if let timestamp = activity.timestamp {
                detailRow("When", value: timestamp.formatted(date: .abbreviated, time: .shortened))
              }
              digestRow
            }
          }

          if !activity.details.coinChanges.isEmpty {
            Card {
              VStack(alignment: .leading, spacing: 12) {
                Text("Balance changes")
                  .font(.headline)
                ForEach(Array(activity.details.coinChanges.enumerated()), id: \.offset) {
                  _, change in
                  HStack {
                    Text(suiPartyLabel(change.owner, currentAddress: currentAddress))
                      .font(.system(.footnote, design: .monospaced))
                      .foregroundColor(.secondary)
                    Spacer()
                    Text("\(change.amount) \(change.coinSymbol)")
                      .font(.footnote.weight(.medium))
                  }
                }
              }
            }
          }

          if let url = suiExplorerURL(digest: activity.digest, network: AppConstants.suiNetwork) {
            Link(destination: url) {
              HStack {
                Text("View on SuiVision")
                Spacer()
                Image(systemName: "arrow.up.right.square")
              }
            }
            .font(.body.weight(.medium))
          }
        }
        .padding(24)
      }
      .navigationTitle("Transaction")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismiss() }
        }
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(activity.direction == .received ? "Received" : "Sent")
        .font(.subheadline)
        .foregroundColor(.secondary)
      Text(
        "\(activity.direction == .received ? "+" : "-")\(activity.amount) \(activity.coinSymbol)"
      )
      .font(.largeTitle.weight(.semibold))
      .foregroundColor(activity.direction == .received ? .green : .primary)
    }
  }

  /// Tap to copy the full digest; the value briefly flickers to "Copied" then reverts.
  private var digestRow: some View {
    Button {
      UIPasteboard.general.string = activity.digest
      digestCopied = true
      Task {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        digestCopied = false
      }
    } label: {
      detailRow(
        "Digest",
        value: digestCopied ? "Copied" : shortSuiAddress(activity.digest, leading: 8, trailing: 6),
        mono: !digestCopied)
    }
    .buttonStyle(.plain)
  }

  private func detailRow(_ label: String, value: String, mono: Bool = false) -> some View {
    HStack {
      Text(label)
        .foregroundColor(.secondary)
      Spacer()
      Text(value)
        .font(mono ? .system(.body, design: .monospaced) : .body)
        .multilineTextAlignment(.trailing)
    }
  }
}
