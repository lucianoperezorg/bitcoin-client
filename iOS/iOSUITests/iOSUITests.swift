//
//  iOSUITests.swift
//  iOSUITests
//
//  Created by Luciano Perez on 07/12/2022.
//

import XCTest

final class iOSUITests: XCTestCase {

    func testNavigationThroughTheApp() throws {
        let app = XCUIApplication()
        app.launch()
        app.tables.element(boundBy: 0).cells.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.staticTexts["currenctPriceLabel"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
}
