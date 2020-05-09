// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Taxii2Client",
    platforms: [
         .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        .library(
            name: "Taxii2Client",
            targets: ["Taxii2Client"]),
    ],
    dependencies: [
        .package(name: "GenericJSON", url: "https://github.com/zoul/generic-json-swift.git", from: "2.0.1")
    ],
    targets: [
        .target(
            name: "Taxii2Client",
            dependencies: ["GenericJSON"]),

    ]
)
