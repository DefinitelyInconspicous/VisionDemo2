//contains text recognition View and translation View on top of one another
import SwiftUI

struct TextTranslateView: View {
    @StateObject private var recognizeText = RecognizeText()
    @State private var selectedLanguage = "English"
    @State private var image = UIImage()
    @State private var showingImagePicker = false
    
    
    var body: some View {
        ScrollView{
            VStack(alignment: .center, spacing: 24) {
                //Recognize text from photo view
                PhotoTextRecognitionView(recognizeText: recognizeText, selectedImage: $image)
                
                //Translate the recognized text view
                TranslationView(
                    sourceText: recognizeText.resultStrings.joined(separator: " "),
                    sourceLanguage: nil
                )
            }
            .padding()
        }
        .navigationTitle("Vision")
    }
}

