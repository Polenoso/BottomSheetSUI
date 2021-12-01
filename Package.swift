// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BottomSheetSUI",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "BottomSheetSUI",
            targets: ["BottomSheetSUI"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BottomSheetSUI",
            dependencies: []),
        .testTarget(
            name: "BottomSheetSUITests",
            dependencies: ["BottomSheetSUI"]),
    ]
)
