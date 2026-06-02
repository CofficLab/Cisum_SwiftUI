// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BookScenePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BookScenePlugin",
            targets: ["BookScenePlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "BookScenePlugin",
            dependencies: [
                "CisumUI",
                .product(name: "MagicAlert", package: "MagicAlert"),
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookScenePluginTests",
            dependencies: ["BookScenePlugin"],
            path: "Tests"
        )
    ]
)
