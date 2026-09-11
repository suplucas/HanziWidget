import SwiftUI

struct ContentView: View {
    private let store = HanziStore.shared

    var body: some View {
        NavigationStack {
            List(store.all) { item in
                HStack(spacing: 16) {
                    Text(item.character)
                        .font(.system(size: 32, weight: .bold))
                        .frame(width: 70, alignment: .center)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.pinyin)
                            .font(.headline)
                            .foregroundColor(.blue)
                        Text(item.meaning)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Palavras Hanzi")
        }
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
