import XCTest

@MainActor
final class GameRoomUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testOnboardingCanReachTheJournal() throws {
    let app = XCUIApplication()
    app.launchArguments = ["--ui-testing"]
    app.launch()

    XCTAssertTrue(app.staticTexts["A shelf for your gaming life"].waitForExistence(timeout: 5))
    for _ in 0..<4 {
      app.buttons["Continue"].tap()
    }
    app.buttons["Enter Game Room"].tap()

    XCTAssertTrue(app.navigationBars["Memory"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["Your gaming memories start here"].exists)
  }
}
