// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BookProgressPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BookProgressPlugin",
            targets: ["BookProgressPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../BookPlugin"),
        .package(path: "../BookScenePlugin"),
        .package(path: "../../Packages/MagicPlayMan")
    ],
    targets: [
        .target(
            name: "BookProgressPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "BookPlugin", package: "BookPlugin"),
                .product(name: "BookScenePlugin", package: "BookScenePlugin"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookProgressPluginTests",
            dependencies: [
                "BookProgressPlugin",
                .product(name: "BookPlugin", package: "BookPlugin")
            ],
            path: "Tests"
        )
    ]
)
