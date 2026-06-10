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
  dependencies: [
    .package(url: "https://github.com/elai950/AlertToast", from: "1.3.9")
  ],
  targets: [
    .target(
      name: "UI",
      dependencies: [
        .product(name: "AlertToast", package: "AlertToast")
      ]
    ),
    .testTarget(
      name: "UITests",
      dependencies: ["UI"]
    ),
  ]
)
