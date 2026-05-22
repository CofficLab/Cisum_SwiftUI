// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DeviceData",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "CisumDeviceData",
            targets: ["CisumDeviceData"]
        )
    ],
    targets: [
        .target(
            name: "CisumDeviceData"
        ),
        .testTarget(
            name: "CisumDeviceDataTests",
            dependencies: ["CisumDeviceData"]
        )
    ]
)
