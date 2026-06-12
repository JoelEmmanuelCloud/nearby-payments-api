import LeanSuiApi
import SwiftUI
import UI

/// The Activity tab: the account's on-chain transaction history for the balance coin, newest first,
/// with cursor-based infinite scroll and a tap-through detail sheet.
struct ActivityView: View {
  @StateObject private var viewModel: ActivityViewModel

  @State private var selected: SuiActivity?

  private let suiAddress: String?

  init(suiAddress: String?) {
    self.suiAddress = suiAddress
    _viewModel = StateObject(wrappedValue: ActivityViewModel(suiAddress: suiAddress))
  }

  var body: some View {
    NavigationStack {
      content
        .navigationTitle("Activity")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .sheet(item: $selected) { ActivityDetailView(activity: $0, currentAddress: suiAddress) }
    }
  }

  @ViewBuilder
  private var content: some View {
    switch viewModel.phase {
    case .loading:
      ActivitySkeletonView()
    case .empty:
      placeholder(
        icon: "receipt.fill", title: "No activity yet",
        subtitle: "Your transactions will show up here.")
    case .error:
      placeholder(
        icon: "exclamationmark.triangle", title: "Error encountered during fetch.", subtitle: nil)
    case .content:
      list
    }
  }

  private var list: some View {
    List {
      ForEach(viewModel.items, id: \.digest) { item in
        Button {
          selected = item
        } label: {
          ActivityRowView(activity: item)
        }
        .buttonStyle(.plain)
        .listRowSeparator(.hidden)
        .onAppear {
          if item.digest == viewModel.items.last?.digest {
            Task { await viewModel.loadMore() }
          }
        }
      }

      if viewModel.isLoadingMore {
        HStack {
          Spacer()
          ProgressView()
          Spacer()
        }
        .listRowSeparator(.hidden)
      }
    }
    .listStyle(.plain)
  }

  private func placeholder(icon: String, title: String, subtitle: String?) -> some View {
    VStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 56))
        .foregroundColor(.secondary)
      Text(title)
        .font(.headline)
      if let subtitle {
        MutedText(subtitle)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(24)
  }
}

extension SuiActivity: @retroactive Identifiable {
  public var id: String { digest }
}
