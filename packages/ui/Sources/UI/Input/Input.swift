import SwiftUI

/// A single-line text input with consistent styling. Matches the Android `Input` primitive.
public struct Input: View {
  @Binding private var text: String

  private let placeholder: String

  public init(_ placeholder: String, text: Binding<String>) {
    self.placeholder = placeholder
    self._text = text
  }

  public var body: some View {
    TextField(placeholder, text: $text)
      .textFieldStyle(.roundedBorder)
      .autocorrectionDisabled()
      #if os(iOS)
        .textInputAutocapitalization(.never)
      #endif
  }
}

#Preview {
  Input("username", text: .constant("alice"))
    .padding()
}
