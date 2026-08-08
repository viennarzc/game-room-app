import XCTest
import UIKit

@MainActor
final class GameRoomUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testOnboardingCanReachTheJournal() throws {
    let app = XCUIApplication()
    app.launchArguments = ["--ui-testing"]
    app.launch()

    completeOnboarding(in: app)

    XCTAssertTrue(app.navigationBars["Memory"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["Your gaming memories start here"].exists)
  }

  func testCollectibleGalleryShowsBuiltInArtwork() throws {
    let app = XCUIApplication()
    app.launchArguments = ["--ui-testing"]
    app.launch()

    completeOnboarding(in: app)

    app.tabBars.buttons["Settings"].tap()
    let gallery = app.staticTexts["Collectible Gallery"]
    XCTAssertTrue(gallery.waitForExistence(timeout: 5))
    gallery.tap()

    let starterCollection = app.staticTexts["Essential Collection"]
    XCTAssertTrue(starterCollection.waitForExistence(timeout: 5))
    starterCollection.tap()

    XCTAssertTrue(app.staticTexts["Controller Eight Bit Rectangular"].waitForExistence(timeout: 5))
    let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
    attachment.name = "Collectible Gallery"
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  func testIPadUsesSidebarNavigation() throws {
    try XCTSkipUnless(
      UIDevice.current.userInterfaceIdiom == .pad,
      "This navigation layout applies only to iPad."
    )

    let app = XCUIApplication()
    app.launchArguments = ["--ui-testing"]
    app.launch()

    completeOnboarding(in: app)

    let shelf = app.staticTexts["Shelf"].firstMatch
    XCTAssertTrue(shelf.waitForExistence(timeout: 5))
    shelf.tap()

    XCTAssertTrue(app.navigationBars["Shelf"].waitForExistence(timeout: 5))
    let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
    attachment.name = "iPad Sidebar Navigation"
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  private func completeOnboarding(in app: XCUIApplication) {
    XCTAssertTrue(app.staticTexts["A shelf for your gaming life"].waitForExistence(timeout: 5))
    for _ in 0..<4 {
      app.buttons["Continue"].tap()
    }
    app.buttons["Enter Game Room"].tap()
  }
}
