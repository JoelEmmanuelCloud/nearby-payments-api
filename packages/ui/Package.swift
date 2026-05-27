// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "UI",
  platforms: [
    .iOS(.v26),
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "UI",
      targets: ["UI"]
    )
  ],
  targets: [
    .target(
      name: "UI"
    ),
    .testTarget(
      name: "UITests",
      dependencies: ["UI"]
    ),
  ]
)
