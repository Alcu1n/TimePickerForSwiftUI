// [IN]: XCTest, SwiftUI bindings, and WheelPickerKit public picker-style contracts / XCTest、SwiftUI 绑定与 WheelPickerKit 公开选择器样式契约
// [OUT]: Deterministic package tests for presets, arc profiles, and exposed configuration / 用于预设、圆弧轮廓与公开配置的确定性包测试
// [POS]: Lock down the distributable API while allowing the renderer internals to evolve / 锁定可分发 API，同时允许渲染器内部继续演进
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import SwiftUI
import XCTest
@testable import WheelPickerKit

final class TimerWheelPickerTests: XCTestCase {
    func testDefaultStyleUsesExpectedUnitLabel() {
        let style = TimerWheelPickerStyle.premiumDemo

        XCTAssertEqual(style.typography.unitLabel, "MIN")
        XCTAssertEqual(style.layout.arcProfile, .classic)
        XCTAssertEqual(style.layout.largeTickFrequency, 5)
        XCTAssertEqual(style.layout.tickWidth, 3.3, accuracy: 0.001)
    }

    func testImmersiveArcPresetUsesFullWidthShallowProfile() {
        let style = TimerWheelPickerStyle.immersiveArc

        XCTAssertEqual(style.layout.arcProfile, .fullWidthShallow)
        XCTAssertEqual(style.layout.dialScale, 1, accuracy: 0.001)
        XCTAssertEqual(style.layout.largeTickFrequency, 10)
        XCTAssertEqual(style.typography.unitLabel, "Relaxed")
    }

    func testCustomStyleKeepsExposedLayoutAndTypographyValues() {
        let style = TimerWheelPickerStyle(
            colors: .init(ringBackground: .green),
            layout: .init(arcProfile: .fullWidthShallow, dialHeight: 196, dialScale: 0.82, indicatorHeight: 24, tickWidth: 4),
            typography: .init(valueFontSize: 52, unitFontSize: 12, unitLabel: "SEC")
        )

        XCTAssertEqual(style.layout.arcProfile, .fullWidthShallow)
        XCTAssertEqual(style.layout.dialHeight, 196, accuracy: 0.001)
        XCTAssertEqual(style.layout.dialScale, 0.82, accuracy: 0.001)
        XCTAssertEqual(style.layout.indicatorHeight, 24, accuracy: 0.001)
        XCTAssertEqual(style.layout.tickWidth, 4, accuracy: 0.001)
        XCTAssertEqual(style.typography.unitLabel, "SEC")
    }

    @MainActor
    func testPickerInitializerExposesRangeStepAndStyle() {
        let style = TimerWheelPickerStyle(
            typography: .init(unitLabel: "SEC")
        )
        let selection = Binding.constant(45)
        let picker = TimerWheelPicker(
            selection: selection,
            range: 10...300,
            step: 5,
            style: style
        )

        XCTAssertEqual(picker.range, 10...300)
        XCTAssertEqual(picker.step, 5)
        XCTAssertEqual(picker.style.typography.unitLabel, "SEC")
    }
}
