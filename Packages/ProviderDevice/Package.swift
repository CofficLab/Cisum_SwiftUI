// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderDevice",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderDevice", targets: ["ProviderDevice"]),
    ],
    targets: [
        .target(name: "ProviderDevice", path: ".",
            sources: ["Sources/ProviderDevice"],
            resources: [.process("Resources")]),
    ],
    swiftLanguageModes: [.v5]
)
