// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPlayBack",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "PluginPlayBack", targets: ["PluginPlayBack"]),
    ],
    dependencies: [
        .package(name: "KernelCore", path: "../KernelCore"),
        .package(name: "MagicPlayMan", path: "../MagicPlayMan"),
        .package(name: "ProviderPlayback", path: "../ProviderPlayback"),
    ],
    targets: [
        .target(
            name: "PluginPlayBack",
            dependencies: [
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "ProviderPlayback", package: "ProviderPlayback"),
            ],
            path: "Sources/PluginPlayBack"
        ),
    ],
    swiftLanguageModes: [.v5]
)
