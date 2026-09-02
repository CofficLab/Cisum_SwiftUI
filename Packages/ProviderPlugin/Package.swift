// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderPlugin", targets: ["ProviderPlugin"]),
    ],
    dependencies: [
        .package(name: "CisumUI", path: "../CisumUI"),
    ],
    targets: [
        .target(
            name: "ProviderPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
            ],
            path: "Sources/ProviderPlugin"
        ),
    ],
    swiftLanguageModes: [.v5]
)
