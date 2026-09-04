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
        .package(path: "../CisumUIComponents"),
        .package(name: "KernelCore", path: "../KernelCore"),
        .package(name: "MagicPlayMan", path: "../MagicPlayMan"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(name: "ProviderPlayback", path: "../ProviderPlayback"),
        .package(name: "ProviderStorage", path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "PluginPlayBack",
            dependencies: [
                "CisumUIComponents",
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                "ProviderDocsView",
                .product(name: "ProviderPlayback", package: "ProviderPlayback"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
            ],
            path: "Sources/PluginPlayBack"
        ),
    ],
    swiftLanguageModes: [.v5]
)
