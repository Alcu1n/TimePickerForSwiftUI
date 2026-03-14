// [IN]: XCTest, SwiftUI bindings, and WheelPickerKit public API / XCTest、SwiftUI 绑定与 WheelPickerKit 公开 API
// [OUT]: Deterministic package tests for picker defaults and exposed configuration / 用于选择器默认值与公开配置的确定性包测试
// [POS]: Lock down the distributable contract so GitHub consumers get a stable API surface / 锁定可分发契约，保证 GitHub 使用者拿到稳定 API 面
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import SwiftUI
import XCTest
@testable import WheelPickerKit

final class TimerWheelPickerTests: XCTestCase {
    func testDefaultStyleUsesExpectedUnitLabel() {
        let style = TimerWheelPickerStyle.premiumDemo

        XCTAssertEqual(style.typography.unitLabel, "MIN")
        XCTAssertEqual(style.layout.largeTickFrequency, 5)
        XCTAssertEqual(style.layout.tickWidth, 3.3, accuracy: 0.001)
    }

    func testCustomStyleKeepsExposedLayoutAndTypographyValues() {
        let style = TimerWheelPickerStyle(
            colors: .init(ringBackground: .green),
            layout: .init(dialHeight: 196, dialScale: 0.82, indicatorHeight: 24, tickWidth: 4),
            typography: .init(valueFontSize: 52, unitFontSize: 12, unitLabel: "SEC")
        )

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
