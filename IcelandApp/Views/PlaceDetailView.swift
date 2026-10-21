import MapKit
import SwiftUI

struct PlaceDetailView: View {
    let place: Place
    @Environment(FavoritesStore.self) private var favorites

    private var isFavorite: Bool { favorites.contains(place) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header

                VStack(alignment: .leading, spacing: 24) {
                    titleBlock
                    Text(place.description)
                        .font(.body)
                        .lineSpacing(6)
                    highlights
                    infoCards
                    locationMap
                    credit
                }
                .padding(20)
                .padding(.top, 4)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.snappy) { favorites.toggle(place) }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .primary)
                        .symbolEffect(.bounce, value: isFavorite)
                }
                .accessibilityLabel(isFavorite ? "取消收藏" : "收藏")
                .accessibilityIdentifier("favoriteButton")
            }
        }
    }

    private var header: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .scrollView).minY
            PlacePhoto(id: place.id, category: place.category)
                .frame(width: geo.size.width, height: geo.size.height + max(0, minY))
                .overlay {
                    LinearGradient(colors: [.black.opacity(0.3), .clear, .clear], startPoint: .top, endPoint: .bottom)
                }
                .offset(y: -max(0, minY))
        }
        .frame(height: 440)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(place.localName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(place.name)
                .font(.largeTitle.weight(.bold))
            Text(place.summary)
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Tag(text: place.category.title, symbol: place.category.symbol, color: place.category.color)
                Tag(text: place.region, symbol: "mappin.and.ellipse", color: Theme.accent)
            }
            .padding(.top, 4)
        }
    }

    private var highlights: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("必看亮點")
                .font(.title3.weight(.bold))
            ForEach(place.highlights, id: \.self) { item in
                Label {
                    Text(item)
                } icon: {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(place.category.color)
                }
                .font(.body)
            }
        }
    }

    private var infoCards: some View {
        HStack(spacing: 12) {
            InfoCard(title: "最佳季節", value: place.bestSeason, symbol: "calendar")
            InfoCard(
                title: "座標",
                value: String(format: "%.2f°N  %.2f°W", place.latitude, -place.longitude),
                symbol: "location.fill"
            )
        }
    }

    private var locationMap: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("位置")
                .font(.title3.weight(.bold))
            Map(initialPosition: .region(MKCoordinateRegion(
                center: place.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 1.2, longitudeDelta: 2.4)
            ))) {
                Marker(place.name, systemImage: place.category.symbol, coordinate: place.coordinate)
                    .tint(place.category.color)
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private var credit: some View {
        if let credit = PhotoLibrary.credits[place.id] {
            Text("照片：\(credit.artist)・\(credit.license)・Wikimedia Commons")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

private struct Tag: View {
    let text: String
    let symbol: String
    let color: Color

    var body: some View {
        Label(text, systemImage: symbol)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12), in: Capsule())
    }
}

private struct InfoCard: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
