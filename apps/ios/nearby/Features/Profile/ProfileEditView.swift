import SwiftUI
import UI

/// The minimal name-registration screen, pushed from the main profile page. The field binds straight
/// to the view model: each keystroke is parsed/validated there (a space is rejected, not stripped) and
/// drives a debounced availability check — the same decoupled pattern as the send recipient field.
struct ProfileEditView: View {
  @ObservedObject var viewModel: ProfileViewModel

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        MutedText(
          "Choose your unique Nearby handle. This registers an on-chain sub-domain under nearby.sui and cannot be changed."
        )

        HStack {
          Input("username", text: nameBinding)
            .disabled(viewModel.isSaving)
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

          Text(".nearby.sui")
            .foregroundColor(.secondary)
        }

        if let status = viewModel.statusMessage {
          Text(status)
            .font(.caption)
            .foregroundColor(viewModel.isAvailable ? .green : .red)
        }

        UIButton(
          viewModel.isSaving ? "Registering…" : "Register",
          isDisabled: !viewModel.isAvailable || viewModel.isSaving
        ) {
          Task { await viewModel.registerName() }
        }
      }
      .padding(24)
    }
    .navigationTitle("Choose your name")
    .navigationBarTitleDisplayMode(.inline)
    .onChange(of: viewModel.suinsName) { _, newValue in
      // Registered → pop back to the main page (which now shows the Registered badge). In setup mode
      // the view model's `onFinish` already routes home, so this is a harmless no-op there.
      if newValue != nil { dismiss() }
    }
  }

  private var nameBinding: Binding<String> {
    Binding(
      get: { viewModel.nameInput },
      set: { viewModel.onNameInputChange($0) }
    )
  }
}
