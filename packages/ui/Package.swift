// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "UI",
  platforms: [
    .iOS(26),
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
