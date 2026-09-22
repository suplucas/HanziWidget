import XCTest

final class HanziWidgetUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCarouselShowsTitleAndCounter() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["carousel_title"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH '1/'")
        ).firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["progress_counter"].waitForExistence(timeout: 5))
    }

    func testDictionarySearchFindsMeaning() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Dicionário"].tap()

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("água")

        XCTAssertTrue(app.staticTexts["água"].firstMatch.waitForExistence(timeout: 5))
    }

    func testPracticeTabOpens() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Prática"].tap()
        XCTAssertTrue(
            app.staticTexts["Prática"].waitForExistence(timeout: 5)
                || app.staticTexts["Qual o significado?"].waitForExistence(timeout: 5)
                || app.staticTexts["Fila vazia"].waitForExistence(timeout: 5)
        )
    }
}
