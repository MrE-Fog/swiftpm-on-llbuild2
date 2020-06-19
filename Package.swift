// swift-tools-version:5.1

// This source file is part of the Swift.org open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

import PackageDescription

let package = Package(
    name: "swiftpm-on-llbuild2",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.0.1"),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", from: "0.0.1"),
        .package(url: "https://github.com/apple/swift-llbuild2.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "LLBSwiftBuild",
            dependencies: [
                "llbuild2BuildSystem",
                "llbuild2Util"
            ]
        ),

        .target(
            name: "spmllb2",
            dependencies: [
                "ArgumentParser",
                "LLBSwiftBuild",
            ]
        ),

        .testTarget(
            name: "LLBSwiftBuildTests",
            dependencies: ["LLBSwiftBuild"]
        ),

        .target(
            name: "Workflow",
            path: "Sources/Workflows/Workflow"
        ),

        .target(
            name: "ExampleWorkflows",
            dependencies: ["Workflow"],
            path: "Sources/Workflows/ExampleWorkflows"
        ),
        .target(
            name: "spm-workflow",
            dependencies: [
                "ExampleWorkflows",
                "ArgumentParser",
                "SwiftToolsSupport-auto",
            ],
            path: "Sources/Workflows/spm-workflow"
        ),
    ]
)
