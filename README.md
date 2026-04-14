# WheelPicker

Premium SwiftUI wheel picker shipped as a Swift Package, with a separate immersive demo app for visual verification.  
一个以 Swift Package 形式分发、并附带独立沉浸式示例应用用于视觉验证的高质感 SwiftUI 滚轮选择器。

## What This Package Ships

`WheelPickerKit` exports only the reusable picker surface:
- `TimerWheelPicker`
- `TimerWheelPickerStyle`

It does not ship the demo app's background shell, screen layout, or any app-only buttons.  
`WheelPickerKit` 只导出可复用的选择器表面：
- `TimerWheelPicker`
- `TimerWheelPickerStyle`

它不包含示例应用里的背景外壳、页面布局或任何应用专属按钮。

## Requirements

- iOS 18.0+
- macOS 15.0+ for package builds and tests
- Xcode 16+
- Swift 6 toolchain

## Installation

### Xcode

1. Open your app project in Xcode.
2. Go to `File > Add Package Dependencies...`.
3. Paste your repository URL.
4. Choose a version rule.
5. Add the `WheelPickerKit` product to your app target.

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
            initialSelection: 30,
            style: .immersiveArc
        )
    }
}
```

## Selection Output

The picker writes its current value back through the `selection` binding. That means another app can read, display, persist, or react to the value with normal SwiftUI data flow.  
这个组件会通过 `selection` 绑定把当前值回写出去。这意味着其他 app 可以用标准 SwiftUI 数据流直接读取、展示、持久化或监听这个值。

```swift
import SwiftUI
import WheelPickerKit

struct TimerHostView: View {
    @State private var selectedMinutes = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Current value: \(selectedMinutes)")

            TimerWheelPicker(
                selection: $selectedMinutes,
                range: 5...180,
                step: 1,
                initialSelection: 30,
                style: .immersiveArc
            )
        }
        .onChange(of: selectedMinutes) { oldValue, newValue in
            print("Wheel changed from \(oldValue) to \(newValue)")
        }
    }
}
```

## Public API

### `TimerWheelPicker`

```swift
TimerWheelPicker(
    selection: Binding<Int>,
    range: ClosedRange<Int> = 5...180,
    step: Int = 1,
    initialSelection: Int = 30,
    style: TimerWheelPickerStyle = .premiumDemo
)
```

- `selection`: Bound selected value used for output and external control. / 绑定的当前选中值，用于组件输出和外部控制。
- `range`: Inclusive value range. / 闭区间数值范围。
- `step`: Tick step size. Each step maps to one discrete value. / 刻度步进。每一步都映射到一个离散值。
- `initialSelection`: Fallback value used on first appearance when the bound selection is outside the valid stepped range; defaults to `30` and snaps to the nearest valid step. / 当绑定值在首次出现时不落在合法步进范围内，组件会使用这个回退初始值；默认是 `30`，并会吸附到最近的合法步进值。
- `style`: Public visual configuration. / 公开视觉配置。

### Initial Value Behavior

There are now two intentional ways to control the first visible value:
- Set your own `@State` before presenting the picker if your app already owns a valid starting value. / 如果宿主 app 已经持有一个合法起始值，直接在展示前设置自己的 `@State`。
- Pass `initialSelection` when you want the picker to repair an invalid or unset binding on first appearance. / 如果你希望 picker 在首次显示时修正无效或未初始化的绑定值，则传入 `initialSelection`。

Example:

```swift
import SwiftUI
import WheelPickerKit

struct DefaultValueExample: View {
    @State private var selectedMinutes = 0

