//
//  TTSPlayer.swift
//  TikTok-TTs
    

import SwiftUI
import Speech


@Observable
class TTSPlayer: NSObject {
    @ObservationIgnored var synthesizer = AVSpeechSynthesizer()
    var isSpeaking: Bool = false
    var isSpeechPaused: Bool = false

    
    func speak(_ prompt: String, voice: AVSpeechSynthesisVoice, settings: UtteranceConfiguration) {
        let utterance = AVSpeechUtterance(string: prompt)
        utterance.voice = voice
        utterance.rate = settings.rate
        utterance.pitchMultiplier = settings.pitchMultiplier
        utterance.volume = settings.volume
        
        synthesizer.delegate = self
        synthesizer.speak(utterance)
    }
}

extension TTSPlayer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        withAnimation { isSpeaking = true }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        withAnimation { isSpeaking = false }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        withAnimation {
            isSpeechPaused = true
            isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        withAnimation {
            isSpeechPaused = false
            isSpeaking = true
        }
    }
}
