import SwiftUI

struct PlaceRoute: Hashable {
    let place: Place
    let source: String

    var transitionID: String { "\(source)_\(place.id)" }
}

struct ExploreView: View {
    @State private var category: PlaceCategory?
    @Namespace private var zoom

    private var filtered: [Place] {
        guard let category else { return Place.all }
        return Place.all.filter { $0.category == category }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    HeroHeader()

                    SectionTitle(title: "精選景點", subtitle: "一生必去的冰島絕景")
                    featuredCarousel

                    SectionTitle(title: "所有景點", subtitle: "依類型探索冰與火的國度")
                    categoryChips
                    placeList
                }
                .padding(.bottom, 32)
            }
            .ignoresSafeArea(edges: .top)
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .navigationTitle("探索")
            .navigationDestination(for: PlaceRoute.self) { route in
                PlaceDetailView(place: route.place)
                    .navigationTransition(.zoom(sourceID: route.transitionID, in: zoom))
            }
        }
    }

    private var featuredCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(Place.featured) { place in
                    let route = PlaceRoute(place: place, source: "featured")
                    NavigationLink(value: route) {
                        FeaturedCard(place: place)
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: route.transitionID, in: zoom)
                    .accessibilityIdentifier("featured_\(place.id)")
                    .scrollTransition(axis: .horizontal) { content, phase in
                        content
                            .scaleEffect(phase.isIdentity ? 1 : 0.92)
                            .opacity(phase.isIdentity ? 1 : 0.8)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .frame(height: 380)
        .accessibilityIdentifier("featuredCarousel")
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChip(title: "全部", symbol: "sparkles", isSelected: category == nil) {
                    category = nil
                }
                .accessibilityIdentifier("category_all")

                ForEach(PlaceCategory.allCases) { item in
                    CategoryChip(title: item.title, symbol: item.symbol, isSelected: category == item) {
                        category = item
                    }
                    .accessibilityIdentifier("category_\(item.rawValue)")
                }
            }
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
    }

    private var placeList: some View {
        LazyVStack(spacing: 14) {
            ForEach(filtered) { place in
                let route = PlaceRoute(place: place, source: "list")
                NavigationLink(value: route) {
                    PlaceRow(place: place)
                }
                .buttonStyle(.plain)
                .matchedTransitionSource(id: route.transitionID, in: zoom)
                .accessibilityIdentifier("place_\(place.id)")
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .padding(.horizontal, 20)
        .animation(.snappy, value: category)
    }
}

private struct HeroHeader: View {
    var body: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .scrollView).minY
            PlacePhoto(id: "kirkjufell")
                .frame(width: geo.size.width, height: geo.size.height + max(0, minY))
                .overlay {
                    LinearGradient(
                        colors: [.black.opacity(0.35), .clear, .black.opacity(0.75)],
                        startPoint: .top, endPoint: .bottom
                    )
                }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ÍSLAND")
                            .font(.caption.weight(.heavy))
                            .kerning(6)
                            .opacity(0.85)
                        Text("冰與火之國")
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                        Text("冰川、火山、瀑布與極光交織的北大西洋島嶼")
                            .font(.subheadline.weight(.medium))
                            .opacity(0.9)
                    }
                    .foregroundStyle(.white)
                    .padding(24)
                    .padding(.bottom, 8)
                }
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 36, bottomTrailingRadius: 36))
                .offset(y: -max(0, minY))
        }
        .frame(height: 480)
    }
}

private struct SectionTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2.weight(.bold))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
    }
}

private struct FeaturedCard: View {
    let place: Place

    var body: some View {
        PlacePhoto(id: place.id, category: place.category)
            .frame(width: 290, height: 370)
            .overlay {
                LinearGradient(colors: [.clear, .clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
            }
            .overlay(alignment: .topLeading) {
                Label(place.category.title, systemImage: place.category.symbol)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(14)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.localName)
                        .font(.caption.weight(.semibold))
                        .opacity(0.8)
                    Text(place.name)
                        .font(.title2.weight(.bold))
                    Label(place.region, systemImage: "mappin.and.ellipse")
                        .font(.footnote)
                        .opacity(0.9)
                }
                .foregroundStyle(.white)
                .padding(18)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.18), radius: 12, y: 8)
    }
}

private struct CategoryChip: View {
    let title: String
    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .foregroundStyle(isSelected ? .white : .primary)
                .background(
                    isSelected ? AnyShapeStyle(Theme.accent) : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .animation(.snappy, value: isSelected)
    }
}

struct PlaceRow: View {
    let place: Place

    var body: some View {
        HStack(spacing: 14) {
            PlacePhoto(id: place.id, category: place.category)
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Image(systemName: place.category.symbol)
                        .foregroundStyle(place.category.color)
                    Text(place.localName)
                        .foregroundStyle(.secondary)
                }
                .font(.caption.weight(.semibold))

                Text(place.name)
                    .font(.headline)

                Text(place.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .contentShape(Rectangle())
    }
}
