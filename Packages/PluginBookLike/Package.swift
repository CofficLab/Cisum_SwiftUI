// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BookLikePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BookLikePlugin",
            targets: ["BookLikePlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../BookScenePlugin"),
        .package(path: "../../Packages/MagicPlayMan")
    ],
    targets: [
        .target(
            name: "BookLikePlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "BookScenePlugin", package: "BookScenePlugin"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookLikePluginTests",
            dependencies: ["BookLikePlugin"],
            path: "Tests"
        )
    ]
)
