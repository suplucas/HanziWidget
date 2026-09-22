import Foundation

struct HanziItem: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let character: String
    let pinyin: String
    let pinyinNum: String
    let meaning: String
    let exemploHanzi: String?
    let exemploPinyin: String?
    let exemploTraducao: String?

    enum CodingKeys: String, CodingKey {
        case id
        case character = "hanzi"
        case pinyin
        case pinyinNum = "pinyin_num"
        case meaning = "traducao"
        case exemploHanzi = "exemplo_hanzi"
        case exemploPinyin = "exemplo_pinyin"
        case exemploTraducao = "exemplo_traducao"
    }

    init(
        id: Int,
        character: String,
        pinyin: String,
        pinyinNum: String,
        meaning: String,
        exemploHanzi: String? = nil,
        exemploPinyin: String? = nil,
        exemploTraducao: String? = nil
    ) {
        self.id = id
        self.character = character
        self.pinyin = pinyin
        self.pinyinNum = pinyinNum
        self.meaning = meaning
        self.exemploHanzi = exemploHanzi
        self.exemploPinyin = exemploPinyin
        self.exemploTraducao = exemploTraducao
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        character = try container.decode(String.self, forKey: .character)
        pinyin = try container.decode(String.self, forKey: .pinyin)
        pinyinNum = try container.decodeIfPresent(String.self, forKey: .pinyinNum) ?? pinyin
        meaning = try container.decode(String.self, forKey: .meaning)
        exemploHanzi = try container.decodeIfPresent(String.self, forKey: .exemploHanzi)
        exemploPinyin = try container.decodeIfPresent(String.self, forKey: .exemploPinyin)
        exemploTraducao = try container.decodeIfPresent(String.self, forKey: .exemploTraducao)
    }
}
