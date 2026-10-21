import SwiftUI

struct FavoritesView: View {
    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        NavigationStack {
            Group {
                if favorites.places.isEmpty {
                    ContentUnavailableView(
                        "尚未收藏景點",
                        systemImage: "heart",
                        description: Text("在景點頁面點擊右上角的愛心，就能把喜歡的地方加入旅程清單。")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(favorites.places) { place in
                                NavigationLink(value: place) {
                                    PlaceRow(place: place)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("favorite_\(place.id)")
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("我的收藏")
            .navigationDestination(for: Place.self) { place in
                PlaceDetailView(place: place)
            }
        }
    }
}
