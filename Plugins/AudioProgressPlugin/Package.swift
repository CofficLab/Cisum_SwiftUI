// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AudioProgressPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioProgressPlugin",
            targets: ["AudioProgressPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../AudioPlugin"),
        .package(path: "../AudioScenePlugin"),
        .package(path: "../AudioLikePlugin"),
        .package(path: "../../Packages/MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "AudioProgressPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "AudioPlugin", package: "AudioPlugin"),
                .product(name: "AudioScenePlugin", package: "AudioScenePlugin"),
                .product(name: "AudioLikePlugin", package: "AudioLikePlugin"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioProgressPluginTests",
            dependencies: ["AudioProgressPlugin"],
            path: "Tests"
        )
    ]
)
