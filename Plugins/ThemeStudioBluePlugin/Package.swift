// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeStudioBluePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ThemeStudioBluePlugin",
            targets: ["ThemeStudioBluePlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "ThemeStudioBluePlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeStudioBluePluginTests",
            dependencies: ["ThemeStudioBluePlugin"],
            path: "Tests"
        )
    ]
)
