// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderSettings",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderSettings", targets: ["ProviderSettings"]),
    ],
    dependencies: [
        .package(name: "CisumKernel", path: "../CisumKernel"),
        .package(name: "CisumUIComponents", path: "../CisumUIComponents"),
        // MARK: - Provider Contracts（设置窗口只依赖能力契约，不依赖内核/工厂）
        .package(name: "ProviderAppState", path: "../ProviderAppState"),
        .package(name: "ProviderPlugin", path: "../ProviderPlugin"),
        .package(name: "ProviderStorage", path: "../ProviderStorage"),
        .package(name: "ProviderTheme", path: "../ProviderTheme"),
    ],
    targets: [
        .target(
            name: "ProviderSettings",
            dependencies: [
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "ProviderAppState", package: "ProviderAppState"),
                .product(name: "ProviderPlugin", package: "ProviderPlugin"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
                .product(name: "ProviderTheme", package: "ProviderTheme"),
            ],
            path: "Sources/ProviderSettings"
        ),
    ],
    swiftLanguageModes: [.v5]
)
