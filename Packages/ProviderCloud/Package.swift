// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderCloud",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderCloud", targets: ["ProviderCloud"]),
    ],
    targets: [
        .target(name: "ProviderCloud", path: "Sources/ProviderCloud"),
    ],
    swiftLanguageModes: [.v5]
)
