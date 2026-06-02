// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AudioPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioPlugin",
            targets: ["AudioPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../AudioLikePlugin"),
        .package(url: "https://github.com/nookery/MagicAlert", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "AudioPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "AudioLikePlugin", package: "AudioLikePlugin"),
                .product(name: "MagicAlert", package: "MagicAlert")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioPluginTests",
            dependencies: ["AudioPlugin"],
            path: "Tests"
        )
    ]
)
