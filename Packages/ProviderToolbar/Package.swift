// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderToolbar",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderToolbar", targets: ["ProviderToolbar"]),
    ],
    dependencies: [
        .package(name: "CisumKernel", path: "../CisumKernel"),
        .package(name: "ProviderPlugin", path: "../ProviderPlugin"),
    ],
    targets: [
        .target(
            name: "ProviderToolbar",
            dependencies: [
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "ProviderPlugin", package: "ProviderPlugin"),
            ],
            path: "Sources/ProviderToolbar"
        ),
    ],
    swiftLanguageModes: [.v5]
)
