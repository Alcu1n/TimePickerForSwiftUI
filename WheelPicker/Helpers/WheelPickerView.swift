// [IN]: SwiftUI, dedicated wheel haptics controller, discrete picker values, and premium wheel config / SwiftUI、专用滚轮震动控制器、离散选择值与高级滚轮配置
// [OUT]: Reusable wheel picker with gradient ticks and haptics / 带渐变刻度与震动反馈的可复用滚轮选择器
// [POS]: Render arc-backed wheel interaction with per-tick feedback / 渲染带弧形背景与逐刻度反馈的滚轮交互
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import SwiftUI

struct WheelPickerConfig {
    var activeTint: Color = .primary
    var inactiveTint: Color = Color.gray.opacity(0.8)
    var largeTickFrequency: Int = 10
    var strokeStyle: StrokeStyle = .init(
        lineWidth: 50,
        lineCap: .round,
        lineJoin: .round
    )
    var backgroundLineWidth: CGFloat = 62
    var backgroundColor: Color = Color(hue: 0.37, saturation: 0.72, brightness: 0.92)
    var tickHueRange: ClosedRange<Double> = 0.34...0.48
    var tickSaturationRange: ClosedRange<Double> = 0.5...0.9
    var tickBrightnessRange: ClosedRange<Double> = 0.66...0.98
    var valueHueRange: ClosedRange<Double> = 0.35...0.48
    var valueSaturationRange: ClosedRange<Double> = 0.4...0.82
    var valueBrightnessRange: ClosedRange<Double> = 0.72...0.98
    var largeTickRatio: CGFloat = 0.65
    var smallTickRatio: CGFloat = 0.4
    var tickWidth: CGFloat = 3
    var tickSlotWidth: CGFloat = 8
    var gapBetweenTicks: CGFloat = -2
    var height: CGFloat = 200
    var indicatorHeight: CGFloat = 32
    var indicatorWidth: CGFloat = 6
    var indicatorDotSize: CGFloat = 12

    func valueColor(for value: Int, within values: [Int]) -> Color {
        color(
            progress: progress(for: value, within: values),
            hueRange: valueHueRange,
            saturationRange: valueSaturationRange,
            brightnessRange: valueBrightnessRange
        )
    }

    func tickColor(for value: Int, within values: [Int]) -> Color {
        color(
            progress: progress(for: value, within: values),
            hueRange: tickHueRange,
            saturationRange: tickSaturationRange,
            brightnessRange: tickBrightnessRange
        )
    }

    private func progress(for value: Int, within values: [Int]) -> Double {
        guard
            let first = values.first,
            let last = values.last,
            first != last
        else {
            return 0
        }

        let clamped = min(max(value, first), last)
        return Double(clamped - first) / Double(last - first)
    }

    private func color(
        progress: Double,
        hueRange: ClosedRange<Double>,
        saturationRange: ClosedRange<Double>,
        brightnessRange: ClosedRange<Double>
    ) -> Color {
        Color(
            hue: interpolate(in: hueRange, progress: progress),
            saturation: interpolate(in: saturationRange, progress: progress),
            brightness: interpolate(in: brightnessRange, progress: progress)
        )
    }

    private func interpolate(in range: ClosedRange<Double>, progress: Double) -> Double {
        range.lowerBound + ((range.upperBound - range.lowerBound) * progress)
    }
}

struct WheelPickerView<Label: View>: View {
    let values: [Int]
    @Binding private var selectedValue: Int
    let config: WheelPickerConfig
    @ViewBuilder let label: (Int, Bool) -> Label

    @State private var activePosition: Int?
    @State private var isScrolling = false
    @StateObject private var haptics = WheelHapticController()

