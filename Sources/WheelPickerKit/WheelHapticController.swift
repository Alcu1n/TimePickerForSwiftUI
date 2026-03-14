// [IN]: Foundation timing and CoreHaptics engine lifecycle for synchronized feedback / Foundation 时间控制与用于同步反馈的 CoreHaptics 引擎生命周期
// [OUT]: Package-private throttled per-tick haptic plus click-audio controller / 包内使用的带节流逐刻度震动与点击音控制器
// [POS]: Keep tactile feedback stable without leaking engine management into the public picker API / 保持触感反馈稳定，同时不把引擎管理泄漏到公开组件 API
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import CoreHaptics
import Foundation

@MainActor
final class WheelHapticController: ObservableObject {
    private var engine: CHHapticEngine?
    private var engineIsStarted = false
    private var supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    private let minimumInterval: TimeInterval = 1.0 / 18.0
    private let tickAudioDuration: TimeInterval = 0.026
    private var lastFeedbackTime: TimeInterval = 0
    private var selectionPattern: CHHapticPattern?

    func prepare() {
        guard supportsHaptics else { return }
        createEngineIfNeeded()
        selectionPattern = makeSelectionPattern()
    }

    func beginInteraction() {
        guard supportsHaptics else { return }
        createEngineIfNeeded()
        startEngineIfNeeded()
    }

    func endInteraction() {
        lastFeedbackTime = 0
    }

    func playSelectionTick() {
        guard supportsHaptics else { return }

        let now = Date.timeIntervalSinceReferenceDate
        guard now - lastFeedbackTime >= minimumInterval else { return }

        createEngineIfNeeded()
        startEngineIfNeeded()

        let pattern = selectionPattern ?? makeSelectionPattern()
        guard let pattern else { return }
        selectionPattern = pattern

        do {
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
            lastFeedbackTime = now
        } catch {
            recreateEngine()
        }
    }

    private func createEngineIfNeeded() {
        guard engine == nil else { return }

        do {
            let engine = try CHHapticEngine()
            engine.isAutoShutdownEnabled = false
            engine.playsHapticsOnly = false
            engine.stoppedHandler = { [weak self] _ in
                Task { @MainActor in
                    self?.engineIsStarted = false
                }
            }
            engine.resetHandler = { [weak self] in
                Task { @MainActor in
                    self?.engineIsStarted = false
                    self?.selectionPattern = self?.makeSelectionPattern()
                    self?.startEngineIfNeeded()
                }
            }
            self.engine = engine
        } catch {
            supportsHaptics = false
        }
    }

    private func startEngineIfNeeded() {
        guard let engine else { return }
        guard !engineIsStarted else { return }

        do {
            try engine.start()
            engineIsStarted = true
        } catch {
            recreateEngine()
        }
    }

    private func recreateEngine() {
        engine?.stop(completionHandler: nil)
        engine = nil
        engineIsStarted = false
        createEngineIfNeeded()
        selectionPattern = makeSelectionPattern()
        startEngineIfNeeded()
    }

    private func makeSelectionPattern() -> CHHapticPattern? {
        let hapticEvent = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 0.28),
                .init(parameterID: .hapticSharpness, value: 0.42)
            ],
            relativeTime: 0
        )

        let audioEvent = CHHapticEvent(
            eventType: .audioContinuous,
            parameters: [
                .init(parameterID: .audioVolume, value: 0.14),
                .init(parameterID: .audioPitch, value: 0.55),
                .init(parameterID: .audioBrightness, value: 0.82),
                .init(parameterID: .attackTime, value: 0),
                .init(parameterID: .decayTime, value: 0.08),
                .init(parameterID: .releaseTime, value: 0.05),
                .init(parameterID: .sustained, value: 0)
            ],
            relativeTime: 0,
            duration: tickAudioDuration
        )

        do {
            return try CHHapticPattern(events: [audioEvent, hapticEvent], parameters: [])
        } catch {
            return try? CHHapticPattern(events: [hapticEvent], parameters: [])
        }
    }
}
