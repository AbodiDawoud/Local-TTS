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
                    VStack(spacing: 1) {
                        LabeledContent {
                            Text("**\(utterance.rate, specifier: "%.1f")**")
                        } label: {
                            Label("Rate", systemImage: "waveform.path")
                                .labelStyle(SquaredStyle(color: .indigo))
                        }

                        
                        JunoSlider(sliderValue: $utterance.rate, maxSliderValue: 1, label: "")
                            .shadow(radius: 5)
                    }
                }
                
                Section {
                    VStack(spacing: 1) {
                        LabeledContent {
                            Text("**\(utterance.volume, specifier: "%.1f")**")
                        } label: {
                            Label("Volume", systemImage: "speaker.plus.fill")
                                .labelStyle(SquaredStyle(color: .purple))
                        }

                        
                        JunoSlider(sliderValue: $utterance.volume, maxSliderValue: 1, label: "")
                            .shadow(radius: 5)
                    }
                }
                
                Section {
                    VStack(spacing: 1) {
                        LabeledContent {
                            Text("**\(utterance.pitchMultiplier, specifier: "%.1f")**")
                        } label: {
                            Label("Pitch", systemImage: "waveform.path.ecg")
                                .labelStyle(SquaredStyle(color: .orange))
                        }

                        
                        JunoSlider(sliderValue: $utterance.pitchMultiplier, maxSliderValue: 2, label: "")
                            .shadow(radius: 5)
                    }
                }
                
                Section {
                    Button("Randomize", action: randomizeUtteranceProperties)
                }.frame(maxWidth: .infinity)
            }
            .navigationTitle("Configurations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: dismiss.callAsFunction)
                        .tint(.gray)
                        .fontWeight(.medium)
                        .controlSize(.small)
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)
                }
            }
            .toolbarTitleMenu {
                Link(destination: URL(string: "https://developer.apple.com/documentation/avfaudio/avspeechutterance")!) {
                    Label("Apple Documentation", systemImage: "applelogo")
                }
                Divider()
                Button("Reset Config", systemImage: "arrow.clockwise", action: resetConfiguration)
            }
            .onAppear(perform: setNavigationAppearance)
            .listSectionSpacing(.compact)
        }
        .presentationDetents([.fraction(0.7)])
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
    
    func setNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = UIColor.systemGray4

        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}


fileprivate struct SquaredStyle: LabelStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .frame(width: 32, height: 32)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .background(color.gradient, in: .buttonBorder)
            
            configuration.title
        }
    }
}

#Preview {
    SpeechConfigView(utterance: .constant(.default))
}
