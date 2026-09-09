// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderBook",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderBook", targets: ["ProviderBook"]),
    ],
    dependencies: [
        .package(path: "../MagicKit"),
        .package(path: "../CisumUIComponents"),
    ],
    targets: [
        .target(
            name: "ProviderBook",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
            ],
            path: ".",
            sources: ["Sources/ProviderBook"],
            resources: [
                .process("Resources/Localizable.xcstrings"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
