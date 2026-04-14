// [IN]: SwiftUI, platform color interpolation, package haptic service, and full-bleed masked arc geometry / SwiftUI、平台颜色插值、包内触感服务与全宽遮罩圆弧几何
// [OUT]: Package-private arc renderer with stable tick visibility, wider drag hit regions, and aggressively tightened value placement / 提供稳定刻度可见域、更宽拖动命中区与大幅收紧数值位置的包内圆弧渲染器
// [POS]: Keep the guide arc, tick band, and value label locked to one centered full-width geometry with minimal dead air / 让导向弧、刻度带与数值标签锁定在同一条居中的全宽几何上，并尽量消灭空洞留白
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

private let wheelPickerViewportCoordinateSpace = "WheelPickerViewport"

struct WheelPickerConfig {
    var activeTint: Color = .primary
    var inactiveTint: Color = Color.gray.opacity(0.8)
    var arcProfile: TimerWheelPickerStyle.Layout.ArcProfile = .classic
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
        Color(hue: 0.92, saturation: 0.92, brightness: 1.0),
    ])
    var valueGradient: Gradient = Gradient(colors: [
        Color(hue: 0.58, saturation: 0.34, brightness: 0.92),
        Color(hue: 0.88, saturation: 0.82, brightness: 1.0),
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

            let denominator = max(
                currentStop.location - previousStop.location, .leastNonzeroMagnitude)
            let segmentProgress = (clampedProgress - previousStop.location) / denominator
            return mixedColor(
                from: previousStop.color, to: currentStop.color, progress: segmentProgress)
        }

        return stops.last?.color ?? firstStop.color
    }

    private func normalizedStops(from gradient: Gradient) -> [Gradient.Stop] {
        let sortedStops = gradient.stops.sorted { $0.location < $1.location }

        switch sortedStops.count {
        case 0:
            return [
                .init(color: .white, location: 0),
                .init(color: .white, location: 1),
            ]
        case 1:
            let singleColor = sortedStops[0].color
            return [
                .init(color: singleColor, location: 0),
                .init(color: singleColor, location: 1),
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
            red: Double(
                startComponents.red + ((endComponents.red - startComponents.red) * interpolation)),
            green: Double(
                startComponents.green
                    + ((endComponents.green - startComponents.green) * interpolation)),
            blue: Double(
                startComponents.blue + ((endComponents.blue - startComponents.blue) * interpolation)
            ),
            opacity: Double(
                startComponents.alpha
                    + ((endComponents.alpha - startComponents.alpha) * interpolation))
        )
    }
}

private struct WheelArcGeometry {
    let size: CGSize
    let config: WheelPickerConfig
    let chordWidth: CGFloat
    let radius: CGFloat
    let centerY: CGFloat
    let topY: CGFloat
    let labelTopY: CGFloat
    let labelWidth: CGFloat

    init(size: CGSize, config: WheelPickerConfig) {
        self.size = size
        self.config = config

        switch config.arcProfile {
        case .classic:
            let strokeWidth = config.strokeStyle.lineWidth
            let usableWidth = min(
                size.width - strokeWidth, max((size.height - strokeWidth) * 2, strokeWidth * 2))
            let resolvedChordWidth = max(usableWidth, config.tickSlotWidth * 6)
            self.chordWidth = resolvedChordWidth
            self.radius = resolvedChordWidth / 2
            self.centerY = size.height - (strokeWidth / 2)
            self.topY = centerY - radius
            self.labelTopY = topY + (radius * 0.54)
            self.labelWidth = min(radius * 1.06, size.width * 0.72)
        case .fullWidthShallow:
            let resolvedChordWidth = max(
                size.width + max(config.tickWidth, config.strokeStyle.lineWidth) + 4,
                config.tickSlotWidth * 12)
            let sagitta = min(max(size.height * 0.18, 48), 74)
            self.chordWidth = resolvedChordWidth
            self.radius =
                (sagitta / 2) + ((resolvedChordWidth * resolvedChordWidth) / (8 * sagitta))
            self.topY = max(14, config.indicatorDotSize * 0.55)
            self.centerY = topY + radius
            self.labelTopY = topY + sagitta - 56
            self.labelWidth = min(size.width * 0.88, 320)
        }
    }

