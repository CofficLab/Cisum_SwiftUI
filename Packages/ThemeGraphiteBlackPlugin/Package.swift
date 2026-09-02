// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeGraphiteBlackPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ThemeGraphiteBlackPlugin",
            targets: ["ThemeGraphiteBlackPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "ThemeGraphiteBlackPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeGraphiteBlackPluginTests",
            dependencies: ["ThemeGraphiteBlackPlugin"],
            path: "Tests"
        )
    ]
)
