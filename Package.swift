// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TipTopPaySDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "TipTopPay",
            targets: ["TipTopPay"]
        ),
        .library(
            name: "TipTopPayNetworking",
            targets: ["TipTopPayNetworking"]
        )
    ],
    targets: [
        .target(
            name: "TipTopPay",
            dependencies: [
                "TipTopPayNetworking"
            ],
            path: "sdk",
            exclude: [
                "Pods",
                "sdk-Bridging-Header.h"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "TipTopPayNetworking",
            path: "networking",
            sources: ["source"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
