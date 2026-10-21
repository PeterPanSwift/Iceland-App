import SwiftUI

@main
struct IcelandApp: App {
    @State private var favorites = FavoritesStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(favorites)
                .tint(Theme.accent)
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("探索", systemImage: "mountain.2.fill") { ExploreView() }
            Tab("地圖", systemImage: "map.fill") { MapScreen() }
            Tab("收藏", systemImage: "heart.fill") { FavoritesView() }
            Tab("資訊", systemImage: "info.circle.fill") { InfoView() }
        }
    }
}