    init(
        values: [Int],
        selectedValue: Binding<Int>,
        config: WheelPickerConfig = .init(),
        @ViewBuilder label: @escaping (Int, Bool) -> Label
    ) {
        self.values = values
        self._selectedValue = selectedValue
        self.config = config
        self.label = label
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let width = size.width - config.strokeStyle.lineWidth
            let diameter = min(max(width, size.height), width)
            let radius = diameter / 2

            ZStack {
                backgroundArc(size: size, radius: radius)
                wheelPickerScrollView(size: size, radius: radius)
            }
            .compositingGroup()
            .offset(y: -config.strokeStyle.lineWidth / 2)
        }
        .frame(height: config.height)
        .task {
            guard activePosition == nil else { return }
            activePosition = resolvedSelection(for: selectedValue)
            haptics.prepare()
        }
        .onChange(of: activePosition) { oldValue, newValue in
            guard let newValue, selectedValue != newValue else { return }
            selectedValue = newValue
            if oldValue != nil, isScrolling {
                haptics.playSelectionTick()
            }
        }
        .onChange(of: selectedValue) { _, newValue in
            let resolvedValue = resolvedSelection(for: newValue)
            guard activePosition != resolvedValue else { return }
            activePosition = resolvedValue
        }
        .onScrollPhaseChange { _, newPhase in
            if newPhase == .idle {
                withAnimation(.easeOut(duration: 0.12)) {
                    isScrolling = false
                }
                haptics.endInteraction()
            } else if !isScrolling {
                withAnimation(.easeOut(duration: 0.08)) {
                    isScrolling = true
                }
                haptics.beginInteraction()
            }

            guard newPhase == .idle else { return }

            Task {
                activePosition = nil
                try? await Task.sleep(for: .seconds(0))
                withAnimation(.snappy(duration: 0.18)) {
                    activePosition = resolvedSelection(for: selectedValue)
                }
                await MainActor.run {
                    isScrolling = false
                }
            }
        }
    }

    private func backgroundArc(size: CGSize, radius: CGFloat) -> some View {
        WheelPath(size, radius: radius)
            .stroke(
                config.backgroundColor,
                style: StrokeStyle(
                    lineWidth: config.backgroundLineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .shadow(color: config.backgroundColor.opacity(0.4), radius: 24, y: 16)
            .overlay {
                WheelPath(size, radius: radius)
                    .stroke(Color.white.opacity(0.12), style: config.strokeStyle)
                    .blur(radius: 0.5)
            }
    }

    @ViewBuilder
    private func wheelPickerScrollView(size: CGSize, radius: CGFloat) -> some View {
        let wheelShape = WheelPath(size, radius: radius)
            .strokedPath(config.strokeStyle)

        ScrollView(.horizontal) {
            LazyHStack(spacing: config.gapBetweenTicks) {
                ForEach(values, id: \.self) { value in
                    TickView(value, size: size, radius: radius)
                        .id(value)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled(true)
        .safeAreaPadding(.horizontal, max((size.width - config.tickSlotWidth) / 2, 0))
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollPosition(id: $activePosition, anchor: .center)
        .clipShape(wheelShape)
        .contentShape(wheelShape)
        .overlay(alignment: .bottom) {
            let halfStrokeWidth = config.strokeStyle.lineWidth / 2

            VStack(spacing: -5) {
                Capsule()
                    .fill(config.activeTint)
                    .frame(width: config.indicatorWidth, height: config.indicatorHeight)

                Circle()
                    .fill(config.activeTint)
                    .frame(width: config.indicatorDotSize, height: config.indicatorDotSize)
            }
            .shadow(color: config.activeTint.opacity(0.35), radius: 12, y: 6)
            .offset(y: -radius + halfStrokeWidth + 2)
        }
        .overlay(alignment: .bottom) {
            if radius > 0 {
                label(activePosition ?? resolvedSelection(for: selectedValue), isScrolling)
                    .frame(
                        maxWidth: radius,
                        maxHeight: radius - (config.strokeStyle.lineWidth / 2)
                    )
            }
        }
    }

    @ViewBuilder
    private func TickView(_ value: Int, size: CGSize, radius: CGFloat) -> some View {
        let strokeWidth = config.strokeStyle.lineWidth
        let halfStrokeWidth = strokeWidth / 2
        let isLargeTick = ((values.firstIndex(of: value) ?? 0) % config.largeTickFrequency) == 0
        let tickColor = config.tickColor(for: value, within: values)

        GeometryReader { proxy in
            let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
            let midX = proxy.frame(in: .scrollView(axis: .horizontal)).midX
            let halfWidth = size.width / 2
            let progress = max(min(midX / halfWidth, 1), -1)
            let rotation = Angle(degrees: progress * 180)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            tickColor.opacity(0.64),
                            tickColor
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .offset(y: -radius + halfStrokeWidth)
                .rotationEffect(rotation, anchor: .bottom)
                .offset(x: -minX)
                .shadow(color: Color.black.opacity(0.34), radius: 4, y: 2)
        }
        .frame(width: config.tickWidth, height: strokeWidth * (isLargeTick ? config.largeTickRatio : config.smallTickRatio))
        .frame(width: config.tickSlotWidth, alignment: .leading)
    }

    private func WheelPath(_ size: CGSize, radius: CGFloat) -> Path {
        Path { path in
            path.addArc(
                center: .init(x: size.width / 2, y: size.height),
                radius: radius,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: false
            )
        }
    }

    private func resolvedSelection(for value: Int) -> Int {
        guard let firstValue = values.first else { return value }
        return values.min(by: { abs($0 - value) < abs($1 - value) }) ?? firstValue
    }
}

#Preview {
    ContentView()
}
