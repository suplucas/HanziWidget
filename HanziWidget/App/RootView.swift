import SwiftData
import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HanziCarouselView()
                .tabItem {
                    Label("Carrossel", systemImage: "rectangle.stack")
                }
                .accessibilityIdentifier("tab_carousel")

            PracticeView()
                .tabItem {
                    Label("Prática", systemImage: "brain.head.profile")
                }
                .accessibilityIdentifier("tab_practice")

            DictionaryView()
                .tabItem {
                    Label("Dicionário", systemImage: "book")
                }
                .accessibilityIdentifier("tab_dictionary")
        }
    }
}
