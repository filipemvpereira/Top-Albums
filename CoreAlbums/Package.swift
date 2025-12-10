// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreAlbums",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CoreAlbums",
            targets: ["CoreAlbums"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0"),
        .package(path: "../Network")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CoreAlbums",
            dependencies: [
                "Swinject",
                "Network"
            ]
        ),
        .testTarget(
            name: "CoreAlbumsTests",
            dependencies: [
                "CoreAlbums",
            ],
        ),
    ]
)
