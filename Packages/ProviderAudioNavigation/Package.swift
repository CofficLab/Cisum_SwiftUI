// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderAudioNavigation",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderAudioNavigation", targets: ["ProviderAudioNavigation"]),
    ],
    targets: [
        .target(
            name: "ProviderAudioNavigation",
            path: ".",
            sources: ["Sources/ProviderAudioNavigation"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
