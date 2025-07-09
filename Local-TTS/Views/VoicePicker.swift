//
//  VoicePicker.swift
//  TextToSpeechDemo


import SwiftUI
import Speech


struct VoicePickerView: View {
    @Binding var selectedVoice: AVSpeechSynthesisVoice
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""
    @State private var selectedLanguage: String
    @State private var selectedGender: Int = -1
    @State private var selectedQuality: Int = 1
    
    
    private let availableLanguages: Set<String>
    @Environment(TTSPlayer.self) private var player
    @Environment(\.dismiss) private var dimiss
    
    
    init(selectedVoice: Binding<AVSpeechSynthesisVoice>) {
        self._selectedVoice = selectedVoice
        
        var allLanguages = AVSpeechSynthesisVoice.speechVoices().map((\.language))
        allLanguages.insert("All", at: 0)
        
        self._selectedLanguage = State(initialValue: allLanguages.first!)
        self.availableLanguages = Set(allLanguages)
    }

    
    var body: some View {
        List {
            Section {
                InfoView(key: "Voices", value: filteredVoices.count.str, icon: .voiceSelectionSymbol, background: .blue)
                InfoView(key: "Languages", value: availableLanguages.count.str, icon: .languageSymbol, background: .indigo)
            } header: {
                Text("**Info**")
            } footer: {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 0) {
                        Text("You can install more voices from ")
                        Text("Settings").foregroundStyle(.blue).onTapGesture(perform: openSettingsUrl)
                    }
                    
                    Text("Accessibility > Spoken Content > Voices.").bold()
                }
            }
            
            Section {
                ForEach(filteredVoices, id: \.identifier) { voice in
                    Button {
                        submitVoice(voice)
                    } label: {
                        LabeledContent(voice.name) {
                            Text(languageLocalizedString(for: voice.language))
                        }
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button("Done", systemImage: "checkmark.circle.fill") { submitVoice(voice) }
                        Button("Try", systemImage: "ear.fill") { speakText(voice: voice) }.tint(.indigo)
                    }
                }
            }
        }
        .navigationTitle("Installed Voices")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: setNavigationAppearance)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .toolbar { filterButton }
        .toolbarTitleMenu {
            Menu("Gender", image: .genderSymbol) {
                Picker("", selection: $selectedGender.animation()) {
                    Text("Mixed").tag(-1)
                    Text("Unspecified").tag(0)
                    Text("Male").tag(1)
                    Text("Female").tag(2)
                }
            }
            
            Menu("Quality", image: .qualitySymbol) {
                Picker("", selection: $selectedQuality.animation()) {
                    Text("Default").tag(1)
                    Text("Enhanced").tag(2)
                    Text("Premium  (iOS 17.0)").tag(3)
                }
            }
        }
    }
    
    private var filterButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker("Filter Language", selection: $selectedLanguage.animation()) {
                    ForEach(availableLanguages.sorted(), id: \.self) {
                        Text(advancedLanguageFormatting(for: $0)).tag($0)
                    }
                }.pickerStyle(.inline)
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .imageScale(.large).symbolRenderingMode(.hierarchical)
            }.tint(.secondary)
        }
    }

    
    
    func speakText(voice: AVSpeechSynthesisVoice) {
        let textToSpeak = "Hello, I'm \(voice.name)"
        player.speak(textToSpeak, voice: voice, settings: .default)
    }
    
    func submitVoice(_ voice: AVSpeechSynthesisVoice) {
        selectedVoice = voice
        dismiss()
    }
    
    func languageLocalizedString(for code: String) -> String {
        // returns the name of the language for the given code
        return NSLocale.current.localizedString(forLanguageCode: code) ?? "Unknown"
    }
    
    func advancedLanguageFormatting(for language: String) -> String {
        if language == "All" { return "All" }
        let nsLoc = NSLocale(localeIdentifier: language)
       
        guard let languageString = NSLocale.current.localizedString(forLanguageCode: nsLoc.languageCode),
              let regionString = NSLocale.current.localizedString(forRegionCode:  nsLoc.regionCode ?? "")
        else { return "Unknown" }
        
        return "\(languageString)  [\(regionString)]"
    }
    
    var filteredVoices: [AVSpeechSynthesisVoice] {
        var availableVoices = AVSpeechSynthesisVoice.speechVoices()
        
        if selectedLanguage != "All" {
            // Filter voices based on selected language
            availableVoices = availableVoices.filter {
                $0.language == selectedLanguage
            }
        }
        
        // -1 is equal "Mixed" which means "All"
        if selectedGender != -1 {
            // Filter voices to get the specified gender
            availableVoices = availableVoices.filter { $0.gender.rawValue == selectedGender }
        }
        
        // Filter voices to get the desired quality
        availableVoices = availableVoices.filter { $0.quality.rawValue == selectedQuality }
        
        
        // If no search text, return the processed filtered voices
        if searchText.isEmpty { return availableVoices }
        
        
        return availableVoices.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            // Get language name eg.. (English), if search query contains "english" return all found voices
            languageLocalizedString(for: $0.language).localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func openSettingsUrl() {
        UIApplication.shared.open(
            URL(string: "App-prefs:")!
        )
    }
    
    func setNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = UIColor.systemGray4

        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}




fileprivate struct InfoView: View {
    let key: String
    let value: String
    let icon: ImageResource
    let background: Color // Icon background color

    
    var body: some View {
        LabeledContent {
            Text(value)
                .font(.system(.callout, design: .rounded, weight: .medium))
                .foregroundStyle(.gray)
        } label: {
            HStack {
                Image(icon)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.white)
                    .fontWeight(.light)
                    .background(background, in: .buttonBorder)
                
                Text(key)
            }
        }
    }
}
