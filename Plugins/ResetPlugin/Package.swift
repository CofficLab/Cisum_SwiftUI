// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ResetPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ResetPlugin",
            targets: ["ResetPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
    ],
    targets: [
        .target(
            name: "ResetPlugin",
            dependencies: [
                "CisumUI",
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ResetPluginTests",
            dependencies: ["ResetPlugin"],
            path: "Tests"
        )
    ]
)
