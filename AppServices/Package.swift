// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppServices",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AppServices",
            targets: ["AppServices"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "12.0.0"
        )
    ],
    targets: [
        .target(
            name: "AppServices",
            dependencies: [
                .product(
                    name: "FirebaseAuth",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "FirebaseFirestore",
                    package: "firebase-ios-sdk"
                )
            ]
        )
    ]
)
