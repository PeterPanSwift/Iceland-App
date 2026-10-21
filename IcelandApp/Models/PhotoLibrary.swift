import SwiftUI
import UIKit

struct PhotoCredit: Decodable {
    let file: String
    let artist: String
    let license: String
    let url: String
}

/// Photos downloaded from Wikimedia Commons by `scripts/fetch_photos.py`.
@MainActor
enum PhotoLibrary {
    private static var cache: [String: UIImage] = [:]

    static let credits: [String: PhotoCredit] = {
        guard let url = Bundle.main.url(forResource: "credits", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let credits = try? JSONDecoder().decode([String: PhotoCredit].self, from: data)
        else { return [:] }
        return credits
    }()

    static func image(for id: String) -> UIImage? {
        if let image = cache[id] { return image }
        guard let url = Bundle.main.url(forResource: id, withExtension: "jpg"),
              let image = UIImage(contentsOfFile: url.path)
        else { return nil }
        cache[id] = image
        return image
    }
}

/// Fills its frame with the place photo (or a gradient if the photo is missing).
struct PlacePhoto: View {
    let id: String
    var category: PlaceCategory = .nature

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [category.color.opacity(0.8), Theme.deepBlue],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .overlay {
                if let image = PhotoLibrary.image(for: id) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: category.symbol)
                        .font(.system(size: 44))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

enum Theme {
    static let accent = Color(red: 0.05, green: 0.47, blue: 0.68)
    static let deepBlue = Color(red: 0.04, green: 0.12, blue: 0.24)
}

@Observable
final class FavoritesStore {
    private(set) var ids: [String] = []

    var places: [Place] { ids.compactMap { id in Place.all.first { $0.id == id } } }

    func contains(_ place: Place) -> Bool { ids.contains(place.id) }

    func toggle(_ place: Place) {
        if let index = ids.firstIndex(of: place.id) {
            ids.remove(at: index)
        } else {
            ids.append(place.id)
        }
    }
}
