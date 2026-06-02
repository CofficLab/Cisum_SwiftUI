// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeCisumPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ThemeCisumPlugin",
            targets: ["ThemeCisumPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "ThemeCisumPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeCisumPluginTests",
            dependencies: ["ThemeCisumPlugin"],
            path: "Tests"
        )
    ]
)
