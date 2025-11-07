//image picker, responsible for photo library for you to choose photos
//NOTE: This app uses UIKit's photo picker -- UIImagePickerController, you may also use SwiftUI's photo picker -- PHPicker (only applicable for iOS 14+)

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode //allows SwiftUI to dismiss the photo picker sheet when done
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator //UIKit uses delegates to report selected image, while SwiftUI uses closures and bindings, hence coordinator is necessary for SwiftUI to recevie delegate callbacks
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            } //image chosen from photo picker
            
            parent.presentationMode.wrappedValue.dismiss()
            //image picker sheet is dismissed
        }
    }
}