    var centerX: CGFloat { size.width / 2 }
    var halfChord: CGFloat { chordWidth / 2 }
    var labelHeight: CGFloat { max(size.height - labelTopY - 8, 0) }
    var labelCenterY: CGFloat { labelTopY + (labelHeight / 2) }
    var indicatorPoint: CGPoint { CGPoint(x: centerX, y: topY) }
    private var tickFadeWidth: CGFloat { config.arcProfile == .fullWidthShallow ? 16 : 6 }

    func y(forRelativeX relativeX: CGFloat) -> CGFloat {
        let clampedX = min(max(relativeX, -halfChord), halfChord)
        let offsetY = sqrt(max((radius * radius) - (clampedX * clampedX), 0))
        return centerY - offsetY
    }

    func outwardUnitVector(forRelativeX relativeX: CGFloat) -> CGVector {
        let pointX = min(max(relativeX, -halfChord), halfChord)
        let pointY = y(forRelativeX: pointX)
        let deltaX = pointX
        let deltaY = pointY - centerY
        let length = max(sqrt((deltaX * deltaX) + (deltaY * deltaY)), 0.001)
        return CGVector(dx: deltaX / length, dy: deltaY / length)
    }

    func tickRotation(forRelativeX relativeX: CGFloat) -> Angle {
        let vector = outwardUnitVector(forRelativeX: relativeX)
        return Angle(radians: Double(atan2(vector.dy, vector.dx) - (.pi / 2)))
    }

    func tickLength(isLargeTick: Bool) -> CGFloat {
        let ratio = isLargeTick ? config.largeTickRatio : config.smallTickRatio

        switch config.arcProfile {
        case .classic:
            return config.strokeStyle.lineWidth * ratio
        case .fullWidthShallow:
            let baseLength = min(max(size.height * 0.06, 12), 18)
            return max(baseLength * ratio, isLargeTick ? 10 : 5)
        }
    }

    func tickOffset(isLargeTick: Bool) -> CGFloat {
        switch config.arcProfile {
        case .classic:
            return (tickLength(isLargeTick: isLargeTick) / 2)
                + (config.strokeStyle.lineWidth * 0.04)
        case .fullWidthShallow:
            return (tickLength(isLargeTick: isLargeTick) / 2) + (config.strokeStyle.lineWidth / 2)
                + 12
        }
    }

    func pointOnArc(relativeX: CGFloat, outwardOffset: CGFloat = 0) -> CGPoint {
        let vector = outwardUnitVector(forRelativeX: relativeX)
        return CGPoint(
            x: centerX + relativeX + (vector.dx * outwardOffset),
            y: y(forRelativeX: relativeX) + (vector.dy * outwardOffset)
        )
    }

    func tickOpacity(forRelativeX relativeX: CGFloat) -> CGFloat {
        let distanceFromCenter = abs(relativeX)
        let fadeStart = max(halfChord - tickFadeWidth, 0)

        guard distanceFromCenter < halfChord else { return 0 }
        guard distanceFromCenter > fadeStart else { return 1 }

        let remaining = halfChord - distanceFromCenter
        return max(min(remaining / max(tickFadeWidth, 0.001), 1), 0)
    }

