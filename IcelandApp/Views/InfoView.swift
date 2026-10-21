import SwiftUI

struct InfoView: View {
    private let facts: [(title: String, value: String, symbol: String)] = [
        ("首都", "雷克雅維克", "building.2.fill"),
        ("人口", "約 39 萬人", "person.3.fill"),
        ("面積", "103,000 km²", "map.fill"),
        ("貨幣", "冰島克朗 ISK", "banknote.fill"),
        ("語言", "冰島語", "character.bubble.fill"),
        ("時區", "UTC+0（無夏令）", "clock.fill"),
    ]

    private let tips: [(title: String, detail: String, symbol: String)] = [
        ("洋蔥式穿搭", "天氣一日數變，防風防水外套是必備單品。", "cloud.sun.rain.fill"),
        ("1 號環島公路", "全長約 1,322 公里，自駕 7–10 天最舒服。", "car.fill"),
        ("高地 F 路", "僅夏季開放，必須駕駛四輪傳動車。", "exclamationmark.triangle.fill"),
        ("尊重大自然", "苔蘚生長極慢，請走在步道上，不要踩踏。", "leaf.fill"),
        ("自來水可生飲", "冰島的水來自冰川與泉水，乾淨又好喝。", "drop.fill"),
        ("幾乎全面刷卡", "連加油站與小攤販都能感應支付。", "creditcard.fill"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    factsGrid
                    seasons
                    tipsList
                    credits
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("認識冰島")
        }
    }

    private var factsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(facts, id: \.title) { fact in
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: fact.symbol)
                        .font(.title3)
                        .foregroundStyle(Theme.accent)
                    Text(fact.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(fact.value)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
        }
    }

    private var seasons: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("什麼時候去？")
                .font(.title2.weight(.bold))
            SeasonCard(
                title: "夏季・6 月 – 8 月",
                detail: "午夜太陽幾乎不落下，高地道路開放，適合健行、賞海鸚與環島自駕。",
                symbol: "sun.max.fill",
                colors: [.orange, .pink]
            )
            SeasonCard(
                title: "冬季・11 月 – 3 月",
                detail: "白天短暫但夜空漫長，是追逐北極光、探訪藍冰洞的最佳季節。",
                symbol: "moon.stars.fill",
                colors: [.indigo, Theme.deepBlue]
            )
        }
    }

    private var tipsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("旅遊小提示")
                .font(.title2.weight(.bold))
            VStack(spacing: 0) {
                ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: tip.symbol)
                            .font(.title3)
                            .foregroundStyle(Theme.accent)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(tip.title).font(.headline)
                            Text(tip.detail).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(16)
                    if index < tips.count - 1 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private var credits: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("照片來源")
                .font(.title2.weight(.bold))
            Text("所有照片皆來自 Wikimedia Commons，依各自的創用 CC 授權使用。")
                .font(.footnote)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Place.all) { place in
                    if let credit = PhotoLibrary.credits[place.id] {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(place.name).font(.subheadline.weight(.semibold))
                            Text("\(credit.artist)・\(credit.license)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

private struct SeasonCard: View {
    let title: String
    let detail: String
    let symbol: String
    let colors: [Color]

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.largeTitle)
                .symbolRenderingMode(.hierarchical)
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).opacity(0.9)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(18)
        .background(
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }
}
