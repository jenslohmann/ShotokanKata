//
//  SpeakButton.swift
//  Shōtōkan Kata
//

import SwiftUI
import AVFoundation

@MainActor
final class SpeechController: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechController()

    @Published var speakingText: String? = nil

    private let synthesizer = AVSpeechSynthesizer()

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, language: String = "ja-JP") {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            // If the same word was tapped again, just stop
            if speakingText == text { return }
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession setup failed: \(error)")
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.4
        speakingText = text
        synthesizer.speak(utterance)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {}

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        Task { @MainActor in self.speakingText = nil }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        Task { @MainActor in self.speakingText = nil }
    }
}

struct SpeakButton: View {
    let text: String
    var language: String = "ja-JP"

    @ObservedObject private var controller = SpeechController.shared

    private var isSpeaking: Bool { controller.speakingText == text }

    var body: some View {
        Button {
            controller.speak(text, language: language)
        } label: {
            Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                .foregroundColor(isSpeaking ? .japaneseRed : .secondary)
                .font(.body)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(NSLocalizedString("vocabulary.speak.button", comment: "Speak Japanese word"))
    }
}

#Preview {
    SpeakButton(text: "かた")
        .padding()
}

