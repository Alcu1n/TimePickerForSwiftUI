// [IN]: Swift Package Manager, standard Sources layout, and iOS package test coverage / Swift Package Manager、标准 Sources 布局与 iOS 包测试覆盖
// [OUT]: Distributable WheelPickerKit package manifest / 可分发的 WheelPickerKit 包清单
// [POS]: Declare a GitHub-ready library boundary plus minimal package validation / 声明适合 GitHub 分发的库边界并提供最小包级验证
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WheelPicker",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "WheelPickerKit",
            targets: ["WheelPickerKit"]
        )
    ],
    targets: [
        .target(
            name: "WheelPickerKit",
            exclude: [
                ".folder.md"
            ]
        ),
        .testTarget(
            name: "WheelPickerKitTests",
            dependencies: ["WheelPickerKit"],
            path: "Tests/WheelPickerKitTests",
            exclude: [
                ".folder.md"
            ]
        )
    ]
)
