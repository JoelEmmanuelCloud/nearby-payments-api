// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "storage",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "Storage",
      targets: ["Storage"]
    ),
    .library(
      name: "SwiftStorage",
      type: .dynamic,
      targets: ["SwiftStorage"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-java", from: "0.3.0")
  ],
  targets: [
    .target(
      name: "StorageShared",
      path: "Sources/StorageShared"
    ),
    .target(
      name: "Storage",
      dependencies: ["StorageShared"],
      path: "Sources/Storage"
    ),
    .target(
      name: "SwiftStorage",
      dependencies: [
        "StorageShared",
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
      name: "StorageTests",
      dependencies: ["Storage"],
      path: "Tests/StorageTests"
    ),
  ]
)
