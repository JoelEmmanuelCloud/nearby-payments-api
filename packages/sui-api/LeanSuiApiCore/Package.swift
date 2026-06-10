// swift-tools-version: 6.3
// Inner manifest: standalone development of the LeanSuiApi module.
// Run codegen and tests from this directory:
//   ./apollo-ios-cli generate
//   swift test
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
      targets: ["LeanSuiApi"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
    .package(path: "/Users/peter/Developer/apollo-ios"),
  ],
  targets: [
    .target(
      name: "LeanSuiApi",
      dependencies: [
        .product(name: "BigInt", package: "BigInt"),
        .product(name: "Apollo", package: "apollo-ios"),
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ],
      path: "Sources/LeanSuiApi"
    ),
    .testTarget(
      name: "LeanSuiApiTests",
      dependencies: ["LeanSuiApi"],
      path: "Tests/LeanSuiApiTests"
    ),
  ],
  swiftLanguageModes: [.v6]
)
