import SwiftUI

struct DictionaryView: View {
    @Environment(\.hanziStore) private var store
    @Environment(\.modelContext) private var modelContext

    @State private var query = ""
    @State private var favorites: Set<Int> = []
    @State private var showFavoritesOnly = false

    private var filtered: [HanziItem] {
        let base = showFavoritesOnly
            ? store.all.filter { favorites.contains($0.id) }
            : store.all
        let result = store.filtered(query)
        if showFavoritesOnly {
            let ids = Set(result.map(\.id))
            return base.filter { ids.contains($0.id) }
        }
        return result
    }

    private var repository: ReviewRepository {
        ReviewRepository(context: modelContext)
    }

    var body: some View {
        NavigationStack {
            List(filtered) { item in
                row(for: item)
            }
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        showFavoritesOnly && query.isEmpty ? "Sem favoritos" : "Nada encontrado",
                        systemImage: showFavoritesOnly && query.isEmpty ? "star" : "magnifyingglass",
                        description: Text(
                            showFavoritesOnly && query.isEmpty
                                ? "Marque estrela nos cards para salvar aqui."
                                : "Tente outro hanzi, pinyin ou significado."
                        )
                    )
                }
            }
            .navigationTitle("Dicionário")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFavoritesOnly.toggle()
                        refresh()
                    } label: {
                        Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                    }
                    .accessibilityIdentifier("favorites_filter")
                }
            }
            .searchable(text: $query, prompt: "Buscar hanzi, pinyin ou significado")
            .onAppear(perform: refresh)
            .onChange(of: modelContext.hasChanges) { _, hasChanges in
                if hasChanges { refresh() }
            }
        }
    }

    private func refresh() {
        favorites = repository.favoriteIDs()
    }

    private func row(for item: HanziItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 16) {
                Text(item.character)
                    .font(.system(size: 32, weight: .bold))
                    .frame(width: 70, alignment: .center)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.pinyin)
                            .font(.headline)
                            .foregroundStyle(.blue)
                        if favorites.contains(item.id) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                        }
                    }
                    Text(item.meaning)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    SpeechService.shared.speakHanzi(item)
                } label: {
                    Image(systemName: "speaker.wave.2")
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("dictionary_speak_\(item.id)")
            }

            if let exHanzi = item.exemploHanzi {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(exHanzi)
                            .font(.subheadline.weight(.medium))
                        if let exPinyin = item.exemploPinyin {
                            Text(exPinyin)
                                .font(.caption)
                                .foregroundStyle(.blue.opacity(0.8))
                        }
                    }
                    if let exTraducao = item.exemploTraducao {
                        Text(exTraducao)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.leading, 86)
            }
        }
        .padding(.vertical, 4)
        .accessibilityIdentifier("dictionary_row_\(item.id)")
    }
}
