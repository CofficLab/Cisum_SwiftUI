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
        .package(name: "MagicPlayMan", path: "../MagicPlayMan"),
        .package(name: "ProviderPlayback", path: "../ProviderPlayback"),
    ],
    targets: [
        .target(
            name: "ProviderControlView",
            dependencies: [
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "ProviderPlayback", package: "ProviderPlayback"),
            ],
            path: "Sources/ProviderControlView"
        ),
    ],
    swiftLanguageModes: [.v5]
)
