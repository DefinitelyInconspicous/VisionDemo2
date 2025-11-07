//recognize text View UI
import SwiftUI
import Combine

struct PhotoTextRecognitionView: View {
    @ObservedObject var recognizeText: RecognizeText
    @Binding var selectedImage: UIImage
    @State private var showingImagePicker = false
    
    var body: some View {
        VisionCardView(title: "Upload Photo") {
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button {
                        showingImagePicker = true
                    } label: {
                        Image(systemName: "photo.badge.plus.fill")
                            .font(.headline)
                    } // Upload image button, photolibrary
                }
                .padding(.top, -60)
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
                }
                //if image is selected, show image, else, display "Tap to Upload" interface
                if selectedImage.size.width > 0 {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 180)
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 36))
                                .foregroundColor(.gray)
                            Text("Tap to upload")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        .onTapGesture { showingImagePicker = true }
                    }//imagePicker, photolibrary when clicked on
                }
                
                // Detect text button, contains visionManager's recognize Text
                Button {
                    Task {
                        guard let data = selectedImage.pngData() else { return }
                        await recognizeText.recognizeText(data: data)
                    }
                } label: {
                    Label("Detect Text", systemImage: "text.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                //display text recognition result
                if !recognizeText.resultStrings.isEmpty {
                    ScrollView {
                        Text("Result: \(recognizeText.resultStrings.joined(separator: " "))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 60)
                }
            }
            .padding()
        }
    }
}
