// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CisumFactory",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "CisumFactory",
            targets: ["CisumFactory"]
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
    ],
    targets: [
        .target(
            name: "CisumFactory",
            dependencies: [
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "ProviderCloud", package: "ProviderCloud"),
                .product(name: "ProviderDevice", package: "ProviderDevice"),
                .product(name: "ProviderPlayback", package: "ProviderPlayback"),
                .product(name: "ProviderPlugin", package: "ProviderPlugin"),
            ],
            path: "Sources/CisumFactory"
        ),
    ],
    swiftLanguageModes: [.v5]
)
