# WheelPicker

Premium SwiftUI wheel picker shipped as a Swift Package, with a separate demo app for tuning and visual verification.  
一个以 Swift Package 形式分发、并附带独立示例应用用于调参与视觉验证的高质感 SwiftUI 滚轮选择器。

## What The Package Actually Ships

The `WheelPickerKit` library product exports a clean picker component only:
- `TimerWheelPicker`
- `TimerWheelPickerStyle`

It does **not** ship the demo app's control panel, page copy, background composition, or info cards.  
`WheelPickerKit` 包产品只导出干净的 picker 组件本体：
- `TimerWheelPicker`
- `TimerWheelPickerStyle`

它**不包含**示例应用中的调参面板、页面文案、背景装饰或信息卡片。

## Installation

### Xcode
1. Open your app project in Xcode.
2. Go to `File > Add Package Dependencies...`.
3. Paste your GitHub repository URL.
4. Select the version rule you want.
5. Add the `WheelPickerKit` product to your target.

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/<your-account>/<your-repo>.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "WheelPickerKit", package: "WheelPicker")
        ]
    )
]
```

## Requirements

- iOS 18.0+
- macOS 15.0+ for package builds and tests
- Xcode 16+
- Swift 6 toolchain

## Quick Start

```swift
import SwiftUI
import WheelPickerKit

struct FocusTimerView: View {
    @State private var minutes = 30

    var body: some View {
        TimerWheelPicker(
            selection: $minutes,
            range: 5...180,
            step: 1,
            style: .premiumDemo
        )
        .padding()
        .background(Color.black)
    }
}
```

## API Surface

### `TimerWheelPicker`

```swift
TimerWheelPicker(
    selection: Binding<Int>,
    range: ClosedRange<Int> = 5...180,
    step: Int = 1,
    style: TimerWheelPickerStyle = .premiumDemo
)
```

- `selection`: Bound selected value. The current picker value is exposed here for the rest of your app. / 绑定的当前选中值。其他模块通过这里读取和写回 picker 数值。
- `range`: Inclusive value range. / 闭区间数值范围。
- `step`: Tick step size. Each step maps to one discrete tick. / 刻度步进。每一步都对应一个离散刻度。
- `style`: Visual and layout configuration. / 视觉与布局配置。

### `TimerWheelPickerStyle`

`TimerWheelPickerStyle` is split into three explicit groups instead of one giant mess:
- `colors`
- `layout`
- `typography`

`TimerWheelPickerStyle` 被拆成三组显式配置，而不是一坨难看的大对象：
- `colors`
- `layout`
- `typography`

#### Colors

```swift
TimerWheelPickerStyle.Colors(
    activeTint: .white,
    inactiveTint: Color.white.opacity(0.12),
    ringBackground: .green,
    tickGradient: Gradient(colors: [.cyan, .blue, .purple]),
    valueGradient: Gradient(colors: [.white, .mint])
)
```

- `activeTint`: Marker color. / 中央取值指示器颜色。
- `inactiveTint`: Subtle arc overlay color. / 圆弧弱化叠层颜色。
- `ringBackground`: Outer ring background color. / 外围圆环背景色。
- `tickGradient`: Tick colors across the wheel. / 刻度线沿滚轮分布的渐变色。
- `valueGradient`: Numeric value color mapping. / 中央数值颜色映射。

#### Layout

```swift
TimerWheelPickerStyle.Layout(
    dialHeight: 214,
    dialScale: 0.86,
    ringThickness: 44,
    ringBackgroundExtraWidth: 10,
    indicatorHeight: 28,
    indicatorWidth: 5,
    indicatorDotSize: 10,
    tickWidth: 3.3,
    tickSlotWidth: 5.2,
    gapBetweenTicks: -2.6,
    largeTickFrequency: 5,
    largeTickRatio: 0.68,
    smallTickRatio: 0.32
)
```

- `dialHeight`: Base wheel height before scaling. / 缩放前的基础高度。
- `dialScale`: Overall wheel scale. / wheel 整体缩放比例。
- `ringThickness`: Main ring thickness. / 主圆环厚度。
- `ringBackgroundExtraWidth`: Extra width behind the main ring. / 圆环背景相对主圆环增加的厚度。
- `indicatorHeight`: Marker capsule height. / 指示器胶囊高度。
- `indicatorWidth`: Marker capsule width. / 指示器胶囊宽度。
- `indicatorDotSize`: Marker dot size. / 指示器圆点大小。
- `tickWidth`: Tick line width. / 刻度线宽度。
- `tickSlotWidth`: Horizontal slot per tick. / 每个刻度占用的水平槽宽。
- `gapBetweenTicks`: Tick spacing adjustment. / 刻度之间的间距修正。
- `largeTickFrequency`: Frequency of major ticks. / 主刻度出现频率。
- `largeTickRatio`: Height ratio for major ticks. / 主刻度高度比例。
- `smallTickRatio`: Height ratio for minor ticks. / 次刻度高度比例。

#### Typography

```swift
TimerWheelPickerStyle.Typography(
    valueFontSize: 58,
    unitFontSize: 14,
    unitLabel: "MIN"
)
```

- `valueFontSize`: Main numeric font size. / 数值字号。
- `unitFontSize`: Unit label font size. / 单位字号。
- `unitLabel`: Unit label shown below the value. / 数值下方显示的单位文字。

## Customization Example

```swift
import SwiftUI
import WheelPickerKit

