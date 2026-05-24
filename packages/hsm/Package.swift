// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "HSM",
  platforms: [
    .iOS(.v26),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "HSM",
      targets: ["HSM"]
    ),
    .library(
      name: "SwiftHSM",
      type: .dynamic,
      targets: ["SwiftHSM"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-java", from: "0.3.0")
  ],
  targets: [
    .target(
      name: "HSMShared",
      path: "Sources/Shared"
    ),
    .target(
      name: "HSM",
      dependencies: ["HSMShared"],
      path: "Sources/HSM"
    ),
    .target(
      name: "SwiftHSM",
      dependencies: [
        "HSMShared",
        .product(name: "SwiftJava", package: "swift-java"),
      ],
      path: "Sources/Java",
      swiftSettings: [
        .swiftLanguageMode(.v5)
      ],
      plugins: [
        .plugin(name: "JExtractSwiftPlugin", package: "swift-java")
      ]
    ),
    .testTarget(
      name: "HSMTests",
      dependencies: ["HSM"],
      path: "Tests/HSMTests"
    ),
  ]
)
