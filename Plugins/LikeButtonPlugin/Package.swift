// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LikeButtonPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LikeButtonPlugin",
            targets: ["LikeButtonPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "LikeButtonPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "LikeButtonPluginTests",
            dependencies: ["LikeButtonPlugin"],
            path: "Tests"
        )
    ]
)
