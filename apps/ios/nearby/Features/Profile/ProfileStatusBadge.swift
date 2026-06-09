import SwiftUI

/// The resolving element on the profile page: a spinner while loading, a "Registered" pill once a
/// name exists, or a "Set up name" button that routes to the edit screen. Because this is the only
/// part that changes after load, the page never flips between edit/locked layouts.
struct ProfileStatusBadge: View {
  let isLoading: Bool
  let isRegistered: Bool
  let onSetUp: () -> Void

  var body: some View {
    if isLoading {
      ProgressView()
    } else if isRegistered {
      Text("Registered")
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.green.opacity(0.15))
        .foregroundColor(.green)
        .clipShape(Capsule())
    } else {
      Button("Set up name", action: onSetUp)
        .buttonStyle(.borderedProminent)
        .controlSize(.small)
    }
  }
}

#Preview("Loading") {
  ProfileStatusBadge(isLoading: true, isRegistered: false, onSetUp: {})
}

#Preview("Registered") {
  ProfileStatusBadge(isLoading: false, isRegistered: true, onSetUp: {})
}

#Preview("Set up") {
  ProfileStatusBadge(isLoading: false, isRegistered: false, onSetUp: {})
}
