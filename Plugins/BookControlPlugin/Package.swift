// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BookControlPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BookControlPlugin",
            targets: ["BookControlPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../BookScenePlugin"),
        .package(path: "../BookPlugin"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../../Packages/MagicPlayMan")
    ],
    targets: [
        .target(
            name: "BookControlPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "BookScenePlugin", package: "BookScenePlugin"),
                .product(name: "BookPlugin", package: "BookPlugin"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookControlPluginTests",
            dependencies: ["BookControlPlugin"],
            path: "Tests"
        )
    ]
)
