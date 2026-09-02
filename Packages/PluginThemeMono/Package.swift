// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeMonoPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ThemeMonoPlugin",
            targets: ["ThemeMonoPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "ThemeMonoPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeMonoPluginTests",
            dependencies: ["ThemeMonoPlugin"],
            path: "Tests"
        )
    ]
)
