import Foundation

struct HanziStore {
    static let shared = HanziStore()

    let all: [HanziItem] = [
        HanziItem(character: "学习", pinyin: "xuéxí", meaning: "Estudar / Aprender"),
        HanziItem(character: "你好", pinyin: "nǐ hǎo", meaning: "Olá"),
        HanziItem(character: "谢谢", pinyin: "xièxie", meaning: "Obrigado"),
        HanziItem(character: "中国", pinyin: "zhōngguó", meaning: "China"),
        HanziItem(character: "朋友", pinyin: "péngyou", meaning: "Amigo"),
        HanziItem(character: "水", pinyin: "shuǐ", meaning: "Água")
    ]

    func hanzi(for date: Date) -> HanziItem {
        guard !all.isEmpty else {
            return HanziItem(character: "?", pinyin: "?", meaning: "sem dados")
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
