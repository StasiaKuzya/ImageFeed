//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Анастасия on 22.12.2023.
//

import XCTest
import WebKit

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        // тестируем сценарий авторизации
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("")
        webView.swipeUp()
        
        let webViewsQuery = app.webViews
        webViewsQuery.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        // тестируем сценарий ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["LikeButtom"].tap()
        cellToLike.buttons["LikeButtom"].tap()
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))
        
        cellToLike.tap()
        sleep(5)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButtonTap = app.buttons["BackButtonSingleView"]
        backButtonTap.tap()
    }
    
    func testProfile() throws {
        // тестируем сценарий профиля
        sleep(5)
        app.tabBars.buttons.element(boundBy: 1).tap()

        let userName = app.staticTexts["Anastasia Kuzina"].exists
        let userLogin = app.staticTexts["@stasiakuzya"].exists
        XCTAssertTrue(userName)
        XCTAssertTrue(userLogin)
        
        app.buttons["LogOutButton"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        sleep(5)
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.exists)
    }
}
