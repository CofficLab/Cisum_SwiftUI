// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderAudioLibrary",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderAudioLibrary", targets: ["ProviderAudioLibrary"]),
    ],
    dependencies: [
        .package(path: "../MagicKit"),
        .package(path: "../CisumUIComponents"),
        .package(path: "../ProviderAudioLike"),
        .package(path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "ProviderAudioLibrary",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "ProviderAudioLike", package: "ProviderAudioLike"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
            ],
            path: ".",
            sources: ["Sources/ProviderAudioLibrary"],
            resources: [.process("Resources")]
        ),
    ],
    swiftLanguageModes: [.v5]
)
