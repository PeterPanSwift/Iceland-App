import XCTest

/// Shared setup and gesture helpers for the UI tests that drive the app on camera.
class AppUITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hant)", "-AppleLocale", "zh_TW"]
    }

    func element(_ identifier: String) -> XCUIElement {
        app.buttons[identifier].firstMatch
    }

    func pause(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }

    var window: XCUIElement { app.windows.firstMatch }

    /// Positive fraction scrolls content up (reveals content below).
    func scroll(_ fraction: CGFloat) {
        let startY: CGFloat = fraction > 0 ? 0.72 : 0.25
        let endY = startY - fraction
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: startY))
        let end = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: endY))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: 900, thenHoldForDuration: 0.15)
    }

    func isVisible(_ element: XCUIElement) -> Bool {
        guard element.exists, element.isHittable else { return false }
        let frame = element.frame
        let height = window.frame.height
        return frame.minY > height * 0.08 && frame.maxY < height * 0.84
    }

    func scrollUntilVisible(_ element: XCUIElement, maxScrolls: Int = 8) {
        var attempts = 0
        while !isVisible(element) && attempts < maxScrolls {
            if element.exists, element.frame.minY < window.frame.height * 0.08 {
                scroll(-0.2)
            } else {
                scroll(0.25)
            }
            pause(0.6)
            attempts += 1
        }
    }

    func tapIfPossible(_ element: XCUIElement) {
        if element.waitForExistence(timeout: 5), element.isHittable {
            element.tap()
        } else {
            XCTFail("Could not tap \(element)")
        }
    }

    func tapTab(_ label: String) {
        let tabButton = app.tabBars.buttons[label]
        if tabButton.waitForExistence(timeout: 3) {
            tabButton.tap()
        } else {
            tapIfPossible(app.buttons[label].firstMatch)
        }
    }

    func goBack() {
        let back = app.navigationBars.buttons["BackButton"]
        if back.exists {
            back.tap()
            return
        }
        let first = app.navigationBars.buttons.element(boundBy: 0)
        if first.exists, first.identifier != "favoriteButton" {
            first.tap()
        } else {
            let edge = window.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
            edge.press(forDuration: 0.05, thenDragTo: window.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5)))
        }
    }
}
