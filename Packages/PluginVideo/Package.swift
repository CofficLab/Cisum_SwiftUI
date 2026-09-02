// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VideoPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "VideoPlugin",
            targets: ["VideoPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "VideoPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "VideoPluginTests",
            dependencies: ["VideoPlugin"],
            path: "Tests"
        )
    ]
)
