import Gateway
import SwiftUI

struct HomeProviderIconView: View {
  let currentProvider: OAuthProvider?

  var body: some View {
    switch currentProvider {
    case .google:
      Image("GoogleG")
        .resizable()
        .scaledToFit()
        .frame(width: 18, height: 18)

    case .apple:
      Image(systemName: "apple.logo")
        .resizable()
        .scaledToFit()
        .frame(width: 16, height: 18)
        .foregroundColor(.primary)

    default:
      Image(systemName: "checkmark.seal.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 20, height: 20)
        .foregroundColor(.blue)
    }
  }
}
