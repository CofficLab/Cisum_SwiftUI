// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AudioLikePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioLikePlugin",
            targets: ["AudioLikePlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../AudioScenePlugin"),
        .package(path: "../../Packages/MagicKit"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.0"),
        .package(path: "../../Packages/MagicPlayMan")
    ],
    targets: [
        .target(
            name: "AudioLikePlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "AudioScenePlugin", package: "AudioScenePlugin"),
                .product(name: "MagicAlert", package: "MagicAlert"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioLikePluginTests",
            dependencies: ["AudioLikePlugin"],
            path: "Tests"
        )
    ]
)
