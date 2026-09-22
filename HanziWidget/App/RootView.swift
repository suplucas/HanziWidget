import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HanziCarouselView()
                .tabItem {
                    Label("Carrossel", systemImage: "rectangle.stack")
                }

            DictionaryView()
                .tabItem {
                    Label("Dicionário", systemImage: "book")
                }
        }
    }
}
