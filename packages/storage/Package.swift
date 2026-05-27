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
    )
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-java", from: "0.3.0")
  ],
  targets: [
    .target(
      name: "Storage",
      path: "Sources/Storage"
    ),
    .testTarget(
      name: "StorageTests",
      dependencies: ["Storage"],
      path: "Tests/StorageTests"
    ),
  ]
)
