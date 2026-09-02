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
    targets: [
        .target(name: "ProviderAudioLibrary", path: "Sources/ProviderAudioLibrary"),
    ],
    swiftLanguageModes: [.v5]
)
