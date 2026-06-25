// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-memory-inline-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Memory Inline Primitives",
            targets: ["Memory Inline Primitives"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-memory-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-allocation-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Inline raw byte region (element-free; @_rawLayout(likeArrayOf: UInt8, count: n); conforms Memory.Region)
        //
        // Post dependency-inversion, the inline leaf depends on allocation-primitives to declare its
        // Memory.Allocatable adopt-role conformance (NO Memory.Growable — fixed capacity cannot be
        // freshly allocated to a byte count). The edge points inline → allocation.
        .target(
            name: "Memory Inline Primitives",
            dependencies: [
                .product(name: "Memory Primitive", package: "swift-memory-primitives"),
                .product(name: "Memory Region Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Address Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Allocator Protocol Primitives", package: "swift-memory-allocation-primitives"),
            ]
        ),
        .testTarget(
            name: "Memory Inline Primitives Tests",
            dependencies: [
                "Memory Inline Primitives",
                .product(name: "Memory Allocation Primitives", package: "swift-memory-allocation-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("RawLayout"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
