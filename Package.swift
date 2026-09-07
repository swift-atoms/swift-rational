// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-rational",
    platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
    products: [
        .library(name: "Rational", targets: ["Rational"]),

        .library(name: "Rational Foundation Integration", targets: ["Rational Foundation Integration"]),
        .library(name: "Rational Test Support", targets: ["Rational Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-integer.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-property.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-addition.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-subtraction.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-multiplication.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-division.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-magnitude.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-polarity.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Rational",
            dependencies: [
                .product(name: "Integer", package: "swift-integer"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Addition", package: "swift-addition"),
                .product(name: "Subtraction", package: "swift-subtraction"),
                .product(name: "Multiplication", package: "swift-multiplication"),
                .product(name: "Division", package: "swift-division"),
                .product(name: "Magnitude", package: "swift-magnitude"),
                .product(name: "Polarity", package: "swift-polarity"),
            ],
            path: "Sources/Rational"
        ),

        .target(
            name: "Rational Foundation Integration",
            dependencies: [
                .target(name: "Rational"),
            ],
            path: "Sources/Rational Foundation Integration"
        ),
        .target(
            name: "Rational Test Support",
            dependencies: [
                .target(name: "Rational"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Rational Tests",
            dependencies: [
                .target(name: "Rational"),
                .product(name: "Integer", package: "swift-integer"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Addition", package: "swift-addition"),
                .product(name: "Subtraction", package: "swift-subtraction"),
                .product(name: "Multiplication", package: "swift-multiplication"),
                .product(name: "Division", package: "swift-division"),
                .product(name: "Magnitude", package: "swift-magnitude"),
                .product(name: "Polarity", package: "swift-polarity"),
                .target(name: "Rational Test Support"),
                .target(name: "Rational Foundation Integration"),
            ],
            path: "Tests/Rational Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
