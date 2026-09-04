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
        .package(name: "CisumUIComponents", path: "../CisumUIComponents"),
    ],
    targets: [
        .target(
            name: "ProviderTheme",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
            ],
            path: ".",
            sources: ["Sources/ProviderTheme"],
            resources: [.process("Resources")]
        ),
    ],
    swiftLanguageModes: [.v5]
)
