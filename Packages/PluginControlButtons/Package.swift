// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginControlButtons",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "PluginControlButtons",
            targets: ["PluginControlButtons"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(name: "KernelCore", path: "../KernelCore"),
        .package(name: "MagicPlayMan", path: "../MagicPlayMan"),
        .package(path: "../ProviderPlayback"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(name: "ProviderRootView", path: "../ProviderRootView"),
    ],
    targets: [
        .target(
            name: "PluginControlButtons",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "ProviderPlayback", package: "ProviderPlayback"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "ProviderRootView", package: "ProviderRootView"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [.process("Resources")]
        ),
    ],
    swiftLanguageModes: [.v5]
)