    func makeArcPath() -> Path {
        var path = Path()
        let samples = config.arcProfile == .fullWidthShallow ? 220 : 140

        for index in 0...samples {
            let progress = CGFloat(index) / CGFloat(samples)
            let relativeX = (-halfChord) + (chordWidth * progress)
            let point = CGPoint(x: centerX + relativeX, y: y(forRelativeX: relativeX))

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        return path
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

    private var displayValues: [Int] {
        config.arcProfile == .fullWidthShallow ? values.reversed() : values
    }

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
            let geometry = WheelArcGeometry(size: proxy.size, config: config)
            let currentValue = activePosition ?? resolvedSelection(for: selectedValue)

            ZStack(alignment: .top) {
                backgroundArc(geometry: geometry)
                    .allowsHitTesting(false)
                wheelPickerScrollView(size: proxy.size, geometry: geometry)
                selectionIndicator(geometry: geometry)
                    .allowsHitTesting(false)
                label(currentValue, isScrolling)
                    .frame(
                        maxWidth: geometry.labelWidth, maxHeight: geometry.labelHeight,
                        alignment: .top
                    )
                    .position(x: geometry.centerX, y: geometry.labelCenterY)
                    .allowsHitTesting(false)
            }
            .compositingGroup()
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

    private func backgroundArc(geometry: WheelArcGeometry) -> some View {
        geometry.makeArcPath()
            .stroke(
                config.backgroundColor,
                style: StrokeStyle(
                    lineWidth: config.backgroundLineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .overlay {
                geometry.makeArcPath()
                    .stroke(config.inactiveTint, style: config.strokeStyle)
                    .blur(radius: config.arcProfile == .classic ? 0.5 : 0)
            }
            .shadow(
                color: config.arcProfile == .fullWidthShallow
                    ? Color.black.opacity(0.16) : config.backgroundColor.opacity(0.4),
                radius: config.arcProfile == .fullWidthShallow ? 10 : 24,
                y: config.arcProfile == .fullWidthShallow ? 2 : 16
            )
    }

    private func wheelPickerScrollView(size: CGSize, geometry: WheelArcGeometry) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: config.gapBetweenTicks) {
                ForEach(displayValues, id: \.self) { value in
                    tickView(value, size: size, geometry: geometry)
                        .id(value)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled(true)
        .safeAreaPadding(.horizontal, max((size.width - config.tickSlotWidth) / 2, 0))
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollPosition(id: $activePosition, anchor: .center)
        .coordinateSpace(name: wheelPickerViewportCoordinateSpace)
        .background(Color.white.opacity(0.001))
        .contentShape(Rectangle())
    }

    private func selectionIndicator(geometry: WheelArcGeometry) -> some View {
        Group {
            if config.arcProfile == .fullWidthShallow {
                Circle()
                    .fill(config.activeTint)
                    .frame(width: config.indicatorDotSize, height: config.indicatorDotSize)
                    .shadow(color: Color.black.opacity(0.16), radius: 4, y: 2)
                    .position(geometry.indicatorPoint)
            } else {
                VStack(spacing: -5) {
                    Capsule()
                        .fill(config.activeTint)
                        .frame(width: config.indicatorWidth, height: config.indicatorHeight)

                    Circle()
                        .fill(config.activeTint)
                        .frame(width: config.indicatorDotSize, height: config.indicatorDotSize)
                }
                .shadow(color: config.activeTint.opacity(0.35), radius: 12, y: 6)
                .position(
                    x: geometry.centerX,
                    y: geometry.topY + (config.indicatorHeight / 2) + (config.indicatorDotSize / 2)
                )
            }
        }
    }

    @ViewBuilder
    private func tickView(_ value: Int, size: CGSize, geometry: WheelArcGeometry) -> some View {
        let tickIndex = displayValues.firstIndex(of: value) ?? 0
        let isLargeTick = (tickIndex % max(config.largeTickFrequency, 1)) == 0
        let tickColor = config.tickColor(for: value, within: values)
        let tickLength = geometry.tickLength(isLargeTick: isLargeTick)

        GeometryReader { proxy in
            let frame = proxy.frame(in: .named(wheelPickerViewportCoordinateSpace))
            let relativeX = frame.midX - (size.width / 2)
            let vector = geometry.outwardUnitVector(forRelativeX: relativeX)
            let arcPoint = geometry.pointOnArc(
                relativeX: relativeX, outwardOffset: geometry.tickOffset(isLargeTick: isLargeTick))
            let tickOpacity = geometry.tickOpacity(forRelativeX: relativeX)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            tickColor.opacity(config.arcProfile == .fullWidthShallow ? 0.72 : 0.64),
                            tickColor,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: config.tickWidth, height: tickLength)
                .rotationEffect(geometry.tickRotation(forRelativeX: relativeX))
                .position(
                    x: (proxy.size.width / 2)
                        + (vector.dx * geometry.tickOffset(isLargeTick: isLargeTick)),
                    y: arcPoint.y
                )
                .opacity(tickOpacity)
                .shadow(
                    color: config.arcProfile == .fullWidthShallow
                        ? Color.white.opacity(0.04) : Color.black.opacity(0.34),
                    radius: config.arcProfile == .fullWidthShallow ? 0 : 4,
                    y: config.arcProfile == .fullWidthShallow ? 0 : 2
                )
        }
        .frame(width: config.tickSlotWidth, height: size.height)
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

extension PlatformColor {
    fileprivate var rgbaComponents: RGBAComponents {
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
    @State private var selection = 78

    var body: some View {
        TimerWheelPicker(selection: $selection, range: 5...180, step: 1, style: .immersiveArc)
    }
}
