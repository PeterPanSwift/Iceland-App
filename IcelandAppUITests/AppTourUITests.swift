import XCTest

/// Drives a scripted tour through the app while `simctl io recordVideo` captures the screen.
/// The tour writes wall-clock marks to `MARKS_PATH` so the recording can be trimmed to
/// just the in-app part afterwards.
final class AppTourUITests: AppUITestCase {
    private var marks: [String: Double] = [:]

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
