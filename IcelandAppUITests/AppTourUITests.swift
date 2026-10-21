import XCTest

/// Drives a scripted tour through the app while `simctl io recordVideo` captures the screen.
/// The tour writes wall-clock marks to `MARKS_PATH` so the recording can be trimmed to
/// just the in-app part afterwards.
final class AppTourUITests: XCTestCase {
    private var app: XCUIApplication!
    private var marks: [String: Double] = [:]

    override func setUp() {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hant)", "-AppleLocale", "zh_TW"]
    }

    func testAppTour() {
        app.launch()
        XCTAssertTrue(app.staticTexts["冰與火之國"].waitForExistence(timeout: 20))
        pause(1.0)
        mark("start")
        pause(2.5)

        // Explore: featured carousel
        let carousel = app.scrollViews["featuredCarousel"]
        if carousel.waitForExistence(timeout: 5) {
            carousel.swipeLeft(velocity: .slow)
            pause(1.4)
            carousel.swipeLeft(velocity: .slow)
            pause(1.4)
        }

        // Scroll to the category chips and filter waterfalls
        scroll(0.42)
        pause(1.2)
        let waterfalls = element("category_waterfall")
        scrollUntilVisible(waterfalls)
        tapIfPossible(waterfalls)
        pause(1.6)

        // Open Skógafoss
        let skogafoss = element("place_skogafoss")
        scrollUntilVisible(skogafoss)
        pause(0.8)
        tapIfPossible(skogafoss)
        pause(2.5)

        // Detail page
        scroll(0.4)
        pause(1.8)
        scroll(0.4)
        pause(1.8)
        scroll(0.45)
        pause(1.5)
        tapIfPossible(element("favoriteButton"))
        pause(1.5)
        scroll(-0.9)
        pause(1.2)
        goBack()
        pause(1.5)

        // Reset filter and look at the full list
        tapIfPossible(element("category_all"))
        pause(1.2)
        scroll(0.35)
        pause(1.5)

        // Map tab
        tapTab("地圖")
        pause(4.0)
        tapIfPossible(element("mapcard_jokulsarlon"))
        pause(4.5)
        tapIfPossible(element("mapcard_kirkjufell"))
        pause(4.5)
        tapIfPossible(element("mapOverview"))
        pause(3.0)

        // Favorites tab
        tapTab("收藏")
        pause(2.5)

        // Info tab
        tapTab("資訊")
        pause(2.0)
        scroll(0.4)
        pause(1.8)
        scroll(0.4)
        pause(1.8)
        scroll(0.5)
        pause(2.0)

        mark("end")
    }

    // MARK: - Helpers

    private func element(_ identifier: String) -> XCUIElement {
        app.buttons[identifier].firstMatch
    }

    private func pause(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }

    private var window: XCUIElement { app.windows.firstMatch }

    /// Positive fraction scrolls content up (reveals content below).
    private func scroll(_ fraction: CGFloat) {
        let startY: CGFloat = fraction > 0 ? 0.72 : 0.25
        let endY = startY - fraction
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: startY))
        let end = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: endY))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: 900, thenHoldForDuration: 0.15)
    }

    private func isVisible(_ element: XCUIElement) -> Bool {
        guard element.exists, element.isHittable else { return false }
        let frame = element.frame
        let height = window.frame.height
        return frame.minY > height * 0.08 && frame.maxY < height * 0.84
    }

    private func scrollUntilVisible(_ element: XCUIElement, maxScrolls: Int = 8) {
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

    private func tapIfPossible(_ element: XCUIElement) {
        if element.waitForExistence(timeout: 5), element.isHittable {
            element.tap()
        } else {
            XCTFail("Could not tap \(element)")
        }
    }

    private func tapTab(_ label: String) {
        let tabButton = app.tabBars.buttons[label]
        if tabButton.waitForExistence(timeout: 3) {
            tabButton.tap()
        } else {
            tapIfPossible(app.buttons[label].firstMatch)
        }
    }

    private func goBack() {
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

    private func mark(_ name: String) {
        let now = Date().timeIntervalSince1970
        marks[name] = now
        print("TOUR_MARK \(name)=\(now)")
        guard let path = ProcessInfo.processInfo.environment["MARKS_PATH"],
              let data = try? JSONSerialization.data(withJSONObject: marks, options: [.prettyPrinted, .sortedKeys])
        else { return }
        try? data.write(to: URL(fileURLWithPath: path))
    }
}
