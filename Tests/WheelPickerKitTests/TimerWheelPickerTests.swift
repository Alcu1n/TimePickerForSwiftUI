// [IN]: XCTest, SwiftUI bindings, and WheelPickerKit public picker-style contracts / XCTest、SwiftUI 绑定与 WheelPickerKit 公开选择器样式契约
// [OUT]: Deterministic package tests for presets, immersive default style, initial selection fallback, exposed aliases, and binding-based selection flow / 用于预设、默认沉浸式样式、初始默认值回退、公开别名与绑定式选值流的确定性包测试
// [POS]: Lock down the distributable API while allowing the renderer internals to evolve and the default style contract to stay explicit / 锁定可分发 API，同时允许渲染器内部继续演进并让默认样式契约保持明确
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

    func testReadableCustomizationAliasesStayAvailable() {
        let colors = TimerWheelPickerStyle.Colors(
            inactiveTint: .orange,
            tickGradient: Gradient(colors: [.blue, .purple]),
            tickColor: .red
        )
        var typography = TimerWheelPickerStyle.Typography(unitLabel: "Relaxed")
        typography.captionText = "Wind Up"
        let style = TimerWheelPickerStyle(colors: colors, typography: typography)
        let config = style.makeWheelConfig()

        XCTAssertNotNil(style.colors.tickColor)
        XCTAssertEqual(config.tickGradient.stops.count, 2)
        XCTAssertEqual(style.typography.unitLabel, "Wind Up")
        XCTAssertEqual(style.typography.captionText, "Wind Up")
    }

    @MainActor
    func testPickerInitializerExposesRangeStepAndStyle() {
        let selection = Binding.constant(45)
        let picker = TimerWheelPicker(
            selection: selection,
            range: 10...300,
            step: 5
        )

        XCTAssertEqual(picker.range, 10...300)
        XCTAssertEqual(picker.step, 5)
        XCTAssertEqual(picker.initialSelection, 30)
        XCTAssertEqual(picker.style.layout.arcProfile, .fullWidthShallow)
        XCTAssertEqual(picker.style.typography.unitLabel, "Relaxed")
    }

    @MainActor
    func testPickerInitializerAllowsLegacyPremiumPresetOverride() {
        let selection = Binding.constant(45)
        let picker = TimerWheelPicker(
            selection: selection,
            style: .premiumDemo
        )

        XCTAssertEqual(picker.style.layout.arcProfile, .classic)
        XCTAssertEqual(picker.style.typography.unitLabel, "MIN")
    }

    @MainActor
    func testConsumerBindingCanReadAndWriteSelectionValue() {
        var currentSelection = 45
        let selection = Binding(
            get: { currentSelection },
            set: { currentSelection = $0 }
        )

        _ = TimerWheelPicker(selection: selection, style: .immersiveArc)

        XCTAssertEqual(selection.wrappedValue, 45)
        selection.wrappedValue = 90
        XCTAssertEqual(currentSelection, 90)
    }

    @MainActor
    func testPickerInitializerExposesCustomInitialSelection() {
        let selection = Binding.constant(45)
        let picker = TimerWheelPicker(
            selection: selection,
            range: 10...300,
            step: 5,
            initialSelection: 75,
            style: .immersiveArc
        )

        XCTAssertEqual(picker.initialSelection, 75)
    }
}
