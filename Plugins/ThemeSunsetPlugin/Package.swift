// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeSunsetPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ThemeSunsetPlugin",
            targets: ["ThemeSunsetPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "ThemeSunsetPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeSunsetPluginTests",
            dependencies: ["ThemeSunsetPlugin"],
            path: "Tests"
        )
    ]
)
