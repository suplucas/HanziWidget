import Foundation

struct HanziItem: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let character: String
    let pinyin: String
    let meaning: String

    init(id: UUID = UUID(), character: String, pinyin: String, meaning: String) {
        self.id = id
        self.character = character
        self.pinyin = pinyin
        self.meaning = meaning
    }
}
