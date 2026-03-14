// [IN]: SwiftUI, WheelPickerKit package product, and demo-side tuning state / SwiftUI、WheelPickerKit 包产品与示例侧调节状态
// [OUT]: Premium demo screen showcasing the packaged timer wheel picker / 展示已打包计时器滚轮组件的高级示例界面
// [POS]: Prove the app consumes the distributable picker package instead of embedding picker implementation / 证明应用通过可分发包而非内嵌实现消费选择器
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import SwiftUI
import WheelPickerKit

struct ContentView: View {
    @State private var selectedDuration: Int = 30
    @State private var pickerStyle = TimerWheelPickerStyle.premiumDemo

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

                TimerWheelPicker(
                    selection: $selectedDuration,
                    range: 5...180,
                    step: 1,
                    style: pickerStyle
                )

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
            infoChip(title: "Binding", value: "\(selectedDuration) min")
        }
        .padding(10)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        }
        .shadow(color: pickerStyle.colors.activeTint.opacity(0.12), radius: 24, y: 12)
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dial Controls")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.88))

            controlRow(title: "Size", value: "\(Int(pickerStyle.layout.dialHeight))") {
                Slider(value: $pickerStyle.layout.dialHeight, in: 180...240, step: 1)
                    .tint(pickerStyle.colors.ringBackground)
            }

            controlRow(title: "Scale", value: String(format: "%.2fx", pickerStyle.layout.dialScale)) {
                Slider(value: $pickerStyle.layout.dialScale, in: 0.72...1.0, step: 0.01)
                    .tint(pickerStyle.colors.ringBackground)
            }

            controlRow(title: "Ring", value: "\(Int(pickerStyle.layout.ringThickness))") {
                Slider(value: $pickerStyle.layout.ringThickness, in: 34...52, step: 1)
                    .tint(pickerStyle.colors.ringBackground)
            }

            controlRow(title: "Marker", value: "\(Int(pickerStyle.layout.indicatorHeight))") {
                Slider(value: $pickerStyle.layout.indicatorHeight, in: 18...38, step: 1)
                    .tint(pickerStyle.colors.ringBackground)
            }

            controlRow(title: "Value", value: "Custom") {
                LinearGradient(gradient: pickerStyle.colors.valueGradient, startPoint: .leading, endPoint: .trailing)
                    .frame(height: 10)
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    }
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
