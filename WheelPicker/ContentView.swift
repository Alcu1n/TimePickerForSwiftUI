// [IN]: SwiftUI, timer picker styling, and size controls / SwiftUI、计时器选择器样式与尺寸控制
// [OUT]: Premium timer picker demo screen with tuning panel / 带调节面板的高级质感计时器选择器示例界面
// [POS]: Compose timer semantics, scaling, and presentation / 组合时间语义、缩放控制与高级视觉呈现
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import SwiftUI

struct ContentView: View {
    @State private var selectedDuration: Int = 30
    @State private var dialHeight: CGFloat = 214
    @State private var ringThickness: CGFloat = 44
    @State private var indicatorHeight: CGFloat = 28
    @State private var dialScale: CGFloat = 0.86

    private let timerValues = Array(5...180)

    private var timerConfig: WheelPickerConfig {
        WheelPickerConfig(
            activeTint: Color.white,
            inactiveTint: Color.white.opacity(0.18),
            largeTickFrequency: 5,
            strokeStyle: .init(lineWidth: ringThickness, lineCap: .round, lineJoin: .round),
            backgroundLineWidth: ringThickness + 10,
            backgroundColor: Color(hue: 0.37, saturation: 0.74, brightness: 0.94),
            tickHueRange: 0.62...0.92,
            tickSaturationRange: 0.42...0.92,
            tickBrightnessRange: 0.88...1.0,
            valueHueRange: 0.58...0.88,
            valueSaturationRange: 0.34...0.82,
            valueBrightnessRange: 0.92...1.0,
            largeTickRatio: 0.68,
            smallTickRatio: 0.32,
            tickWidth: 3.3,
            tickSlotWidth: 5.2,
            gapBetweenTicks: -2.6,
            height: dialHeight,
            indicatorHeight: indicatorHeight,
            indicatorWidth: 5,
            indicatorDotSize: 10
        )
    }

    var body: some View {
        ZStack {
            Color.black
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(hue: 0.36, saturation: 0.78, brightness: 0.78).opacity(0.28),
                    .clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 320
            )
            .blur(radius: 30)
            .ignoresSafeArea()

            VStack(spacing: 28) {
                headerView

                WheelPickerView(values: timerValues, selectedValue: $selectedDuration, config: timerConfig) { currentValue, isScrolling in
                    TimerValueLabel(
                        minutes: currentValue,
                        accent: timerConfig.valueColor(for: currentValue, within: timerValues),
                        isScrolling: isScrolling
                    )
                }
                .scaleEffect(dialScale, anchor: .center)
                .frame(height: dialHeight * dialScale)

                controlPanel

                detailCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Focus Timer")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .tracking(2.4)
                .foregroundStyle(Color.white.opacity(0.62))

            Text("Set a calm, precise countdown")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)

            Text("Scroll the dial to move from a quick reset to a deep session.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.68))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var detailCard: some View {
        HStack(spacing: 14) {
            infoChip(title: "Range", value: "05-180 min")
            infoChip(title: "Step", value: "1 min")
            infoChip(title: "Preset", value: "30 min")
        }
        .padding(10)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        }
        .shadow(color: timerConfig.activeTint.opacity(0.12), radius: 24, y: 12)
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dial Controls")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.88))

            controlRow(title: "Size", value: "\(Int(dialHeight))") {
                Slider(value: $dialHeight, in: 180...240, step: 1)
                    .tint(timerConfig.backgroundColor)
            }

            controlRow(title: "Scale", value: String(format: "%.2fx", dialScale)) {
                Slider(value: $dialScale, in: 0.72...1.0, step: 0.01)
                    .tint(timerConfig.backgroundColor)
            }

            controlRow(title: "Ring", value: "\(Int(ringThickness))") {
                Slider(value: $ringThickness, in: 34...52, step: 1)
                    .tint(timerConfig.backgroundColor)
            }

            controlRow(title: "Marker", value: "\(Int(indicatorHeight))") {
                Slider(value: $indicatorHeight, in: 18...38, step: 1)
                    .tint(timerConfig.backgroundColor)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        }
    }

    private func infoChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.5))

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct TimerValueLabel: View {
    let minutes: Int
    let accent: Color
    let isScrolling: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(String(minutes))
                .font(.system(size: 58, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(accent)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.22), value: minutes)
                .scaleEffect(isScrolling ? 0.985 : 1)
                .animation(.easeOut(duration: 0.12), value: isScrolling)
                .shadow(color: accent.opacity(0.32), radius: 18, y: 10)

            Text("MIN")
                .font(.system(size: 14, weight: .bold, design: .rounded))
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

private extension ContentView {
    func controlRow<Control: View>(title: String, value: String, @ViewBuilder control: () -> Control) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.58))

                Spacer()

                Text(value)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .monospacedDigit()
            }

            control()
        }
    }
}

#Preview {
    ContentView()
}
