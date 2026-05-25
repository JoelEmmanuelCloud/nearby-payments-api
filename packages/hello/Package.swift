// swift-tools-version: 6.2
import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "Hello",
  platforms: [
    .iOS(.v26)
  ],
  products: [
    .library(
      name: "SwiftHello",
      type: .dynamic,
      targets: ["SwiftHello"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-java", from: "0.3.0")
  ],
  targets: [
    .target(
      name: "SwiftHello",
      dependencies: [
        .product(name: "SwiftJava", package: "swift-java")
      ],
      path: "Sources/Java",
      exclude: [
        "HelloAndroid.kt",
        "swift-java.config",
      ],
      swiftSettings: [
        .swiftLanguageMode(.v5)
      ],
      plugins: [
        .plugin(name: "JExtractSwiftPlugin", package: "swift-java")
      ]
    )
  ]
)
