//
//  gridtokexiosUITests.swift
//  gridtokexiosUITests
//
//  Created by Chanthawat Kiriyadee on 20/6/2569 BE.
//

import XCTest

final class gridtokexiosUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testWelcomeToAppFlow() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UITEST"]
        app.launch()

        // 1 · Welcome — "Create account" appears after the launch sequence (~7s).
        let createAccount = app.buttons["Create account"]
        XCTAssertTrue(createAccount.waitForExistence(timeout: 20), "Welcome CTA missing")
        createAccount.tap()

        // 2 · Create account — fields prefilled with bypass creds; Continue advances.
        let continueBtn = app.buttons["Continue"]
        XCTAssertTrue(continueBtn.waitForExistence(timeout: 10), "Create-account screen missing")
        XCTAssertTrue(app.staticTexts["Create your account"].exists, "Create-account title missing")
        continueBtn.tap()

        // 3 · Verify email — code prefilled with bypass; Verify advances.
        let verifyBtn = app.buttons["Verify"]
        XCTAssertTrue(verifyBtn.waitForExistence(timeout: 10), "Verify screen missing")
        XCTAssertTrue(app.staticTexts["Check your email"].exists, "Verify title missing")
        verifyBtn.tap()

        // 4 · Profile + role — name prefilled, role preselected; Continue advances.
        let profileContinue = app.buttons["Continue"]
        XCTAssertTrue(profileContinue.waitForExistence(timeout: 10), "Profile screen missing")
        XCTAssertTrue(app.staticTexts["Tell us about you"].exists, "Profile title missing")
        profileContinue.tap()

        // 5 · Success — confirmation, then enter the app.
        let enter = app.buttons["Enter GridTokenX"]
        XCTAssertTrue(enter.waitForExistence(timeout: 10), "Success screen missing")
        XCTAssertTrue(app.staticTexts["You're all set"].exists, "Success title missing")
        enter.tap()

        // 6 · Dashboard — landing after login proves the flow completed.
        let earned = app.staticTexts["You earned today"]
        XCTAssertTrue(earned.waitForExistence(timeout: 10), "Did not reach dashboard")
        XCTAssertTrue(app.buttons["Sell my energy"].exists, "Dashboard action missing")
    }

    @MainActor
    func testBackFromCreateAccountReturnsToWelcome() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UITEST"]
        app.launch()

        let createAccount = app.buttons["Create account"]
        XCTAssertTrue(createAccount.waitForExistence(timeout: 30))
        createAccount.tap()

        let back = app.buttons["BackButton"]
        XCTAssertTrue(back.waitForExistence(timeout: 20), "Back chevron missing")
        back.tap()

        XCTAssertTrue(app.buttons["Create account"].waitForExistence(timeout: 20), "Did not return to Welcome")
    }

    // MARK: - 06 · Dashboard (live)

    @MainActor
    func testLiveDashboardRenders() throws {
        let app = XCUIApplication()
        app.launchArguments += ["SHOW_LIVE"]
        app.launch()

        XCTAssertTrue(app.staticTexts["GRX/THB"].waitForExistence(timeout: 10), "Live dashboard header missing")
        XCTAssertTrue(app.buttons["Trade"].exists, "Trade tab missing")
        XCTAssertTrue(app.buttons["Market"].exists, "Market tab missing")
        XCTAssertTrue(app.buttons["Buy"].exists && app.buttons["Sell"].exists && app.buttons["DCA"].exists,
                      "Side segment missing")
    }

    @MainActor
    func testLiveDashboardSideSwitchUpdatesCTA() throws {
        let app = XCUIApplication()
        app.launchArguments += ["SHOW_LIVE"]
        app.launch()

        // SHOW_LIVE defaults to Buy → sticky CTA reads "Buy … kWh …".
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS 'kWh'")).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 10), "CTA missing")
        XCTAssertTrue(cta.label.hasPrefix("Buy"), "CTA should start as Buy, got \(cta.label)")

        // Switch to Sell → CTA flips to "Sell …".
        app.buttons["Sell"].tap()
        let sellCTA = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Sell' AND label CONTAINS 'kWh'")).firstMatch
        XCTAssertTrue(sellCTA.waitForExistence(timeout: 5), "CTA did not switch to Sell")
    }

    @MainActor
    func testLiveDashboardMarketTab() throws {
        let app = XCUIApplication()
        app.launchArguments += ["SHOW_LIVE"]
        app.launch()

        XCTAssertTrue(app.buttons["Market"].waitForExistence(timeout: 10), "Market tab missing")
        app.buttons["Market"].tap()
        XCTAssertTrue(app.staticTexts["P2P trade feed"].waitForExistence(timeout: 5), "Market feed missing")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
