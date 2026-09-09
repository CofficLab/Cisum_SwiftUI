// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderAudioLike",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderAudioLike", targets: ["ProviderAudioLike"]),
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
    ],
    targets: [
        .target(
            name: "ProviderAudioLike",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
            ],
            path: ".",
            sources: ["Sources/ProviderAudioLike"],
            resources: [
                .process("Resources/Localizable.xcstrings"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
