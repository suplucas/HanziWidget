import XCTest
@testable import HanziWidget

final class HanziItemDecodingTests: XCTestCase {
    func testDecodesSnakeCaseJSON() throws {
        let json = """
        {
          "id": 10,
          "hanzi": "好",
          "pinyin": "hǎo",
          "pinyin_num": "hao3",
          "traducao": "Bom",
          "exemplo_hanzi": "你好",
          "exemplo_pinyin": "nǐ hǎo",
          "exemplo_traducao": "Olá"
        }
        """.data(using: .utf8)!

        let item = try JSONDecoder().decode(HanziItem.self, from: json)
        XCTAssertEqual(item.id, 10)
        XCTAssertEqual(item.character, "好")
        XCTAssertEqual(item.pinyinNum, "hao3")
        XCTAssertEqual(item.meaning, "Bom")
        XCTAssertEqual(item.exemploHanzi, "你好")
    }

    func testDecodesWithoutExampleFields() throws {
        let json = """
        {"id": 1, "hanzi": "一", "pinyin": "yī", "pinyin_num": "yi1", "traducao": "um"}
        """.data(using: .utf8)!

        let item = try JSONDecoder().decode(HanziItem.self, from: json)
        XCTAssertNil(item.exemploHanzi)
        XCTAssertNil(item.exemploPinyin)
        XCTAssertNil(item.exemploTraducao)
    }

    func testPinyinNumFallsBackToPinyin() throws {
        let json = """
        {"id": 2, "hanzi": "的", "pinyin": "de", "traducao": "partícula"}
        """.data(using: .utf8)!

        let item = try JSONDecoder().decode(HanziItem.self, from: json)
        XCTAssertEqual(item.pinyinNum, "de")
    }
}