    var body: some View {
        TimerWheelPicker(
            selection: $selectedMinutes,
            range: 5...180,
            step: 5,
            initialSelection: 30,
            style: .immersiveArc
        )
    }
}
```

In this example, `selectedMinutes` starts at `0`, which is outside the valid stepped range. The picker will repair it to `30` on first appearance. If you pass `initialSelection: 33` with `step: 5`, it snaps to the nearest valid value.  
在这个例子里，`selectedMinutes` 初始为 `0`，不在合法步进范围内，因此 picker 会在首次出现时把它修正为 `30`。如果你传入 `initialSelection: 33` 且 `step: 5`，它会吸附到最近的合法值。

### `TimerWheelPickerStyle`

`TimerWheelPickerStyle` is intentionally split into three groups:
- `colors`
- `layout`
- `typography`

`TimerWheelPickerStyle` 被明确拆成三组：
- `colors`
- `layout`
- `typography`

#### Presets

- `.premiumDemo`: Keeps the original thicker wheel treatment. / 保留原始更厚重的滚轮视觉。
- `.immersiveArc`: Uses the full-width shallow arc treatment with tighter value placement and metallic ratchet feedback. / 使用全宽浅弧视觉，带更贴近弧线的数字布局和金属棘轮反馈。

## Customization API

The following knobs are public and intended for app-level customization.  
以下参数都已经是公开 API，设计目标就是让引入该组件的 app 进行高度定制。

### 1. Tick Color

Use `tickColor` when you want a single solid tick color.  
如果你只想要单色刻度，请使用 `tickColor`。

```swift
let colors = TimerWheelPickerStyle.Colors(
    tickColor: .white
)
```

If you want a multi-stop tick look, use `tickGradient`.  
如果你想要多段渐变刻度，则使用 `tickGradient`。

```swift
let colors = TimerWheelPickerStyle.Colors(
    tickGradient: Gradient(colors: [.cyan, .blue, .indigo])
)
```

### 2. Guide Arc Color

Use `guideArcTint` to customize the visible arc line color.  
使用 `guideArcTint` 自定义可见导向弧线颜色。

```swift
var colors = TimerWheelPickerStyle.Colors()
colors.guideArcTint = Color.white.opacity(0.9)
```

`inactiveTint` is still available for compatibility; `guideArcTint` is just the readable alias.  
`inactiveTint` 仍然保留以兼容旧写法；`guideArcTint` 只是更易懂的别名。

### 3. Numeric Font Size

Use `typography.valueFontSize` to control the large numeric text size.  
使用 `typography.valueFontSize` 控制中间大数字字号。

```swift
let typography = TimerWheelPickerStyle.Typography(
    valueFontSize: 96
)
```

### 4. Bottom Caption Text

Use `captionText` to customize the bottom text shown under the value.  
使用 `captionText` 自定义显示在数值下方的底部文本。

```swift
var typography = TimerWheelPickerStyle.Typography()
typography.captionText = "Relaxed"
```

`unitLabel` is still available for compatibility; `captionText` is the clearer alias because the text may be a mood label instead of a unit.  
`unitLabel` 仍然保留以兼容旧写法；`captionText` 是更清晰的别名，因为这段文字可能是状态文案而不是单位。

## Style Reference

### `TimerWheelPickerStyle.Colors`

```swift
TimerWheelPickerStyle.Colors(
    activeTint: .white,
    inactiveTint: Color.white.opacity(0.18),
    ringBackground: Color.white.opacity(0.24),
    tickGradient: Gradient(colors: [.white.opacity(0.8), .white]),
    tickColor: .white,
    valueGradient: Gradient(colors: [.white.opacity(0.92), .white])
)
```

- `activeTint`: Indicator dot color. / 顶部指示圆点颜色。
- `inactiveTint`: Visible guide arc tint. / 可见导向弧线颜色。
- `guideArcTint`: Readable alias of `inactiveTint`. / `inactiveTint` 的易读别名。
- `ringBackground`: Background arc color behind the guide arc. / 导向弧后方背景弧颜色。
- `tickGradient`: Gradient used by tick marks when `tickColor` is not set. / 未设置 `tickColor` 时刻度线使用的渐变。
- `tickColor`: Solid tick color override for single-color ticks. / 单色刻度的直接覆盖色。
- `valueGradient`: Numeric value color mapping. / 中央数值颜色映射。

### `TimerWheelPickerStyle.Layout`

```swift
TimerWheelPickerStyle.Layout(
    arcProfile: .fullWidthShallow,
    dialHeight: 346,
    dialScale: 1,
    ringThickness: 2,
    ringBackgroundExtraWidth: 0.8,
    indicatorHeight: 0,
    indicatorWidth: 0,
    indicatorDotSize: 16,
    tickWidth: 1.6,
    tickSlotWidth: 8,
    gapBetweenTicks: 2,
    largeTickFrequency: 10,
    largeTickRatio: 0.9,
    smallTickRatio: 0.52
)
```

- `arcProfile`: `.classic` or `.fullWidthShallow`. / `.classic` 或 `.fullWidthShallow`。
- `dialHeight`: Base wheel height. / wheel 基础高度。
- `dialScale`: Overall scale factor. / 整体缩放比例。
- `ringThickness`: Guide arc thickness. / 导向弧线厚度。
- `ringBackgroundExtraWidth`: Extra width behind the guide arc. / 背景弧相对导向弧额外增加的厚度。
- `indicatorHeight`: Capsule indicator height used by the classic profile. / 经典轮廓中胶囊指示器的高度。
- `indicatorWidth`: Capsule indicator width used by the classic profile. / 经典轮廓中胶囊指示器的宽度。
- `indicatorDotSize`: Indicator dot size. / 指示圆点大小。
- `tickWidth`: Tick line width. / 刻度线宽度。
- `tickSlotWidth`: Horizontal space reserved per tick. / 每个刻度的水平槽宽。
- `gapBetweenTicks`: Additional spacing adjustment between ticks. / 刻度之间的额外间距修正。
- `largeTickFrequency`: Major tick frequency. / 主刻度频率。
- `largeTickRatio`: Major tick height ratio. / 主刻度高度比例。
- `smallTickRatio`: Minor tick height ratio. / 次刻度高度比例。

### `TimerWheelPickerStyle.Typography`

```swift
TimerWheelPickerStyle.Typography(
    valueFontSize: 108,
    unitFontSize: 28,
    unitLabel: "Relaxed"
)
```

- `valueFontSize`: Large numeric text size. / 大数字字号。
- `unitFontSize`: Bottom caption font size. / 底部文案字号。
- `unitLabel`: Bottom caption text. / 底部文案文本。
- `captionText`: Readable alias of `unitLabel`. / `unitLabel` 的易读别名。

## Full Customization Example

```swift
import SwiftUI
import WheelPickerKit

