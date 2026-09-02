// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeDaylightSilverPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ThemeDaylightSilverPlugin",
            targets: ["ThemeDaylightSilverPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "ThemeDaylightSilverPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeDaylightSilverPluginTests",
            dependencies: ["ThemeDaylightSilverPlugin"],
            path: "Tests"
        )
    ]
)
