import AVFoundation
import Foundation
import Observation
import Speech
import SwiftUI

@Observable
final class SpeechRecognitionService {
    var transcript = ""
    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    func requestAuthorization() async {
        authorizationStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    func mockTranscribe() {
        transcript = "Today I showed up even though I did not feel ready. I want to become more disciplined and calm."
    }
}

@Observable
final class VoiceRecordingService {
    var isRecording = false
    var isPaused = false

    func start() {
        isRecording = true
        isPaused = false
    }

    func pause() {
        isPaused = true
    }

    func resume() {
        isPaused = false
    }

    func stop() {
        isRecording = false
        isPaused = false
    }
}

@Observable
final class WaveformAnimationManager {
    var samples: [Double] = (0..<36).map { index in
        0.25 + (sin(Double(index) * 0.7) + 1) * 0.3
    }

    func refresh() {
        samples = samples.enumerated().map { index, _ in
            0.2 + (sin(Date().timeIntervalSince1970 * 2 + Double(index) * 0.55) + 1) * 0.35
        }
    }
}
