import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            Tab("Image", systemImage: "photo"){
                NavigationStack{
                    RemoveBackgroundView()
                }
            }
            Tab("Text", systemImage: "text.viewfinder") {
                NavigationStack{
                    TextTranslateView()
                }
            }
        }
    }
}
