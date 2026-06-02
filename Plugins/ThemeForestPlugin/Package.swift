// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeForestPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ThemeForestPlugin",
            targets: ["ThemeForestPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "ThemeForestPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeForestPluginTests",
            dependencies: ["ThemeForestPlugin"],
            path: "Tests"
        )
    ]
)
