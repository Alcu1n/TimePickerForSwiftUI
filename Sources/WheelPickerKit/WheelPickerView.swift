// [IN]: SwiftUI, platform color interpolation, package haptic service, and discrete wheel config / SwiftUI、平台颜色插值、包内触感服务与离散滚轮配置
// [OUT]: Package-private wheel renderer with configurable gradients and stable feedback / 带可配置渐变与稳定反馈的包内滚轮渲染器
// [POS]: Render the shipped picker's arc interaction while hiding implementation behind the public API / 为对外组件渲染圆弧交互，并将实现细节隐藏在公开 API 背后
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import SwiftUI
#if canImport(UIKit)
import UIKit
private typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
private typealias PlatformColor = NSColor
#endif

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
    var tickGradient: Gradient = Gradient(colors: [
        Color(hue: 0.62, saturation: 0.42, brightness: 0.88),
        Color(hue: 0.92, saturation: 0.92, brightness: 1.0)
    ])
    var valueGradient: Gradient = Gradient(colors: [
        Color(hue: 0.58, saturation: 0.34, brightness: 0.92),
        Color(hue: 0.88, saturation: 0.82, brightness: 1.0)
    ])
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
        color(progress: progress(for: value, within: values), gradient: valueGradient)
    }

    func tickColor(for value: Int, within values: [Int]) -> Color {
        color(progress: progress(for: value, within: values), gradient: tickGradient)
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

    private func color(progress: Double, gradient: Gradient) -> Color {
        let clampedProgress = min(max(progress, 0), 1)
        let stops = normalizedStops(from: gradient)

        guard let firstStop = stops.first else { return .white }
        guard clampedProgress > firstStop.location else { return firstStop.color }

        for index in 1..<stops.count {
            let previousStop = stops[index - 1]
            let currentStop = stops[index]

            guard clampedProgress <= currentStop.location else { continue }

            let denominator = max(currentStop.location - previousStop.location, .leastNonzeroMagnitude)
            let segmentProgress = (clampedProgress - previousStop.location) / denominator
            return mixedColor(from: previousStop.color, to: currentStop.color, progress: segmentProgress)
        }

        return stops.last?.color ?? firstStop.color
    }

    private func normalizedStops(from gradient: Gradient) -> [Gradient.Stop] {
        let sortedStops = gradient.stops.sorted { $0.location < $1.location }

        switch sortedStops.count {
        case 0:
            return [
                .init(color: .white, location: 0),
                .init(color: .white, location: 1)
            ]
        case 1:
            let singleColor = sortedStops[0].color
            return [
                .init(color: singleColor, location: 0),
                .init(color: singleColor, location: 1)
            ]
        default:
            return sortedStops
        }
    }

    private func mixedColor(from start: Color, to end: Color, progress: Double) -> Color {
        let startComponents = PlatformColor(start).rgbaComponents
        let endComponents = PlatformColor(end).rgbaComponents
        let interpolation = CGFloat(progress)

        return Color(
            .sRGB,
            red: Double(startComponents.red + ((endComponents.red - startComponents.red) * interpolation)),
            green: Double(startComponents.green + ((endComponents.green - startComponents.green) * interpolation)),
            blue: Double(startComponents.blue + ((endComponents.blue - startComponents.blue) * interpolation)),
            opacity: Double(startComponents.alpha + ((endComponents.alpha - startComponents.alpha) * interpolation))
        )
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
                    .stroke(config.inactiveTint, style: config.strokeStyle)
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

private struct RGBAComponents {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
}

private extension PlatformColor {
    var rgbaComponents: RGBAComponents {
#if canImport(UIKit)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return RGBAComponents(red: red, green: green, blue: blue, alpha: alpha)
        }

        let resolved = resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
        resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return RGBAComponents(red: red, green: green, blue: blue, alpha: alpha)
#elseif canImport(AppKit)
        let resolved = usingColorSpace(.deviceRGB) ?? self
        return RGBAComponents(
            red: resolved.redComponent,
            green: resolved.greenComponent,
            blue: resolved.blueComponent,
            alpha: resolved.alphaComponent
        )
#endif
    }
}

#Preview {
    WheelPickerPreviewHarness()
        .padding()
        .background(Color.black)
}

private struct WheelPickerPreviewHarness: View {
    @State private var selection = 30

    var body: some View {
        TimerWheelPicker(selection: $selection, range: 5...180, step: 1)
    }
}
