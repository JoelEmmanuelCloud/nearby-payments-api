// swift-tools-version: 6.3
// Inner manifest: standalone development + testing of the LeanSui module
// (no swift-java plugin). Run from this directory:
//   swift build
//   swift test
import PackageDescription

let package = Package(
  name: "LeanSui",
  platforms: [
    .iOS(.v26),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "LeanSui",
      targets: ["LeanSui"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/MarcoDotIO/UInt256.git", from: "1.0.0"),
    .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
    .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"4.0.0"),
    .package(name: "HSM", path: "../../hsm/HSMCore"),
    .package(name: "LeanSuiApi", path: "../../sui-api/LeanSuiApiCore"),
    .package(name: "LeanSuiBCS", path: "../../sui-bcs/LeanSuiBCSCore"),
  ],
  targets: [
    .target(
      name: "LeanSui",
      dependencies: [
        .product(name: "BigInt", package: "BigInt"),
        .product(name: "UInt256", package: "UInt256"),
        .product(name: "Crypto", package: "swift-crypto"),
        .product(name: "HSM", package: "HSM"),
        .product(name: "LeanSuiApi", package: "LeanSuiApi"),
        .product(name: "LeanSuiBCS", package: "LeanSuiBCS"),
      ],
      path: "Sources/LeanSui",
      exclude: [
        "swift-java.config"
      ]
    ),
    .testTarget(
      name: "LeanSuiTests",
      dependencies: ["LeanSui"],
      path: "Tests/LeanSuiTests"
    ),
  ],
  swiftLanguageModes: [.v6]
)
