//remove background from image View UI and Functions
//NOTE: Vision works with CoreImage smoothly to create Mask (Vision) and Apply Mask (CoreImage) to remove background of the image

import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

struct RemoveBackgroundView: View {
    @State private var image = UIImage()
    @State private var undoStack: [UIImage] = []
    @State private var redoStack: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            VisionCardView(title: "Remove background"){
                ZStack{
                    HStack{
                        Button { //download image button
                            savePNGImage(image)
                            showingAlert = true
                        } label: {
                            Label("", systemImage: "square.and.arrow.down")
                                .font(.headline)
                        }
                        .alert("Image saved!", isPresented: $showingAlert) {
                            Button("OK") {
                            }
                            //alert pop up when image is saved
                        }
                        
                        Spacer()
                        Button {
                            showingImagePicker = true
                        } label: {
                            Label("", systemImage: "photo.badge.plus.fill")
                                .font(.headline)
                        } //photo library image picker button
                    }
                    .padding(.top, -60)
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
                    }
                    
                }
                .padding()
                //show image if an image is chosen, else show Tap to Upload interface
                if image.size.width > 0 {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
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
                    }//image picker shown when pressed on
                    .onTapGesture {
                        showingImagePicker = true
                    }
                }
                
                ZStack{
                    Button("Remove!!") {
                        removeBackground()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    HStack{
                        Button { //undo image button
                            undo()
                        } label: {
                            Label("", systemImage: "arrow.uturn.backward")
                                .font(.headline)
                        }
                        Spacer()
                        Button { //redo image button
                            redo()
                        } label: {
                            Label("", systemImage: "arrow.uturn.forward")
                                .font(.headline)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Vision")
    }
    
    private func undo() { //undo image function
        guard let lastImage = undoStack.popLast() else { return }
        redoStack.append(image)
        image = lastImage
    }
    
    private func redo(){ //redo image function
        guard let nextImage = redoStack.popLast() else { return }
        undoStack.append(image)
        image = nextImage
    }
    
    //unused function
    private func saveImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    } //auto saves as jpeg, not ideal for background removal, as saved photo will have a white background instead of transparent background
    
    private func savePNGImage(_ image: UIImage) {
        guard let pngData = image.pngData() else {
            print("Failed to convert to PNG")
            return
        }
        
        //  a temporary file URL
        let filename = UUID().uuidString + ".png"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try pngData.write(to: url)
            UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: url.path)!, nil, nil, nil)
        } catch {
            print("Failed to save PNG:", error)
        }
    }//saves image as a PNG to avoid loss of transparent background (jpeg does not support alpha/transparency)
    
    private func createMask(from inputImage: CIImage) -> CIImage? { //Vision framework
        
        //request generates an instance mask of noticable objects to separate from the background
        let request = VNGenerateForegroundInstanceMaskRequest()
        //call perform to execute Vision requests on image
        let handler = VNImageRequestHandler(ciImage: inputImage)
        
        do {
            try handler.perform([request])
            
            if let result = request.results?.first {
                let mask = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
                return CIImage(cvPixelBuffer: mask)
                //created mask
            }
        } catch {
            //error handling
            print(error)
        }
        
        return nil
    }
    
    private func applyMask(mask: CIImage, to image: CIImage) -> CIImage { //CoreImage framework
        let filter = CIFilter.blendWithMask() //blends 2 images together
        
        filter.inputImage = image //main image you uploaded
        filter.maskImage = mask //mask decides area of image that stays
        filter.backgroundImage = CIImage.empty() //area outside of the mask becomes transparent
        
        return filter.outputImage! //output is background-removed image
    }
    
    private func convertToUIImage(ciImage: CIImage) -> UIImage {
        //CoreImage framework only works with CIImage, hence a function to convert UIImage into CIImage
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {
            fatalError("Failed to render CGImage")
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func removeBackground() {
        guard let inputImage = CIImage(image: image) else {
            print("Failed to create CIImage")
            return
        } //image you uploaded
        
        Task {
            guard let maskImage = createMask(from: inputImage) else {
                print("Failed to create mask")
                return
            } //Vision detects and creates a Mask
            
            let outputImage = applyMask(mask: maskImage, to: inputImage) //CoreImage applies the mask, outputs image with removed background
            let finalImage = convertToUIImage(ciImage: outputImage) //CIImage converted back to UIImage for easy handling
            
            //undo and redo function handling
            undoStack.append(image)
            redoStack.removeAll()
            
            image = finalImage //update new image as image without background
        }
    }
    
}
