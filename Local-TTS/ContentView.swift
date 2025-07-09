//
//  ContentView.swift
//  Local-TTS
    

import SwiftUI
import Speech
import AlertKit


struct ContentView: View {
    @State private var userPrompt: String = ""
    
    @State private var showVoicePicker: Bool = false
    @State private var showConfigForm: Bool = false
    @State private var isFilePickerPresented: Bool = false
    
    @State private var selectedVoice: AVSpeechSynthesisVoice = .init(language: "en")!
    @State private var speechUtterance: UtteranceConfiguration = .default
    @Environment(TTSPlayer.self) private var player
    
    
    var body: some View {
        Form {
            HeroCardView()
            
            Section {
                TextField("What would you like to hear?", text: $userPrompt.animation(), axis: .vertical)
                    .frame(minHeight: 200, alignment: .topLeading)
            } header: {
                HStack {
                    Text("Your Prompt")
                    Spacer()
                    if !promptEmpty {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .symbolVariant(.circle.fill)
                            .symbolRenderingMode(.hierarchical)
                            .onTapGesture(perform: clearPrompt)
                    }
                }
            }
            
            Section("Actions") {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button("", systemImage: "plus") {
                            isFilePickerPresented.toggle()
                        }
                        
                        
                        Spacer()
                        
                        Divider()
                        Spacer()
                        
                        Button("", image: .voice) {
                            showConfigForm.toggle()
                        }
                        
                        
                        Spacer()
                        Divider().frame(height: 50)
                        
                        Spacer()
                        Button("", image: .voiceSelectionSymbol) {
                            showVoicePicker.toggle()
                        }.fontWeight(.light)
                            
                        Spacer()
                    }
                    .font(.title3)
                    .labelStyle(.iconOnly)
                    
                    Divider()
                }
                .listRowInsets(EdgeInsets())
                
                
                VStack(alignment: .leading, spacing: 15) {
                    speakButton
                    
                    Rectangle()
                        .frame(height: 0.7)
                        .foregroundStyle(
                            LinearGradient(colors: [.clear, Color.gray.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    Button("Export as Audio") {
                        saveSpeechAsAudioFile(prompt: userPrompt)
                    }
                }
                .padding(.vertical, 10)
                .disabled(promptEmpty)
                .redacted(reason: promptEmpty ? .placeholder : .privacy)
            }
            .buttonStyle(.plain)
            .listRowSeparator(.hidden)
        }
        ._addingBackgroundLayer()
        .scrollDismissesKeyboard(.immediately)
        .fileImporter(isPresented: $isFilePickerPresented, allowedContentTypes: [.text], onCompletion: onImportTextFile)
        .sheet(isPresented: $showConfigForm) { SpeechConfigView(utterance: $speechUtterance) }
        .sheet(isPresented: $showVoicePicker) {
            NavigationStack {
                VoicePickerView(selectedVoice: $selectedVoice)
            }
        }
    }
    
    private var speakButton: some View {
        Button(
            player.isSpeaking ? "Pause" : player.isSpeechPaused ? "Resume" : "Play Audio"

        ) {
            if player.isSpeaking {
                player.synthesizer.pauseSpeaking(at: .word)
                return
            } else if player.isSpeechPaused {
                player.synthesizer.continueSpeaking()
                return
            } else {
                player.speak(userPrompt, voice: selectedVoice, settings: speechUtterance)
            }
        }
        .symbolVariant(.fill)
    }
    
    
    
    var promptEmpty: Bool {
        userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func clearPrompt() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation { userPrompt = "" }
    }
    

    
    func onImportTextFile(result: Result<URL, Error>) {
        guard let url = try? result.get(),
              url.startAccessingSecurityScopedResource(),
              let data = try? Data(contentsOf: url),
              let content = String(data: data, encoding: .utf8),
              !content.isEmpty
        else { return }
        
        withAnimation {
            userPrompt = content
        }
        
        url.stopAccessingSecurityScopedResource()
    }
    
    func saveSpeechAsAudioFile(prompt: String) {
        let utterance = AVSpeechUtterance(string: userPrompt)
        utterance.voice = selectedVoice
        utterance.rate = speechUtterance.rate
        utterance.pitchMultiplier = speechUtterance.pitchMultiplier
        utterance.volume = speechUtterance.volume
        
        let outputURL = FileManager.default.temporaryDirectory
                                           .appendingPathComponent(UUID().uuidString)
                                           .appendingPathExtension("caf")
        
        // Define a consistent audio format
        let audioFormatSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 22050.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        
        guard let audioFormat = AVAudioFormat(settings: audioFormatSettings),
              let audioFile = try? AVAudioFile(forWriting: outputURL, settings: audioFormat.settings)
        else { return }

        
        player.synthesizer.write(utterance) {
            guard let pcmBuffer = $0 as? AVAudioPCMBuffer else { return }

            if pcmBuffer.frameLength == 0 {
                presentDocumentPicker(for: outputURL)
                return
            }

            do {
                try audioFile.write(from: pcmBuffer)
            } catch {
                AlertKitAPI.present(title: "Error", subtitle: error.localizedDescription, icon: .error, style: .iOS16AppleMusic, haptic: .error)
            }
        }
    }
    
    func presentDocumentPicker(for location: URL) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [location])
        UIWindow.controller.present(documentPicker, animated: true)
    }
}

#Preview {
    ContentView().environment(TTSPlayer())
}
