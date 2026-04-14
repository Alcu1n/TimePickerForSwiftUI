// [IN]: SwiftUI, WheelPickerKit package product, and demo-owned full-bleed immersive style state / SwiftUI、WheelPickerKit 包产品与示例侧全宽沉浸式样式状态
// [OUT]: Full-screen demo screen focused on a full-bleed immersive arc picker presentation with explicit initial-value wiring that matches the package default contract / 聚焦全宽沉浸式圆弧选择器展示且显式接入初始值参数并与包默认契约一致的全屏示例界面
// [POS]: Prove the app shell owns background composition while the package owns the picker, its edge-to-edge arc, and its first-load default contract / 证明应用外壳负责背景构图，而包本体只负责选择器、贴边圆弧与首次加载默认值契约
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import SwiftUI
import WheelPickerKit

struct ContentView: View {
    @State private var selectedDuration = 30
    private let pickerStyle = TimerWheelPickerStyle.immersiveArc

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                TimerWheelPicker(
                    selection: $selectedDuration,
                    range: 5...180,
                    step: 1,
                    initialSelection: 30,
                    style: pickerStyle
                )
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)
            }
            .padding(.vertical, 24)
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.77, green: 0.63, blue: 0.56),
                    Color(red: 0.58, green: 0.40, blue: 0.33),
                    Color(red: 0.33, green: 0.20, blue: 0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.38),
                    Color(red: 0.90, green: 0.71, blue: 0.60).opacity(0.22),
                    .clear
                ],
                center: .top,
                startRadius: 18,
                endRadius: 340
            )
            .blur(radius: 16)

            Circle()
                .fill(Color(red: 0.23, green: 0.10, blue: 0.08).opacity(0.42))
                .frame(width: 320, height: 320)
                .blur(radius: 64)
                .offset(x: 80, y: 40)

            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 240, height: 240)
                .blur(radius: 88)
                .offset(x: -120, y: -180)

            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.08))
                .blur(radius: 40)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
