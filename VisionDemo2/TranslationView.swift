//NOTE: Translation View contains Translation logic
//Apple's translation framwork only supports translation between 2 different langauges, ie: English to English translation will result in an error
//languages that are in use in the app must be downloaded be Translation framework to work

import SwiftUI
import Translation

struct TranslationView: View {
    var sourceText: String
    var sourceLanguage: Locale.Language?
    
    @State private var selectedLanguage = "English" //default or initial selectedLanguage is English
    @State private var targetText: String?
    @State private var configuration: TranslationSession.Configuration?
    @State private var isTranslating = false
    
    private let languages = ["English", "Chinese", "German", "French"] //languages to translate into
    
    var body: some View {
        VisionCardView(title: "Translate") {
            VStack(spacing: 16) {
                //Picker is that dropdown button that shows languages to pick when clicked on ("English")
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(languages, id: \.self) { Text($0) }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedLanguage) {
                    triggerTranslation()
                }
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.05))
                    .frame(height: 180)
                    .overlay(
                        ScrollView {
                            //if translation is still in progress, show a circular loading view, else display the translated text
                            if isTranslating {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .padding()
                            } else {
                                Text(displayText)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)
                                    .padding()
                            }
                        }
                    )
            }
            .padding()
            //auto produce translated text after clicking on "Detect Text" button
            .onAppear { //function triggerTranslation is called once TranslationView appears, detected text is being translated
                triggerTranslation()
            } 
            .onChange(of: sourceText) { //whenever sourceText (detected Text from photo) changes, function triggerTranslation runs again detected text is being translated
                triggerTranslation()
            }
            .translationTask(configuration) { session in
                guard !sourceText.isEmpty else { return }
                do {
                    //if there is detected text, translate it
                    isTranslating = true
                    let response = try await session.translate(sourceText)
                    //translate the detected text from photo
                    targetText = response.targetText //result of translation
                } catch {
                    print("Translation error:", error)
                    targetText = "Translation failed: \(error.localizedDescription)"
                }
                //set isTranslating to false when translation is done
                isTranslating = false
            }
        }
    }
    
    private var displayText: String {
        sourceText.isEmpty ? "Translated text will appear here..." : (targetText ?? "")
        //if there is no detected text, show "Translated text will appear here...", else show translated text
    }
    
    private var targetLocale: Locale.Language {
        switch selectedLanguage {
        case "Chinese": return .init(identifier: "zh-Hans")
        case "German":  return .init(identifier: "de")
        case "French":  return .init(identifier: "fr")
        default:        return .init(identifier: "en") //english is default
        }
        //selectedLanguages enum contains all language codes
    }
    
    private func triggerTranslation() {
        guard !sourceText.isEmpty else {
            //if no detected Text, set targetText and configuration to nil
            targetText = nil
            configuration = nil
            return
        }
        
        DispatchQueue.main.async { //prioritise this background thread
            configuration?.invalidate() //invalidates previous translation session to call a new translation session
            configuration = TranslationSession.Configuration(
                source: sourceLanguage,
                target: targetLocale
            )
        }
    }
}
