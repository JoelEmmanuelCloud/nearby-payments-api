// swift-tools-version: 6.3
// Outer manifest: builds LeanSuiApi as a product for swift-java.
// sourcing from the inner LeanSuiApiCore package-in-package.
import PackageDescription

let package = Package(
  name: "LeanSuiApi",
  platforms: [
    .iOS(.v26),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "LeanSuiApi",
      type: .dynamic,
      targets: ["LeanSuiApi"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/vaariance/swift-java.git", branch: "peter/swift-java-callbackdeps"),
    .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
    .package(path: "/Users/peter/Developer/apollo-ios"),
  ],
  targets: [
    .target(
      name: "LeanSuiApi",
      dependencies: [
        .product(name: "SwiftJava", package: "swift-java"),
        .product(name: "BigInt", package: "BigInt"),
        .product(name: "Apollo", package: "apollo-ios"),
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ],
      path: "LeanSuiApiCore/Sources/LeanSuiApi",
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
      name: "LeanSuiApiTests",
      dependencies: ["LeanSuiApi"],
      path: "LeanSuiApiCore/Tests/LeanSuiApiTests"
    ),
  ],
)
