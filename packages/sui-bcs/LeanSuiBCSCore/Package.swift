// swift-tools-version: 6.3
// Inner manifest: standalone development of the SuiBCS module.
//   swift build
//   swift test
import PackageDescription

let package = Package(
  name: "LeanSuiBCS",
  platforms: [
    .iOS(.v26),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "LeanSuiBCS",
      targets: ["LeanSuiBCS"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/MarcoDotIO/UInt256.git", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "LeanSuiBCS",
      dependencies: [
        .product(name: "UInt256", package: "UInt256")
      ],
      path: "Sources/LeanSuiBCS"
    ),
    .testTarget(
      name: "LeanSuiBCSTests",
      dependencies: ["LeanSuiBCS"],
      path: "Tests/LeanSuiBCSTests"
    ),
  ],
  swiftLanguageModes: [.v6]
)
