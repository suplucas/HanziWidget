import SwiftUI

struct DictionaryView: View {
    private let store = HanziStore.shared
    @State private var query = ""

    private var filtered: [HanziItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return store.all }

        let needle = trimmed.lowercased()
        let needleFolded = trimmed
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "zh"))
            .lowercased()

        return store.all.filter { item in
            if item.character.contains(trimmed) { return true }
            if item.meaning.localizedCaseInsensitiveContains(trimmed) { return true }

            let pinyin = item.pinyin
                .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "zh"))
                .lowercased()
            if pinyin.contains(needleFolded) || pinyin.contains(needle) { return true }
            if item.pinyinNum.lowercased().contains(needle) { return true }

            if let ex = item.exemploHanzi, ex.contains(trimmed) { return true }
            if let ex = item.exemploTraducao, ex.localizedCaseInsensitiveContains(trimmed) { return true }
            if let ex = item.exemploPinyin {
                let folded = ex
                    .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "zh"))
                    .lowercased()
                if folded.contains(needleFolded) || folded.contains(needle) { return true }
            }
            return false
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { item in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 16) {
                        Text(item.character)
                            .font(.system(size: 32, weight: .bold))
                            .frame(width: 70, alignment: .center)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.pinyin)
                                .font(.headline)
                                .foregroundStyle(.blue)
                            Text(item.meaning)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
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
            }
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        "Nada encontrado",
                        systemImage: "magnifyingglass",
                        description: Text("Tente outro hanzi, pinyin ou significado.")
                    )
                }
            }
            .navigationTitle("Dicionário")
            .searchable(text: $query, prompt: "Buscar hanzi, pinyin ou significado")
        }
    }
}
