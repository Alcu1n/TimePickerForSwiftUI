// [IN]: SwiftUI app lifecycle and root content view / SwiftUI 应用生命周期与根内容视图
// [OUT]: WheelPicker app entry point / WheelPicker 应用入口
// [POS]: Boot the timer picker demo scene / 启动计时器选择器示例场景
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import SwiftUI

@main
struct WheelPickerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
