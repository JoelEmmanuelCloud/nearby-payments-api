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
    .package(url: "https://github.com/sunghyun-k/swiftui-toasts", from: "1.1.2")
  ],
  targets: [
    .target(
      name: "UI",
      dependencies: [
        // iOS-only (UIKit window overlay); macOS gets a passthrough `ToastHost`.
        .product(name: "Toasts", package: "swiftui-toasts", condition: .when(platforms: [.iOS]))
      ]
    ),
    .testTarget(
      name: "UITests",
      dependencies: ["UI"]
    ),
  ]
)
