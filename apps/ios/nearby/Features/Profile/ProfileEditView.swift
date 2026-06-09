import SwiftUI
import UI

/// The minimal name-registration screen, pushed from the main profile page. The text field is driven
/// by local `@State` (typing stays fluid — keystrokes don't round-trip through the view model), and
/// only sanitized, debounced values are pushed to the view model for the availability check.
struct ProfileEditView: View {
  @ObservedObject var viewModel: ProfileViewModel

  @Environment(\.dismiss) private var dismiss

  @State private var name = ""

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        MutedText(
          "Choose your unique Nearby handle. This registers an on-chain sub-domain under nearby.sui and cannot be changed."
        )

        HStack {
          TextField("username", text: $name)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .disabled(viewModel.isSaving)
            .onChange(of: name) { _, newValue in
              let clean = ProfileViewModel.sanitize(newValue)
              if clean != newValue { name = clean }  // reflect sanitization in the field
              viewModel.onNameInputChange(clean)
            }

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
          isDisabled: !viewModel.isAvailable || viewModel.isSaving || name.isEmpty
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
}
