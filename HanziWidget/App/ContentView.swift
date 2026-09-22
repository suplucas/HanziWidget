import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        RootView()
            .environment(\.hanziStore, HanziStore.shared)
            .modelContainer(for: ReviewState.self)
    }
}

@main
struct HanziWidgetAppMain: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
