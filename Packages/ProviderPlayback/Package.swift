// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderPlayback",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderPlayback", targets: ["ProviderPlayback"]),
    ],
    dependencies: [
        .package(name: "MagicPlayMan", path: "../MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "ProviderPlayback",
            dependencies: [
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: ".",
            sources: ["Sources/ProviderPlayback"],
            resources: [.process("Resources")]
        ),
    ],
    swiftLanguageModes: [.v5]
)
