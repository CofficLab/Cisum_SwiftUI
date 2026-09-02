// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FactoryCisum",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "FactoryCisum",
            targets: ["FactoryCisum"]
        ),
    ],
    dependencies: [
        .package(name: "CisumKernel", path: "../CisumKernel"),
        .package(name: "CisumUI", path: "../CisumUI"),
        .package(name: "MagicKit", path: "../MagicKit"),
        .package(name: "MagicPlayMan", path: "../MagicPlayMan"),
        .package(name: "ProviderCloud", path: "../ProviderCloud"),
        .package(name: "ProviderDevice", path: "../ProviderDevice"),
        .package(name: "ProviderPlayback", path: "../ProviderPlayback"),
        .package(name: "ProviderPlugin", path: "../ProviderPlugin"),
        .package(name: "ProviderSettings", path: "../ProviderSettings"),
    ],
    targets: [
        .target(
            name: "FactoryCisum",
            dependencies: [
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "ProviderCloud", package: "ProviderCloud"),
                .product(name: "ProviderDevice", package: "ProviderDevice"),
                .product(name: "ProviderPlayback", package: "ProviderPlayback"),
                .product(name: "ProviderPlugin", package: "ProviderPlugin"),
                .product(name: "ProviderSettings", package: "ProviderSettings"),
            ],
            path: "Sources/FactoryCisum"
        ),
    ],
    swiftLanguageModes: [.v5]
)
