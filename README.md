# WheelPicker

Premium SwiftUI demo for an arc-based timer wheel picker.  
高质感 SwiftUI 示例，用于展示基于圆弧刻度盘的计时器滚轮选择器。

## Structure
- `WheelPicker/`: App source, assets, and entitlements. / 应用源码、资源与权限配置。
- `WheelPicker/Helpers/`: Reusable wheel picker rendering and styling primitives. / 可复用的滚轮渲染与样式原语。
- `WheelPicker.xcodeproj/`: Xcode project definition. / Xcode 工程定义。

## Sync Protocol
- `ContentView` owns timer semantics and premium presentation. / `ContentView` 负责时间语义与高级视觉呈现。
- `WheelPickerView` owns discrete wheel interaction, arc background, and gradient ticks. / `WheelPickerView` 负责离散滚轮交互、弧形背景与渐变刻度。
- When files, boundaries, or responsibilities change, update file headers and relevant `.folder.md` maps in the same change. / 当文件、边界或职责变化时，必须在同一修改中同步更新文件头注释与相关 `.folder.md` 地图。
