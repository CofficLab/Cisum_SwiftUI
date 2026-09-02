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
        .package(name: "ProviderContentView", path: "../ProviderContentView"),
        .package(name: "ProviderDevice", path: "../ProviderDevice"),
        .package(name: "ProviderPlayback", path: "../ProviderPlayback"),
        .package(name: "ProviderPlugin", path: "../ProviderPlugin"),
        .package(name: "ProviderRootView", path: "../ProviderRootView"),
        .package(name: "ProviderSettings", path: "../ProviderSettings"),
        .package(name: "ProviderToolbar", path: "../ProviderToolbar"),
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
                .product(name: "ProviderContentView", package: "ProviderContentView"),
                .product(name: "ProviderDevice", package: "ProviderDevice"),
                .product(name: "ProviderPlayback", package: "ProviderPlayback"),
                .product(name: "ProviderPlugin", package: "ProviderPlugin"),
                .product(name: "ProviderRootView", package: "ProviderRootView"),
                .product(name: "ProviderSettings", package: "ProviderSettings"),
                .product(name: "ProviderToolbar", package: "ProviderToolbar"),
            ],
            path: "Sources/FactoryCisum"
        ),
    ],
    swiftLanguageModes: [.v5]
)
