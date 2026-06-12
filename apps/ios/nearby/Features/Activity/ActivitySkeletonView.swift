import SwiftUI
import UI

/// Placeholder rows shown while the activity feed loads. Mirrors `ActivityRowView`'s layout so real
/// rows slot in without a jump, and reuses the shared `Skeleton` shimmer for visual cohesion.
struct ActivitySkeletonView: View {
  var body: some View {
    VStack(spacing: 0) {
      ForEach(0..<8, id: \.self) { _ in
        HStack(spacing: 12) {
          Skeleton(cornerRadius: 20)
            .frame(width: 40, height: 40)

          VStack(alignment: .leading, spacing: 6) {
            Skeleton().frame(width: 80, height: 14)
            Skeleton().frame(width: 120, height: 10)
          }

          Spacer()

          VStack(alignment: .trailing, spacing: 6) {
            Skeleton().frame(width: 70, height: 14)
            Skeleton().frame(width: 40, height: 10)
          }
        }
        .padding(.vertical, 8)
      }
    }
    .padding(16)
    .frame(maxHeight: .infinity, alignment: .top)
  }
}

#Preview {
  ActivitySkeletonView()
}
