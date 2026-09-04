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
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "ProviderRootView", package: "ProviderRootView"),
            ],
            path: ".",
            sources: ["Sources"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
