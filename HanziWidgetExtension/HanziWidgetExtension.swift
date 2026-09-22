import SwiftUI
import WidgetKit

struct HanziEntry: TimelineEntry {
    let date: Date
    let hanzi: HanziItem
}

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

struct HanziWidgetEntryView: View {
    var entry: HanziEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            lockscreenRectangular
        case .accessoryCircular:
            lockscreenCircular
        case .accessoryInline:
            Text("\(entry.hanzi.character) · \(entry.hanzi.pinyin)")
                .font(.caption)
                .widgetAccentable()
        case .systemMedium:
            systemMedium
        default:
            systemSmall
        }
    }

    private var systemSmall: some View {
        VStack(spacing: 6) {
            Text(entry.hanzi.character)
                .font(.system(size: 52, weight: .bold))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .widgetAccentable()
            Text(entry.hanzi.pinyin)
                .font(.headline)
                .foregroundStyle(.blue)
            Text(entry.hanzi.meaning)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var systemMedium: some View {
        HStack(spacing: 16) {
            Text(entry.hanzi.character)
                .font(.system(size: 56, weight: .bold))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .widgetAccentable()

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.hanzi.pinyin)
                    .font(.headline)
                    .foregroundStyle(.blue)
                Text(entry.hanzi.meaning)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(4)
        .accessibilityElement(children: .combine)
    }

    private var lockscreenRectangular: some View {
        HStack(spacing: 8) {
            Text(entry.hanzi.character)
                .font(.headline.weight(.bold))
                .widgetAccentable()
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.hanzi.pinyin)
                    .font(.caption)
                Text(entry.hanzi.meaning)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var lockscreenCircular: some View {
        Gauge(value: 1.0) {
            Text(entry.hanzi.character)
                .font(.title2.weight(.bold))
                .widgetAccentable()
        } currentValueLabel: {
            Text(entry.hanzi.pinyin)
                .font(.system(size: 8, weight: .medium))
                .minimumScaleFactor(0.5)
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .accessibilityLabel("\(entry.hanzi.character), \(entry.hanzi.pinyin)")
    }
}

struct HanziWidgetExtension: Widget {
    let kind = "HanziWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HanziProvider()) { entry in
            HanziWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        }
        .configurationDisplayName("Hanzi do Dia")
        .description("Um hanzi novo todos os dias na sua tela.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline,
        ])
    }
}
