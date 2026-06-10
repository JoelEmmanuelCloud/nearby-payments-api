// swift-tools-version: 6.3
import PackageDescription

let package = Package(
  name: "Identity",
  platforms: [
    .iOS(.v26),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "Identity",
      type: .dynamic,
      targets: ["Identity"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/vaariance/swift-java.git", branch: "peter/swift-java-callbackdeps"),
    .package(name: "gateway", path: "../gateway"),
    .package(name: "LeanSuiApi", path: "../sui-api"),
    .package(name: "Auth", path: "../auth"),
  ],
  targets: [
    .target(
      name: "Identity",
      dependencies: [
        .product(name: "SwiftJava", package: "swift-java"),
        .product(name: "Gateway", package: "gateway"),
        .product(name: "LeanSuiApi", package: "LeanSuiApi"),
        .product(name: "Auth", package: "Auth"),
      ],
      path: "IdentityCore/Sources/Identity",
      exclude: [
        "swift-java.config"
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
