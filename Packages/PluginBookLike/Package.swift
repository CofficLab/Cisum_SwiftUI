// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookLike",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookLike",
            targets: ["PluginBookLike"]
        )
    ],
    dependencies: [
        .package(path: "../MagicKit"),
        .package(url: "https://github.com/nookery/MagicPlayMan", from: "1.3.2")
    ],
    targets: [
        .target(
            name: "PluginBookLike",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources/PluginBookLike",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginBookLikeTests",
            dependencies: ["PluginBookLike"],
            path: "Tests/PluginBookLikeTests"
        )
    ]
)
