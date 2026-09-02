// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FileLogPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FileLogPlugin",
            targets: ["FileLogPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
    ],
    targets: [
        .target(
            name: "FileLogPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "FileLogPluginTests",
            dependencies: ["FileLogPlugin"],
            path: "Tests"
        )
    ]
)
