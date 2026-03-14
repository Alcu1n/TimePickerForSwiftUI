// [IN]: SwiftUI, package-private wheel primitives, and timer-facing public-style configuration / SwiftUI、包内滚轮原语与面向计时器的 public 风格配置
// [OUT]: Public timer wheel picker component exposing selection plus style entry points / 暴露选中值与样式入口的公开计时器滚轮组件
// [POS]: Serve as the clean package API that app code imports for reuse / 作为应用侧导入复用的干净包 API
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import SwiftUI

public struct TimerWheelPickerStyle {
    public struct Colors {
        public var activeTint: Color
        public var inactiveTint: Color
        public var ringBackground: Color
        public var tickGradient: Gradient
        public var valueGradient: Gradient

        public init(
            activeTint: Color = .white,
            inactiveTint: Color = Color.white.opacity(0.12),
            ringBackground: Color = Color(hue: 0.37, saturation: 0.74, brightness: 0.94),
            tickGradient: Gradient = Gradient(colors: [
                Color(hue: 0.62, saturation: 0.42, brightness: 0.88),
                Color(hue: 0.92, saturation: 0.92, brightness: 1.0)
            ]),
            valueGradient: Gradient = Gradient(colors: [
                Color(hue: 0.58, saturation: 0.34, brightness: 0.92),
                Color(hue: 0.88, saturation: 0.82, brightness: 1.0)
            ])
        ) {
            self.activeTint = activeTint
            self.inactiveTint = inactiveTint
            self.ringBackground = ringBackground
            self.tickGradient = tickGradient
            self.valueGradient = valueGradient
        }
    }

    public struct Layout {
        public var dialHeight: CGFloat
        public var dialScale: CGFloat
        public var ringThickness: CGFloat
        public var ringBackgroundExtraWidth: CGFloat
        public var indicatorHeight: CGFloat
        public var indicatorWidth: CGFloat
        public var indicatorDotSize: CGFloat
        public var tickWidth: CGFloat
        public var tickSlotWidth: CGFloat
        public var gapBetweenTicks: CGFloat
        public var largeTickFrequency: Int
        public var largeTickRatio: CGFloat
        public var smallTickRatio: CGFloat

        public init(
            dialHeight: CGFloat = 214,
            dialScale: CGFloat = 0.86,
            ringThickness: CGFloat = 44,
            ringBackgroundExtraWidth: CGFloat = 10,
            indicatorHeight: CGFloat = 28,
            indicatorWidth: CGFloat = 5,
            indicatorDotSize: CGFloat = 10,
            tickWidth: CGFloat = 3.3,
            tickSlotWidth: CGFloat = 5.2,
            gapBetweenTicks: CGFloat = -2.6,
            largeTickFrequency: Int = 5,
            largeTickRatio: CGFloat = 0.68,
            smallTickRatio: CGFloat = 0.32
        ) {
            self.dialHeight = dialHeight
            self.dialScale = dialScale
            self.ringThickness = ringThickness
            self.ringBackgroundExtraWidth = ringBackgroundExtraWidth
            self.indicatorHeight = indicatorHeight
            self.indicatorWidth = indicatorWidth
            self.indicatorDotSize = indicatorDotSize
            self.tickWidth = tickWidth
            self.tickSlotWidth = tickSlotWidth
            self.gapBetweenTicks = gapBetweenTicks
            self.largeTickFrequency = largeTickFrequency
            self.largeTickRatio = largeTickRatio
            self.smallTickRatio = smallTickRatio
        }
    }

    public struct Typography {
        public var valueFontSize: CGFloat
        public var unitFontSize: CGFloat
        public var unitLabel: String

        public init(
            valueFontSize: CGFloat = 58,
            unitFontSize: CGFloat = 14,
            unitLabel: String = "MIN"
        ) {
            self.valueFontSize = valueFontSize
            self.unitFontSize = unitFontSize
            self.unitLabel = unitLabel
        }
    }

    public var colors: Colors
    public var layout: Layout
    public var typography: Typography

    public init(
        colors: Colors = .init(),
        layout: Layout = .init(),
        typography: Typography = .init()
    ) {
        self.colors = colors
        self.layout = layout
        self.typography = typography
    }

    public static var premiumDemo: Self {
        Self()
    }

    func makeWheelConfig() -> WheelPickerConfig {
        WheelPickerConfig(
            activeTint: colors.activeTint,
            inactiveTint: colors.inactiveTint,
            largeTickFrequency: layout.largeTickFrequency,
            strokeStyle: .init(lineWidth: layout.ringThickness, lineCap: .round, lineJoin: .round),
            backgroundLineWidth: layout.ringThickness + layout.ringBackgroundExtraWidth,
            backgroundColor: colors.ringBackground,
            tickGradient: colors.tickGradient,
            valueGradient: colors.valueGradient,
            largeTickRatio: layout.largeTickRatio,
            smallTickRatio: layout.smallTickRatio,
            tickWidth: layout.tickWidth,
            tickSlotWidth: layout.tickSlotWidth,
            gapBetweenTicks: layout.gapBetweenTicks,
            height: layout.dialHeight,
            indicatorHeight: layout.indicatorHeight,
            indicatorWidth: layout.indicatorWidth,
            indicatorDotSize: layout.indicatorDotSize
        )
    }
}

public struct TimerWheelPicker: View {
    public let range: ClosedRange<Int>
    public let step: Int
    public let style: TimerWheelPickerStyle
    @Binding private var selection: Int

    private var values: [Int] {
        let safeStep = max(step, 1)
        return Array(stride(from: range.lowerBound, through: range.upperBound, by: safeStep))
    }

    public init(
        selection: Binding<Int>,
        range: ClosedRange<Int> = 5...180,
        step: Int = 1,
        style: TimerWheelPickerStyle = .premiumDemo
    ) {
        self.range = range
        self.step = step
        self.style = style
        self._selection = selection
    }

    public var body: some View {
        let wheelConfig = style.makeWheelConfig()

        WheelPickerView(values: values, selectedValue: $selection, config: wheelConfig) { currentValue, isScrolling in
            TimerWheelPickerLabel(
                minutes: currentValue,
                accent: wheelConfig.valueColor(for: currentValue, within: values),
                style: style,
                isScrolling: isScrolling
            )
        }
        .scaleEffect(style.layout.dialScale, anchor: .center)
        .frame(height: style.layout.dialHeight * style.layout.dialScale)
    }
}

private struct TimerWheelPickerLabel: View {
    let minutes: Int
    let accent: Color
    let style: TimerWheelPickerStyle
    let isScrolling: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(String(minutes))
                .font(.system(size: style.typography.valueFontSize, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(accent)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.22), value: minutes)
                .scaleEffect(isScrolling ? 0.985 : 1)
                .animation(.easeOut(duration: 0.12), value: isScrolling)
                .shadow(color: accent.opacity(0.32), radius: 18, y: 10)

            Text(style.typography.unitLabel)
                .font(.system(size: style.typography.unitFontSize, weight: .bold, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(Color.white.opacity(0.7))
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 26)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Timer")
        .accessibilityValue("\(minutes) minutes")
    }
}
