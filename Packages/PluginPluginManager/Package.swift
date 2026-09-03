// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPluginManager",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "PluginPluginManager", targets: ["PluginPluginManager"]),
    ],
    dependencies: [
        .package(name: "KernelCore", path: "../KernelCore"),
        .package(name: "CisumUIComponents", path: "../CisumUIComponents"),
        .package(name: "ProviderPluginManaging", path: "../ProviderPluginManaging"),
    ],
    targets: [
        .target(
            name: "PluginPluginManager",
            dependencies: [
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "ProviderPluginManaging", package: "ProviderPluginManaging"),
            ],
            path: "Sources/PluginPluginManager"
        ),
    ],
    swiftLanguageModes: [.v5]
)
