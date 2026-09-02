// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeAuroraPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ThemeAuroraPlugin",
            targets: ["ThemeAuroraPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "ThemeAuroraPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeAuroraPluginTests",
            dependencies: ["ThemeAuroraPlugin"],
            path: "Tests"
        )
    ]
)
