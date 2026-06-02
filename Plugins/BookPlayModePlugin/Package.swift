// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BookPlayModePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BookPlayModePlugin",
            targets: ["BookPlayModePlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../BookScenePlugin"),
        .package(path: "../../Packages/MagicKit"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.0"),
        .package(path: "../../Packages/MagicPlayMan")
    ],
    targets: [
        .target(
            name: "BookPlayModePlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "BookScenePlugin", package: "BookScenePlugin"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicAlert", package: "MagicAlert"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookPlayModePluginTests",
            dependencies: ["BookPlayModePlugin"],
            path: "Tests"
        )
    ]
)
