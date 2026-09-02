// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderPluginManaging",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderPluginManaging", targets: ["ProviderPluginManaging"]),
    ],
    dependencies: [
        .package(name: "CisumKernel", path: "../CisumKernel"),
    ],
    targets: [
        .target(
            name: "ProviderPluginManaging",
            dependencies: [
                .product(name: "CisumKernel", package: "CisumKernel"),
            ],
            path: "Sources/ProviderPluginManaging"
        ),
    ],
    swiftLanguageModes: [.v5]
)
