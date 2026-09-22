import Foundation

struct HanziStore {
    static let shared = HanziStore()

    let all: [HanziItem]

    private static let fallback: [HanziItem] = [
        HanziItem(id: 9001, character: "学习", pinyin: "xuéxí", pinyinNum: "xue2xi2", meaning: "Estudar / Aprender"),
        HanziItem(id: 9002, character: "你好", pinyin: "nǐ hǎo", pinyinNum: "ni3hao3", meaning: "Olá"),
        HanziItem(id: 9003, character: "谢谢", pinyin: "xièxie", pinyinNum: "xie4xie5", meaning: "Obrigado"),
        HanziItem(id: 9004, character: "中国", pinyin: "zhōngguó", pinyinNum: "zhong1guo2", meaning: "China"),
        HanziItem(id: 9005, character: "朋友", pinyin: "péngyou", pinyinNum: "peng2you5", meaning: "Amigo"),
        HanziItem(id: 9006, character: "水", pinyin: "shuǐ", pinyinNum: "shui3", meaning: "Água"),
    ]

    init() {
        all = Self.carregarDataset()
    }

    private static func carregarDataset() -> [HanziItem] {
        guard
            let url = Bundle.main.url(forResource: "hanzi", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let items = try? JSONDecoder().decode([HanziItem].self, from: data),
            !items.isEmpty
        else {
            return fallback
        }
        return items
    }

    func hanzi(for date: Date) -> HanziItem {
        guard !all.isEmpty else {
            return HanziItem(
                id: 0,
                character: "?",
                pinyin: "?",
                pinyinNum: "?",
                meaning: "sem dados"
            )
        }
        let dias = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        return all[dias % all.count]
    }

    func proximosDias(aPartirDe data: Date, quantidade: Int) -> [(Date, HanziItem)] {
        let cal = Calendar.current
        let inicio = cal.startOfDay(for: data)
        return (0..<quantidade).compactMap { offset in
            guard let d = cal.date(byAdding: .day, value: offset, to: inicio) else { return nil }
            return (d, hanzi(for: d))
        }
    }
}
