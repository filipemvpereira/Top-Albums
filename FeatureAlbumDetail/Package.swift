// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureAlbumDetail",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FeatureAlbumDetail",
            targets: ["FeatureAlbumDetail"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0"),
        .package(path: "../CoreAlbums"),
        .package(path: "../CoreUI"),
        .package(path: "../CoreResources")
    ],
    targets: [
        .target(
            name: "FeatureAlbumDetail",
            dependencies: [
                "Swinject",
                "CoreAlbums",
                "CoreUI",
                "CoreResources"
            ]
        ),
    ]
)