struct CustomTimerView: View {
    @State private var duration = 45

    private let style = TimerWheelPickerStyle(
        colors: .init(
            activeTint: .white,
            inactiveTint: Color.white.opacity(0.10),
            ringBackground: Color(hue: 0.36, saturation: 0.80, brightness: 0.94),
            tickGradient: Gradient(colors: [.cyan, .blue, .indigo]),
            valueGradient: Gradient(colors: [.white, .mint])
        ),
        layout: .init(
            dialHeight: 196,
            dialScale: 0.82,
            ringThickness: 40,
            indicatorHeight: 24,
            tickWidth: 4
        ),
        typography: .init(
            valueFontSize: 52,
            unitFontSize: 12,
            unitLabel: "SEC"
        )
    )

    var body: some View {
        TimerWheelPicker(
            selection: $duration,
            range: 10...300,
            step: 5,
            style: style
        )
    }
}
```

## Repository Structure

- `Package.swift`: Swift Package manifest exporting `WheelPickerKit`. / 导出 `WheelPickerKit` 的 Swift Package 清单。
- `Sources/WheelPickerKit/`: Shipped package source. / 实际分发的包源码。
- `WheelPicker/`: Demo app source and tuning UI. / 示例应用源码与调参界面。
- `WheelPicker.xcodeproj/`: Xcode project for local development and demo running. / 用于本地开发和运行示例的 Xcode 工程。

## Publishing Notes

- Push this repository to GitHub.
- Create semantic version tags such as `1.0.0`.
- Use those tags as your package version rules in Xcode.

将此仓库推送到 GitHub 后：
- 打上语义化版本标签，例如 `1.0.0`
- 在 Xcode 中按版本规则接入
- 以后通过 tag 管理升级，而不是靠裸分支

## GitHub Push Steps

What you need to do on your side:
1. Create an empty GitHub repository.
2. Copy its HTTPS or SSH URL.
3. In this local project, run:

```bash
git remote add origin <your-github-repo-url>
git add .
git commit -m "Prepare WheelPickerKit for GitHub distribution"
git branch -M main
git push -u origin main
git tag 1.0.0
git push origin 1.0.0
```

Then in another app:
1. Open Xcode.
2. `File > Add Package Dependencies...`
3. Paste the same GitHub URL.
4. Select version rule `Up to Next Major Version` from `1.0.0`.
5. Add product `WheelPickerKit`.

你这边需要做的操作：
1. 在 GitHub 上创建一个空仓库。
2. 复制它的 HTTPS 或 SSH 地址。
3. 在当前本地项目里执行：

```bash
git remote add origin <你的 GitHub 仓库地址>
git add .
git commit -m "Prepare WheelPickerKit for GitHub distribution"
git branch -M main
git push -u origin main
git tag 1.0.0
git push origin 1.0.0
```

之后在另一个 app 的 Xcode 里：
1. 打开 `File > Add Package Dependencies...`
2. 粘贴同一个 GitHub 地址
3. 版本规则选 `Up to Next Major Version`
4. 起始版本填 `1.0.0`
5. 添加产品 `WheelPickerKit`

## Pre-Push Checklist

- Confirm the repository URL is correct.
- Decide your license before making the repo public.
- Test package integration once from a clean app target.
- Keep semantic version tags stable after publishing.

- 确认仓库地址正确。
- 在仓库公开前先决定许可证。
- 至少在一个干净 app target 中测试一次包集成。
- 发布后不要随意重写已公开的语义化版本标签。

## Sync Protocol

- `Sources/WheelPickerKit/` contains the distributable module. / `Sources/WheelPickerKit/` 保存真正可分发的模块。
- `WheelPicker/` contains demo-only UI and must not leak into the library product. / `WheelPicker/` 只保存示例 UI，不得泄漏进库产品。
- `TimerWheelPicker` owns the public API and exposes the selected value through `Binding<Int>`. / `TimerWheelPicker` 负责公开 API，并通过 `Binding<Int>` 暴露选中值。
- When files, boundaries, or responsibilities change, update file headers and relevant `.folder.md` maps in the same change. / 当文件、边界或职责变化时，必须在同一修改中同步更新文件头注释与相关 `.folder.md` 地图。
