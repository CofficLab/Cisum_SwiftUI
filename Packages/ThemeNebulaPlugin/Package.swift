// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeNebulaPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ThemeNebulaPlugin",
            targets: ["ThemeNebulaPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "ThemeNebulaPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeNebulaPluginTests",
            dependencies: ["ThemeNebulaPlugin"],
            path: "Tests"
        )
    ]
)
