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
        .package(name: "CisumKernel", path: "../CisumKernel"),
        .package(name: "CisumUI", path: "../CisumUI"),
        .package(name: "ProviderPluginManaging", path: "../ProviderPluginManaging"),
    ],
    targets: [
        .target(
            name: "PluginPluginManager",
            dependencies: [
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "ProviderPluginManaging", package: "ProviderPluginManaging"),
            ],
            path: "Sources/PluginPluginManager"
        ),
    ],
    swiftLanguageModes: [.v5]
)
