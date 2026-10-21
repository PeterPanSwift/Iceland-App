import MapKit
import SwiftUI

struct MapScreen: View {
    private static let overview = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 64.85, longitude: -19.2),
        span: MKCoordinateSpan(latitudeDelta: 5.2, longitudeDelta: 10.5)
    ))

    @State private var position = MapScreen.overview
    @State private var selectedID: String?
    // The map is only kept alive while its tab is on screen so it stops rendering in the background.
    @State private var isVisible = false

    var body: some View {
        NavigationStack {
            Group {
                if isVisible {
                    map
                } else {
                    Theme.deepBlue.ignoresSafeArea()
                }
            }
            .onAppear { isVisible = true }
            .onDisappear { isVisible = false }
            .safeAreaInset(edge: .bottom) { cards }
            .onChange(of: selectedID) { _, id in
                guard let place = Place.all.first(where: { $0.id == id }) else { return }
                withAnimation(.easeInOut(duration: 1.8)) {
                    position = .camera(MapCamera(centerCoordinate: place.coordinate, distance: 12_000, heading: 20, pitch: 60))
                }
            }
            .navigationTitle("景點地圖")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedID = nil
                        withAnimation(.easeInOut(duration: 1.5)) { position = MapScreen.overview }
                    } label: {
                        Image(systemName: "globe.europe.africa.fill")
                    }
                    .accessibilityLabel("顯示全島")
                    .accessibilityIdentifier("mapOverview")
                }
            }
            .navigationDestination(for: Place.self) { place in
                PlaceDetailView(place: place)
            }
        }
    }

    private var map: some View {
        Map(position: $position, selection: $selectedID) {
            ForEach(Place.all) { place in
                Marker(place.name, systemImage: place.category.symbol, coordinate: place.coordinate)
                    .tint(place.category.color)
                    .tag(place.id)
            }
        }
        .mapStyle(.hybrid(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
    }

    private var cards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Place.all) { place in
                    MapCard(place: place, isSelected: selectedID == place.id) {
                        selectedID = place.id
                    }
                    .accessibilityIdentifier("mapcard_\(place.id)")
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $selectedID, anchor: .center)
        .padding(.vertical, 12)
        .accessibilityIdentifier("mapCards")
    }
}

private struct MapCard: View {
    let place: Place
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                PlacePhoto(id: place.id, category: place.category)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(place.name)
                        .font(.subheadline.weight(.bold))
                    Text(place.localName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Label(place.region, systemImage: "mappin")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(width: 140, alignment: .leading)
            }
            .padding(10)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(isSelected ? place.category.color : .clear, lineWidth: 2.5)
            }
            .scaleEffect(isSelected ? 1.0 : 0.95)
            .animation(.snappy, value: isSelected)
        }
        .buttonStyle(.plain)
        .id(place.id)
    }
}
