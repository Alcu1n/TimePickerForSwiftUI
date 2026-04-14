// [IN]: Foundation timing, AVFoundation metallic-ratchet synthesis, and platform feedback generators for synchronized per-tick feedback / Foundation 时间节流、AVFoundation 金属棘轮声合成与平台反馈生成器，用于同步逐刻度反馈
// [OUT]: Package-private throttled rigid-impact haptic and low-latency metallic ratchet audio controller for wheel selection / 包内使用的带节流刚性冲击震动与低延迟金属棘轮音控制器
// [POS]: Keep tactile and audible feedback crisp, ratcheted, and fast enough for aggressive wheel scrubbing / 保持触感与声音反馈清脆、带棘轮感，并能跟上快速滚动
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议:更新本文件时,同步更新此头注释及所属文件夹的 .folder.md

import AVFoundation
import Foundation
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class WheelHapticController: ObservableObject {
    private let minimumHapticInterval: TimeInterval = 1.0 / 22.0
    private let minimumAudioInterval: TimeInterval = 1.0 / 38.0
    private var lastHapticTime: TimeInterval = 0
    private var lastAudioTime: TimeInterval = 0
    private var audioEngine: AVAudioEngine?
    private var audioPlayers: [AVAudioPlayerNode] = []
    private var tickBuffers: [AVAudioPCMBuffer] = []
    private var nextAudioPlayerIndex = 0
    private var nextBufferIndex = 0
    private var audioEngineIsStarted = false
    #if canImport(UIKit)
    private let impactGenerator = UIImpactFeedbackGenerator(style: .rigid)
    #endif

    func prepare() {
        prepareAudio()
        #if canImport(UIKit)
        impactGenerator.prepare()
        #endif
    }

    func beginInteraction() {
        prepareAudio()
        #if canImport(UIKit)
        impactGenerator.prepare()
        #endif
    }

    func endInteraction() {
        lastHapticTime = 0
        lastAudioTime = 0
    }

    func playSelectionTick() {
        let now = Date.timeIntervalSinceReferenceDate

        #if canImport(UIKit)
        if now - lastHapticTime >= minimumHapticInterval {
            impactGenerator.impactOccurred(intensity: 1)
            impactGenerator.prepare()
            lastHapticTime = now
        }
        #endif

        if now - lastAudioTime >= minimumAudioInterval {
            playTickAudio()
            lastAudioTime = now
        }
    }

    private func prepareAudio() {
        configureAudioSessionIfNeeded()
        createAudioEngineIfNeeded()
        startAudioEngineIfNeeded()
    }

    private func createAudioEngineIfNeeded() {
        guard audioEngine == nil else { return }

        let engine = AVAudioEngine()
        let buffers = makeTickBuffers()
        let format = buffers.first?.format ?? AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)

        guard let format else { return }

        let players = (0..<6).map { _ in AVAudioPlayerNode() }

        for player in players {
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)
        }

        engine.mainMixerNode.outputVolume = 0.72

        audioEngine = engine
        audioPlayers = players
        tickBuffers = buffers
    }

    private func startAudioEngineIfNeeded() {
        guard let audioEngine, !audioEngineIsStarted else { return }

        do {
            try audioEngine.start()
            audioEngineIsStarted = true
        } catch {
            audioEngineIsStarted = false
        }
    }

    private func playTickAudio() {
        guard !audioPlayers.isEmpty, !tickBuffers.isEmpty else { return }
        guard audioEngineIsStarted else {
            prepareAudio()
            guard audioEngineIsStarted else { return }
            playTickAudio()
            return
        }

        let player = audioPlayers[nextAudioPlayerIndex]
        nextAudioPlayerIndex = (nextAudioPlayerIndex + 1) % audioPlayers.count
        let buffer = tickBuffers[nextBufferIndex]
        nextBufferIndex = (nextBufferIndex + 1) % tickBuffers.count

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }

    private func makeTickBuffers() -> [AVAudioPCMBuffer] {
        (0..<4).compactMap { makeTickBuffer(variant: $0) }
    }

    private func makeTickBuffer(variant: Int) -> AVAudioPCMBuffer? {
        let sampleRate = 44_100.0

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            return nil
        }

        let frameCount = AVAudioFrameCount(520)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }

        buffer.frameLength = frameCount

        guard let channelData = buffer.floatChannelData?[0] else {
            return buffer
        }

        var noiseState: UInt32 = 0xA341316C
        let variantOffset = Float(variant) * 70
        let angularA = Float.pi * 2 * (2_120 + variantOffset) / Float(sampleRate)
        let angularB = Float.pi * 2 * (3_340 + (variantOffset * 1.2)) / Float(sampleRate)
        let angularC = Float.pi * 2 * (5_180 + (variantOffset * 1.55)) / Float(sampleRate)
        let angularD = Float.pi * 2 * (7_040 + (variantOffset * 1.8)) / Float(sampleRate)
        let angularTransient = Float.pi * 2 * (6_100 + (variantOffset * 0.9)) / Float(sampleRate)
        let secondaryDelay = 34 + (variant * 7)

        for frame in 0..<Int(frameCount) {
            let progress = Float(frame) / Float(frameCount)
            let frameValue = Float(frame)
            noiseState = 1_664_525 &* noiseState &+ 1_013_904_223
            let normalizedNoise = Float(noiseState & 0xFFFF) / Float(UInt16.max)
            let signedNoise = (normalizedNoise * 2) - 1
            let attack = min(progress * 64, 1)
            let ringEnvelope = expf(-progress * 21)
            let transientEnvelope = expf(-progress * 92)
            let toothImpulse = frame < 4 ? (1 - (Float(frame) / 4)) : 0
            let delayedFrame = frame - secondaryDelay
            let releaseImpulse: Float =
                delayedFrame >= 0 && delayedFrame < 3 ? (1 - (Float(delayedFrame) / 3)) * 0.58 : 0
            let impulseShape = toothImpulse + releaseImpulse
            let transient = impulseShape * 0.82
                + (sinf(frameValue * angularTransient) * 0.22 + signedNoise * 0.05) * transientEnvelope
            let partialA = sinf(frameValue * angularA) * 0.54
            let partialB = sinf((frameValue * angularB) + 0.37) * 0.28
            let partialC = sinf((frameValue * angularC) + 0.91) * 0.16
            let partialD = sinf((frameValue * angularD) + 1.46) * 0.09
            let metallicBody = (partialA + partialB + partialC + partialD) * ringEnvelope
            let signal = (transient + metallicBody) * attack

            channelData[frame] = signal * 0.68
        }

        return buffer
    }

    private func configureAudioSessionIfNeeded() {
        #if canImport(UIKit)
        let session = AVAudioSession.sharedInstance()

        guard session.category != .playback || !session.categoryOptions.contains(.mixWithOthers) else {
            return
        }

        do {
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true, options: [])
        } catch {
            return
        }
        #endif
    }
}
