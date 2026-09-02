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
        .package(path: "../AudioPlugin"),
    ],
    targets: [
        .target(
            name: "StorePlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "AudioPlugin", package: "AudioPlugin"),
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
