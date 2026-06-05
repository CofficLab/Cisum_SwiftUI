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
    ],
    targets: [
        .target(
            name: "BookScenePlugin",
            dependencies: [
                "CisumUI",
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
