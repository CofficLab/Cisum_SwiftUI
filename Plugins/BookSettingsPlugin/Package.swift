// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BookSettingsPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BookSettingsPlugin",
            targets: ["BookSettingsPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../BookPlugin")
    ],
    targets: [
        .target(
            name: "BookSettingsPlugin",
            dependencies: [
                "CisumUI",
                .product(name: "BookPlugin", package: "BookPlugin")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookSettingsPluginTests",
            dependencies: ["BookSettingsPlugin"],
            path: "Tests"
        )
    ]
)
