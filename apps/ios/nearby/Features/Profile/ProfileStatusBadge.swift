import SwiftUI
import UI

/// The resolving element on the profile page: a "Registered" pill once a name exists, or a "Set up
/// name" button that routes to the edit screen. The loading state is a skeleton owned by `ProfileView`,
/// so this only ever renders a resolved result.
struct ProfileStatusBadge: View {
  let isRegistered: Bool
  let onSetUp: () -> Void

  var body: some View {
    if isRegistered {
      Badge("Registered", tone: .success)
    } else {
      Button("Set up name", action: onSetUp)
        .buttonStyle(.borderedProminent)
        .controlSize(.small)
    }
  }
}

#Preview("Registered") {
  ProfileStatusBadge(isRegistered: true, onSetUp: {})
}

#Preview("Set up") {
  ProfileStatusBadge(isRegistered: false, onSetUp: {})
}
