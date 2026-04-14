// [IN]: SwiftUI, package-private full-bleed arc renderer, and timer-facing public style presets / SwiftUI、包内全宽圆弧渲染器与面向计时器的公开样式预设
// [OUT]: Public timer wheel picker API exposing selection, initial selection fallback, readable style aliases, viewport tick-fade controls, and immersive-by-default preset contract / 暴露选中值、初始默认值回退、易读样式别名、刻度视口褪色控制与默认沉浸式预设契约的公开计时器选择器 API
// [POS]: Keep the shipped package surface small while letting consumers customize the arc, tick fade, value position, caption, and initial selection while defaulting new integrations to the immersive arc and its mirrored swipe semantics / 保持包 API 精简，同时让接入方安全自定义圆弧、刻度褪色、数字位置、底部文案与初始默认值，并让新接入默认落到沉浸式圆弧及其镜像滑动语义
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import SwiftUI

public struct TimerWheelPickerStyle {
    public struct Colors {
        public var activeTint: Color
        public var inactiveTint: Color
        public var ringBackground: Color
        public var tickGradient: Gradient
        public var tickColor: Color?
        public var tickCenterOpacity: Double
        public var tickEdgeOpacity: Double
        public var valueGradient: Gradient

        public var guideArcTint: Color {
            get { inactiveTint }
            set { inactiveTint = newValue }
        }

        public init(
            activeTint: Color = .white,
            inactiveTint: Color = Color.white.opacity(0.12),
            ringBackground: Color = Color(hue: 0.37, saturation: 0.74, brightness: 0.94),
            tickGradient: Gradient = Gradient(colors: [
                Color(hue: 0.62, saturation: 0.42, brightness: 0.88),
                Color(hue: 0.92, saturation: 0.92, brightness: 1.0)
            ]),
            tickColor: Color? = nil,
            tickCenterOpacity: Double = 1,
            tickEdgeOpacity: Double = 1,
            valueGradient: Gradient = Gradient(colors: [
                Color(hue: 0.58, saturation: 0.34, brightness: 0.92),
                Color(hue: 0.88, saturation: 0.82, brightness: 1.0)
            ])
        ) {
            self.activeTint = activeTint
            self.inactiveTint = inactiveTint
            self.ringBackground = ringBackground
            self.tickGradient = tickGradient
            self.tickColor = tickColor
            self.tickCenterOpacity = tickCenterOpacity
            self.tickEdgeOpacity = tickEdgeOpacity
            self.valueGradient = valueGradient
        }

        var resolvedTickGradient: Gradient {
            guard let tickColor else { return tickGradient }
            return Gradient(colors: [tickColor, tickColor])
        }
    }

    public struct Layout {
        public enum ArcProfile: Sendable {
            case classic
            case fullWidthShallow
        }

        public var arcProfile: ArcProfile
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
        public var valueLabelOffsetY: CGFloat

        public init(
            arcProfile: ArcProfile = .classic,
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
            smallTickRatio: CGFloat = 0.32,
            valueLabelOffsetY: CGFloat = 0
        ) {
            self.arcProfile = arcProfile
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
            self.valueLabelOffsetY = valueLabelOffsetY
        }
    }

    public struct Typography {
        public var valueFontSize: CGFloat
        public var unitFontSize: CGFloat
        public var unitLabel: String

        public var captionText: String {
            get { unitLabel }
            set { unitLabel = newValue }
        }

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

    public static var immersiveArc: Self {
        Self(
            colors: .init(
                activeTint: .white,
                inactiveTint: Color.white.opacity(0.2),
                ringBackground: Color.white.opacity(0.24),
                tickGradient: Gradient(colors: [
                    Color.white.opacity(0.88),
                    Color.white
                ]),
                tickColor: .white,
                tickCenterOpacity: 1,
                tickEdgeOpacity: 0.2,
                valueGradient: Gradient(colors: [
                    Color.white.opacity(0.92),
                    Color.white
                ])
            ),
            layout: .init(
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
                smallTickRatio: 0.52,
                valueLabelOffsetY: -34
            ),
            typography: .init(
                valueFontSize: 108,
                unitFontSize: 28,
                unitLabel: "Relaxed"
            )
        )
    }

    func makeWheelConfig() -> WheelPickerConfig {
        WheelPickerConfig(
            activeTint: colors.activeTint,
            inactiveTint: colors.inactiveTint,
            arcProfile: layout.arcProfile,
            largeTickFrequency: layout.largeTickFrequency,
            strokeStyle: .init(lineWidth: layout.ringThickness, lineCap: .round, lineJoin: .round),
            backgroundLineWidth: layout.ringThickness + layout.ringBackgroundExtraWidth,
            backgroundColor: colors.ringBackground,
            tickGradient: colors.resolvedTickGradient,
            tickCenterOpacity: colors.tickCenterOpacity,
            tickEdgeOpacity: colors.tickEdgeOpacity,
            valueGradient: colors.valueGradient,
            largeTickRatio: layout.largeTickRatio,
            smallTickRatio: layout.smallTickRatio,
            tickWidth: layout.tickWidth,
            tickSlotWidth: layout.tickSlotWidth,
            gapBetweenTicks: layout.gapBetweenTicks,
            valueLabelOffsetY: layout.valueLabelOffsetY,
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
    public let initialSelection: Int
    public let style: TimerWheelPickerStyle
    @Binding private var selection: Int

    private var values: [Int] {
        let safeStep = max(step, 1)
        return Array(stride(from: range.lowerBound, through: range.upperBound, by: safeStep))
    }

    private var resolvedInitialSelection: Int {
        values.min(by: { abs($0 - initialSelection) < abs($1 - initialSelection) }) ?? initialSelection
    }

    public init(
        selection: Binding<Int>,
        range: ClosedRange<Int> = 5...180,
        step: Int = 1,
        initialSelection: Int = 30,
        style: TimerWheelPickerStyle = .immersiveArc
    ) {
        self.range = range
        self.step = step
        self.initialSelection = initialSelection
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
        .task {
            guard !values.contains(selection) else { return }
            selection = resolvedInitialSelection
        }
    }
}

private struct TimerWheelPickerLabel: View {
    let minutes: Int
    let accent: Color
    let style: TimerWheelPickerStyle
    let isScrolling: Bool

    private var isImmersiveArc: Bool {
        style.layout.arcProfile == .fullWidthShallow
    }

    var body: some View {
        VStack(spacing: isImmersiveArc ? 6 : 8) {
            Text(String(minutes))
                .font(.system(size: style.typography.valueFontSize, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(accent)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.22), value: minutes)
                .scaleEffect(isScrolling ? 0.985 : 1)
                .animation(.easeOut(duration: 0.12), value: isScrolling)
                .shadow(color: accent.opacity(isImmersiveArc ? 0.1 : 0.32), radius: isImmersiveArc ? 8 : 18, y: isImmersiveArc ? 2 : 10)

            Text(style.typography.unitLabel)
                .font(.system(size: style.typography.unitFontSize, weight: isImmersiveArc ? .medium : .bold, design: .rounded))
                .tracking(isImmersiveArc ? 0 : 1.6)
                .foregroundStyle(Color.white.opacity(isImmersiveArc ? 0.88 : 0.7))
        }
        .frame(maxHeight: .infinity)
        .padding(.top, isImmersiveArc ? 0 : 26)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Selected value")
        .accessibilityValue(style.typography.unitLabel.isEmpty ? "\(minutes)" : "\(minutes) \(style.typography.unitLabel)")
    }
}
