// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemePaperPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ThemePaperPlugin",
            targets: ["ThemePaperPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "ThemePaperPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemePaperPluginTests",
            dependencies: ["ThemePaperPlugin"],
            path: "Tests"
        )
    ]
)
