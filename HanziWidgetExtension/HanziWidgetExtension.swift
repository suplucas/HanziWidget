import WidgetKit
import SwiftUI

// MARK: - Entry

struct HanziEntry: TimelineEntry {
    let date: Date
    let hanzi: HanziItem
}

// MARK: - Provider

struct HanziProvider: TimelineProvider {
    func placeholder(in context: Context) -> HanziEntry {
        HanziEntry(
            date: Date(),
            hanzi: HanziItem(id: 0, character: "好", pinyin: "hǎo", pinyinNum: "hao3", meaning: "Bom")
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HanziEntry) -> Void) {
        let hoje = HanziStore.shared.hanzi(for: Date())
        completion(HanziEntry(date: Date(), hanzi: hoje))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HanziEntry>) -> Void) {
        let proximos = HanziStore.shared.proximosDias(aPartirDe: Date(), quantidade: 7)
        let entries = proximos.map { HanziEntry(date: $0.0, hanzi: $0.1) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: - View

struct HanziWidgetEntryView: View {
    var entry: HanziEntry
    @Environment(\.widgetFamily) var family // <-- Adicione esta linha

    var body: some View {
        switch family {
        case .accessoryRectangular:
            // Layout para o widget retangular da tela de bloqueio
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.hanzi.character)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(entry.hanzi.pinyin)
                    .font(.caption)
                Text(entry.hanzi.meaning)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        case .accessoryCircular:
            // Layout para o widget circular
            Gauge(value: 0.7) { // Exemplo de um medidor, pode ser um ícone ou texto
                Text(entry.hanzi.character)
                    .font(.title2)
            }
            .gaugeStyle(.accessoryCircularCapacity)
        case .accessoryInline:
            // Layout para o widget de uma linha
            Text("\(entry.hanzi.character) \(entry.hanzi.pinyin)")
        default:
            // Layout original para a tela inicial
            VStack(spacing: 6) {
                Text(entry.hanzi.character)
                    .font(.system(size: 56, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(entry.hanzi.pinyin)
                    .font(.headline)
                    .foregroundStyle(.blue)
                Text(entry.hanzi.meaning)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding()
        }
    }
}

// MARK: - Widget

struct HanziWidgetExtension: Widget {
    let kind: String = "HanziWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HanziProvider()) { entry in
            // A view do seu widget agora é envolvida pelo containerBackground
            HanziWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    // Define o fundo como o padrão do sistema para widgets.
                    // Isso resolve o erro e se adapta a todos os tamanhos (Tela de Início e Bloqueio).
                    Color.clear
                }
        }
        .configurationDisplayName("Hanzi do Dia")
        .description("Mostra um hanzi diferente a cada dia.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline
        ])
    }
}
