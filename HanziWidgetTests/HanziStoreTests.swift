import Foundation
import Testing
@testable import HanziWidget

struct HanziStoreTests {
    private func makeStore() -> HanziStore {
        HanziStore(all: [
            HanziItem(
                id: 1,
                character: "水",
                pinyin: "shuǐ",
                pinyinNum: "shui3",
                meaning: "Água",
                exemploHanzi: "喝水",
                exemploPinyin: "hē shuǐ",
                exemploTraducao: "Beber água"
            ),
            HanziItem(
                id: 2,
                character: "火",
                pinyin: "huǒ",
                pinyinNum: "huo3",
                meaning: "Fogo"
            ),
            HanziItem(
                id: 3,
                character: "学习",
                pinyin: "xuéxí",
                pinyinNum: "xue2xi2",
                meaning: "Estudar"
            ),
        ])
    }

    @Test
    func datasetLoadsFromBundle() {
        let store = HanziStore()
        #expect(store.all.count == 300)
        #expect(store.all.first?.id == 1)
    }

    @Test
    func fallbackWhenBundleMissing() {
        let store = HanziStore(bundle: Bundle(for: HanziStoreTestsProbe.self))
        #expect(!store.all.isEmpty)
        #expect(store.all.allSatisfy { $0.id >= 9000 })
    }

    @Test
    func itemByID() {
        let store = makeStore()
        #expect(store.item(id: 2)?.character == "火")
        #expect(store.item(id: 999) == nil)
    }

    @Test
    func searchByHanzi() {
        let store = makeStore()
        let result = store.filtered("水")
        #expect(result.map(\.id) == [1])
    }

    @Test
    func searchByPinyinWithoutTones() {
        let store = makeStore()
        #expect(store.filtered("shui3").map(\.id) == [1])
        #expect(store.filtered("xuexi").map(\.id) == [3])
    }

    @Test
    func searchByMeaning() {
        let store = makeStore()
        #expect(store.filtered("fogo").map(\.id) == [2])
        #expect(store.filtered("Fogo").map(\.id) == [2])
    }

    @Test
    func searchByExample() {
        let store = makeStore()
        #expect(store.filtered("beber água").map(\.id) == [1])
    }

    @Test
    func emptyQueryReturnsAll() {
        let store = makeStore()
        #expect(store.filtered("   ").count == 3)
    }

    @Test
    func hanziForDateIsStable() {
        let store = makeStore()
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        #expect(store.hanzi(for: date).id == store.hanzi(for: date).id)
    }

    @Test
    func proximosDiasCount() {
        let store = makeStore()
        let items = store.proximosDias(aPartirDe: Date(), quantidade: 7)
        #expect(items.count == 7)
    }
}

private final class HanziStoreTestsProbe {}
