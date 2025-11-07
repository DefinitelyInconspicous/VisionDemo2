//recognise Text function
//NOTE: as of now, Vision supports 18 different langauges
import SwiftUI
import Vision
import Combine

class RecognizeText: ObservableObject {
    @Published var resultStrings: [String] = []
    
    func recognizeText(data: Data) async {
        self.resultStrings = []
        
        var request = RecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = [Locale.Language.init(identifier: "zh-Hans"), Locale.Language.init(identifier: "en-US")]
        
        do {
            let results = try await request.perform(on: data)
            let recognizedStrings = results.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            print(recognizedStrings)
            DispatchQueue.main.async {
                self.resultStrings = recognizedStrings
            }
        } catch(let error) {
            print("error recognizing text: \(error.localizedDescription)")
        }
    }
}
