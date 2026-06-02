// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StorePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "StorePlugin",
            targets: ["StorePlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../AudioPlugin"),
        .package(url: "https://github.com/nookery/MagicAlert", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "StorePlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "AudioPlugin", package: "AudioPlugin"),
                .product(name: "MagicAlert", package: "MagicAlert")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings"),
                .process("Resources/Products.storekit")
            ]
        ),
        .testTarget(
            name: "StorePluginTests",
            dependencies: ["StorePlugin"],
            path: "Tests"
        )
    ]
)
