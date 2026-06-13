// swift-tools-version: 6.3
// Outer manifest: builds LeanSuiBCS as a product for the wider workspace,
// sourcing from the inner LeanSuiBCSCore package-in-package.
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
      type: .dynamic,
      targets: ["LeanSuiBCS"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/vaariance/swift-java.git", branch: "peter/swift-java-callbackdeps"),
    .package(url: "https://github.com/MarcoDotIO/UInt256.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "LeanSuiBCS",
      dependencies: [
        .product(name: "SwiftJava", package: "swift-java"),
        .product(name: "UInt256", package: "UInt256"),
      ],
      path: "LeanSuiBCSCore/Sources/LeanSuiBCS",
      exclude: [
        "swift-java.config"
      ],
      swiftSettings: [
        .swiftLanguageMode(.v5)
      ],
      plugins: [
        .plugin(name: "JExtractSwiftPlugin", package: "swift-java")
      ]
    ),
    .testTarget(
      name: "LeanSuiBCSTests",
      dependencies: ["LeanSuiBCS"],
      path: "LeanSuiBCSCore/Tests/LeanSuiBCSTests"
    ),
  ],
)
