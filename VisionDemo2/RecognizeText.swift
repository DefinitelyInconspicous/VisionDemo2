//recognise Text function
//NOTE: as of now, Vision supports 18 different langauges

import SwiftUI
import Vision
import Combine

class RecognizeText: ObservableObject {
    
    @Published var resultStrings: [String] = []
    
    func recognizeText(data: Data) async {
        self.resultStrings = []
        
        var request = RecognizeTextRequest() //image-analysis request that recognizes text in an image
        request.recognitionLevel = .accurate
        request.recognitionLanguages = [Locale.Language.init(identifier: "zh-Hans"), Locale.Language.init(identifier: "en-US")] //set specific languages to identify
        
        //NOTE:
        //simplified chinese = zh-Hans, US english = en-US (search Language codes for more)
        //characters like chinese, jap, korean need .accurate and placed first in language array as they are languages with complex characters
        //if no array of recognitionLanguages are set, default language is english
        
        do {
            let results = try await request.perform(on: data) //perform text recognition
            let recognizedStrings = results.compactMap { observation in
                observation.topCandidates(1).first?.string // returns only best recognised text version
            }
            
            print(recognizedStrings)//detected text printed (in terminal)
            DispatchQueue.main.async {
                //dispatchQueue is needed as these are background threads hence need to tell your app that assigning recognizedStrings as resultStrings is your priority
                self.resultStrings = recognizedStrings
            } //result = detected text
            
        } catch(let error) {
            //error handling
            print("error recognizing text: \(error.localizedDescription)")
        }
        
    }
    
}

