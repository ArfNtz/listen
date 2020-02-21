// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "listen",
    products: [
        .library(name: "listen", targets: ["listen"]),
        .executable(name: "listener", targets: ["listener"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "listen",
            dependencies: ["NIO","NIOHTTP1","NIOSSL"]),
        .target(
            name: "listener",
            dependencies: ["listen"]),
        .testTarget(
            name: "listenTests",
            dependencies: ["listen"]),
    ]
)
