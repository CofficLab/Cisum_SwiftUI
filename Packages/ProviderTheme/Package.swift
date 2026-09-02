// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderTheme",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderTheme", targets: ["ProviderTheme"]),
    ],
    dependencies: [
        .package(name: "CisumUI", path: "../CisumUI"),
    ],
    targets: [
        .target(
            name: "ProviderTheme",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
            ],
            path: "Sources/ProviderTheme"
        ),
    ],
    swiftLanguageModes: [.v5]
)
