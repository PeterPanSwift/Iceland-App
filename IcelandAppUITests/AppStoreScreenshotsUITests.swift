import XCTest

/// Captures the App Store screenshots at the simulator's native resolution.
/// PNGs are written to `SCREENSHOTS_DIR` (and attached to the test result as a fallback).
final class AppStoreScreenshotsUITests: AppUITestCase {
    func testCaptureScreenshots() {
        app.launch()
        XCTAssertTrue(app.staticTexts["冰與火之國"].waitForExistence(timeout: 20))
        pause(2.0)
        snap("01-explore")

        // Jökulsárlón detail page, marked as favorite
        let glacier = element("category_glacier")
        scrollUntilVisible(glacier)
        tapIfPossible(glacier)
        pause(1.0)
        let lagoon = element("place_jokulsarlon")
        scrollUntilVisible(lagoon)
        tapIfPossible(lagoon)
        pause(2.0)
        tapIfPossible(element("favoriteButton"))
        pause(1.5)
        snap("02-detail")
        goBack()
        pause(1.5)

        // Waterfall list
        tapIfPossible(element("category_waterfall"))
        pause(1.0)
        alignChipsToTop()
        pause(1.5)
        snap("03-waterfalls")

        // Add a couple more favorites for the favorites screen
        for id in ["skogafoss", "gullfoss"] {
            let row = element("place_\(id)")
            scrollUntilVisible(row)
            tapIfPossible(row)
            pause(1.5)
            tapIfPossible(element("favoriteButton"))
            pause(0.8)
            goBack()
            pause(1.2)
        }

        // Map flying to Kirkjufell in 3D
        tapTab("地圖")
        pause(3.0)
        tapIfPossible(element("mapcard_kirkjufell"))
        pause(9.0)
        snap("04-map")

        tapTab("收藏")
        pause(2.0)
        snap("05-favorites")

        tapTab("資訊")
        pause(2.0)
        snap("06-info")
    }

    /// Scrolls so the category chips sit just under the status bar.
    private func alignChipsToTop() {
        let chip = element("category_all")
        for _ in 0..<6 where chip.exists {
            let target = window.frame.height * 0.08
            let delta = (chip.frame.minY - target) / window.frame.height
            if abs(delta) < 0.03 { break }
            scroll(max(min(delta, 0.5), -0.5))
            pause(0.6)
        }
    }

    private func snap(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        guard let dir = ProcessInfo.processInfo.environment["SCREENSHOTS_DIR"] else { return }
        let url = URL(fileURLWithPath: dir).appendingPathComponent("\(name).png")
        do {
            try shot.pngRepresentation.write(to: url)
        } catch {
            XCTFail("Could not write \(url.path): \(error)")
        }
    }
}
