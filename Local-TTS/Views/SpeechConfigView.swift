//
//  SpeechConfigView.swift
//  TikTok-TTs
    

import SwiftUI
import Speech


struct SpeechConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var utterance: UtteranceConfiguration

    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Label("Rate", systemImage: "waveform.path").labelStyle(SquaredStyle(color: .pink))
                        Slider(value: $utterance.rate, in: 0.1...1)
                            .padding(.leading, 37)
                    }
                }
                
                Section {
                    HStack {
                        Label("Volume", systemImage: "speaker.plus.fill").labelStyle(SquaredStyle(color: .indigo))
                        Slider(value: $utterance.volume, in: 0.1...1)
                            .padding(.leading)
                    }
                }
                
                Section {
                    HStack {
                        Label("Pitch", systemImage: "waveform.path.ecg").labelStyle(SquaredStyle(color: .orange))
                        Slider(value: $utterance.pitchMultiplier, in: 0.2...2)
                            .padding(.leading)
                    }
                }
                
                Section {
                    Button("Randomize", action: randomizeUtteranceProperties)
                }.frame(maxWidth: .infinity)
            }
            .navigationTitle("Configurations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarTitleMenu {
                Link(
                    "Apple Documentation",
                    destination: URL(string: "https://developer.apple.com/documentation/avfaudio/avspeechutterance")!
                )
                Divider()
                Button("Reset Config", role: .destructive, action: resetConfiguration)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.headline)
                            .imageScale(.large)
                            .foregroundStyle(.gray)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .listSectionSpacing(.compact)
            .onAppear(perform: setSliderAppearance)
        }
        .presentationDetents([.medium])
    }
    
    func setSliderAppearance() {
        let thumb = UIImage(systemName: "capsule.fill")!.withTintColor(.label, renderingMode: .alwaysOriginal)
        UISlider.appearance().setThumbImage(thumb, for: .normal)
    }
    

    func randomizeUtteranceProperties() {
        // Set random values within a reasonable range
        withAnimation {
            utterance.rate = Float.random(in: 0.35...0.65) // Rate: Moderate pace
            utterance.volume = Float.random(in: 0.7...1.0) // Volume: Loud but not too loud
            utterance.pitchMultiplier = Float.random(in: 0.9...1.3) // Pitch: Natural range
        }
    }
    
    
    func resetConfiguration() {
        withAnimation {
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.volume = 1.0
            utterance.pitchMultiplier = 1.0
        }
    }
}


struct UtteranceConfiguration: Equatable {
    var rate: Float = AVSpeechUtteranceDefaultSpeechRate
    var volume: Float = 1.0
    var pitchMultiplier: Float = 1.0
    
    static var `default`: UtteranceConfiguration = .init()
}


fileprivate struct SquaredStyle: LabelStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .frame(width: 32, height: 32)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .background(color, in: .buttonBorder)
            
            configuration.title
        }
    }
}
