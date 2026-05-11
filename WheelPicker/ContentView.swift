// [IN]: SwiftUI, WheelPickerKit package product, and demo-owned black screen shell / SwiftUI、WheelPickerKit 包产品与示例侧黑色屏幕外壳
// [OUT]: Full-screen demo screen focused on the package default immersive arc picker with explicit initial-value wiring / 聚焦包默认沉浸式圆弧选择器展示与显式初始值接线的全屏示例界面
// [POS]: Prove the app shell owns only demo composition while the package owns picker behavior, default styling, arc rendering, and first-load default repair / 证明应用外壳只负责示例构图，而包本体负责选择器行为、默认样式、圆弧渲染与首次加载默认值修正
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import SwiftUI
import WheelPickerKit

struct ContentView: View {
    @State private var selectedDuration = 30

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                TimerWheelPicker(
                    selection: $selectedDuration,
                    range: 5...180,
                    step: 1,
                    initialSelection: 30
                )
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)
            }
            .padding(.vertical, 24)
        }
    }

    private var backgroundLayer: some View {
        Color.black
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
