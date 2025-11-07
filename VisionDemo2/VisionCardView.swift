// UI view of cards
import SwiftUI

struct VisionCardView<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()
            content
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
    
}

