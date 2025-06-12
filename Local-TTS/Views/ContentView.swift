//
//  BuiltInTTsView.swift
//  TikTok-TTs
    

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
                TextField("What would you like to hear?", text: $userPrompt, axis: .vertical)
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
                HStack {
                    Spacer()
                    Button("", systemImage: "note.text") {
                        isFilePickerPresented.toggle()
                    }
                        
                    Spacer()
                    
                    Divider()
                    Spacer()
                    
                    Button("", systemImage:  "gearshape.arrow.triangle.2.circlepath") {
                        showConfigForm.toggle()
                    }
                        
                    Spacer()
                    Divider()
                    
                    Spacer()
                    Button("", systemImage:  "waveform.badge.microphone") {
                        showVoicePicker.toggle()
                    }
                    Spacer()
                }
                .font(.title3.weight(.medium))
                .symbolRenderingMode(.hierarchical)
                .padding(.vertical, 6)
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .listRowInsets(EdgeInsets())
            }
            
            Section {
                speakButton
                
                Button("Export as Audio", systemImage: "square.and.arrow.up") {
                    saveSpeechAsAudioFile(prompt: userPrompt)
                }
            }
            .buttonStyle(.plain)
            .disabled(promptEmpty)
            .redacted(reason: promptEmpty ? .placeholder : .privacy)
            .listSectionSpacing(19)
            .symbolVariant(.fill)
            .symbolRenderingMode(.hierarchical)
        }
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
            player.isSpeaking ? "Pause" : player.isSpeechPaused ? "Resume" : "Speak Text",
            systemImage: player.isSpeaking ? "pause" : player.isSpeechPaused ? "playpause" : "play"
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





private struct HeroCardView: View {
    private let systemIcon: String = "bubble.left.and.text.bubble.right.fill"
    private let color: Color = .blue
    private let iconRotation: Double = 40
    
    var body: some View {
        Section {
            HStack {
                Image(systemName: systemIcon)
                    .font(.system(size: 24))
                    .foregroundStyle(color, .primary)
                    .frame(width: 50, height: 50)
                    .background(color.tertiary, in: .rect(cornerRadius: 12))
            
                
                VStack(alignment: .leading, spacing: 0.2) {
                    Text("Text To Speech")
                        .font(.title.bold().smallCaps()).fontDesign(.rounded)
                    
                    Text("On your device")
                        .textScale(.secondary)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .background {
                color
                    .frame(maxWidth: .infinity, maxHeight: 14)
                    .blur(radius: 50)
            }
            .background(alignment: .bottomTrailing) {
                Image(systemName: systemIcon)
                    .font(.system(size: 270))
                    .foregroundStyle(.gray.opacity(0.06))
                    .rotationEffect(.degrees(iconRotation))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .listRowSeparator(.hidden, edges: .bottom)
    }
}