struct CustomWheelExample: View {
    @State private var selectedValue = 0

    private var style: TimerWheelPickerStyle {
        var colors = TimerWheelPickerStyle.Colors(
            ringBackground: Color.white.opacity(0.18),
            tickColor: .white,
            valueGradient: Gradient(colors: [.white, .white.opacity(0.9)])
        )
        colors.guideArcTint = Color.white.opacity(0.92)

        var typography = TimerWheelPickerStyle.Typography(
            valueFontSize: 92,
            unitFontSize: 20,
            unitLabel: "Relaxed"
        )
        typography.captionText = "Wind Up"

        return TimerWheelPickerStyle(
            colors: colors,
            layout: .init(
                arcProfile: .fullWidthShallow,
                dialHeight: 320,
                dialScale: 1,
                ringThickness: 2,
                ringBackgroundExtraWidth: 1,
                indicatorDotSize: 14,
                tickWidth: 1.4,
                tickSlotWidth: 8,
                gapBetweenTicks: 2,
                largeTickFrequency: 10,
                largeTickRatio: 0.88,
                smallTickRatio: 0.5
            ),
            typography: typography
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Selected: \(selectedValue)")

            TimerWheelPicker(
                selection: $selectedValue,
                range: 0...120,
                step: 1,
                initialSelection: 30,
                style: style
            )
        }
    }
}
```

## API Contract Check

The package already exposes the selected value correctly through `Binding<Int>`, and it now also exposes `initialSelection` for first-load fallback control. This is the right contract for other SwiftUI apps, and the included tests cover both the external binding read/write path and the public initial-selection initializer surface.  
这个组件已经通过 `Binding<Int>` 正确暴露了选中值，并且现在也公开了 `initialSelection` 以控制首次加载时的回退默认值。这就是 SwiftUI app 最合适的接入契约，并且当前测试已经覆盖了外部绑定读写路径和公开的初始值初始化参数。

What this means in practice:
- The host app owns the source of truth. / 宿主 app 持有单一真值。
- The picker reads and writes that value. / picker 负责读取和回写这个值。
- The host app can use `.onChange`, persistence, analytics, or any other business logic around it. / 宿主 app 可以对这个值使用 `.onChange`、持久化、埋点或任何业务逻辑。

## Repository Structure

- `Package.swift`: Swift Package manifest exporting `WheelPickerKit`. / 导出 `WheelPickerKit` 的 Swift Package 清单。
- `Sources/WheelPickerKit/`: Shipped package source. / 实际分发的包源码。
- `Tests/WheelPickerKitTests/`: Public API contract tests. / 公开 API 契约测试。
- `WheelPicker/`: Demo app source and immersive verification shell. / 示例应用源码与沉浸式验证外壳。
- `WheelPicker.xcodeproj/`: Local development and demo project. / 本地开发与示例运行工程。

## Publishing Notes

- Push the repository to GitHub.
- Tag semantic versions such as `1.0.0`.
- Consume those tags from other apps through Swift Package Manager.

将仓库推送到 GitHub 后：
- 打语义化版本标签，例如 `1.0.0`
- 通过 Swift Package Manager 在其他 app 中按版本接入
- 用 tag 管理升级，而不是直接依赖裸分支
