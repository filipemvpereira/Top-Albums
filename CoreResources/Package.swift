// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreResources",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CoreResources",
            targets: ["CoreResources"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0")
    ],
    targets: [
        .target(
            name: "CoreResources",
            dependencies: [
                "Swinject",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
