// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RSDayFlow",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "RSDayFlow",
            targets: ["RSDayFlow"]),
    ],
    targets: [
        .target(
            name: "RSDayFlow",
            path: "RSDayFlow",
            publicHeadersPath: "include"
        ),
    ]
)
