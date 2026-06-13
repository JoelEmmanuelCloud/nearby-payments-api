// swift-tools-version: 6.3
import PackageDescription

let package = Package(
  name: "Storage",
  platforms: [
    .macOS(.v15),
    .iOS(.v26),
  ],
  products: [
    .library(
      name: "Storage",
      targets: ["Storage"]
    )
  ],
  targets: [
    .target(
      name: "Storage",
      path: "Sources/Storage",
      exclude: [
        "swift-java.config"
      ]
    ),
    .testTarget(
      name: "StorageTests",
      dependencies: ["Storage"],
      path: "Tests/StorageTests"
    ),
  ]
)
