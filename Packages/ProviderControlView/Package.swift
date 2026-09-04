// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderControlView",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderControlView", targets: ["ProviderControlView"]),
    ],
    dependencies: [
        .package(name: "CisumUIComponents", path: "../CisumUIComponents"),
        .package(name: "MagicPlayMan", path: "../MagicPlayMan"),
        .package(name: "ProviderPlayback", path: "../ProviderPlayback"),
    ],
    targets: [
        .target(
            name: "ProviderControlView",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "ProviderPlayback", package: "ProviderPlayback"),
            ],
            path: ".",
            sources: ["Sources/ProviderControlView"],
            resources: [.process("Resources")]
        ),
    ],
    swiftLanguageModes: [.v5]
)
