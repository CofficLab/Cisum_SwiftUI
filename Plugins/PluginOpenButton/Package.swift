// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginOpenButton",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginOpenButton",
            targets: ["PluginOpenButton"]
        )
    ],
    dependencies: [
        .package(path: "../Packages/CisumUI"),
        .package(path: "../Packages/MagicKit"),
        .package(url: "https://github.com/nookery/MagicPlayMan", from: "1.3.2"),
    ],
    targets: [
        .target(
            name: "PluginOpenButton",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: "Sources/PluginOpenButton"
        ),
        .testTarget(
            name: "PluginOpenButtonTests",
            dependencies: ["PluginOpenButton"],
            path: "Tests/PluginOpenButtonTests"
        )
    ]
)
