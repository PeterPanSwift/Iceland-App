import CoreLocation
import SwiftUI

enum PlaceCategory: String, CaseIterable, Identifiable {
    case waterfall, glacier, coast, geothermal, nature, city

    var id: String { rawValue }

    var title: String {
        switch self {
        case .waterfall: "瀑布"
        case .glacier: "冰川"
        case .coast: "海岸"
        case .geothermal: "地熱"
        case .nature: "自然"
        case .city: "城市"
        }
    }

    var symbol: String {
        switch self {
        case .waterfall: "drop.fill"
        case .glacier: "snowflake"
        case .coast: "water.waves"
        case .geothermal: "flame.fill"
        case .nature: "mountain.2.fill"
        case .city: "building.columns.fill"
        }
    }

    var color: Color {
        switch self {
        case .waterfall: .cyan
        case .glacier: .blue
        case .coast: .indigo
        case .geothermal: .orange
        case .nature: .green
        case .city: .purple
        }
    }
}

struct Place: Identifiable, Hashable {
    let id: String
    let name: String
    let localName: String
    let region: String
    let category: PlaceCategory
    let summary: String
    let description: String
    let highlights: [String]
    let bestSeason: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: Place, rhs: Place) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension Place {
    static let featured: [Place] = ["jokulsarlon", "kirkjufell", "skogafoss", "aurora", "reynisfjara"]
        .compactMap { id in all.first { $0.id == id } }

    static let all: [Place] = [
        Place(
            id: "jokulsarlon",
            name: "傑古沙龍冰河湖",
            localName: "Jökulsárlón",
            region: "東南部・瓦特納冰川",
            category: .glacier,
            summary: "湛藍冰山緩緩漂向大海，冰島最夢幻的冰河湖。",
            description: "傑古沙龍是由布雷達梅庫冰川融化形成的冰河湖，也是冰島最深的湖泊之一。從冰舌崩落的千年冰山在湖面上漂浮，最後經由短短的河道流入大西洋，被海浪沖上黑沙灘後，便成了閃閃發亮的「鑽石沙灘」。",
            highlights: ["搭乘水陸兩用船近距離看冰山", "對岸的鑽石沙灘", "湖中常有海豹出沒"],
            bestSeason: "全年皆宜",
            latitude: 64.0784, longitude: -16.2306
        ),
        Place(
            id: "kirkjufell",
            name: "草帽山",
            localName: "Kirkjufell",
            region: "斯奈山半島",
            category: .nature,
            summary: "造型如教堂尖頂的山峰，冰島最常被拍攝的山。",
            description: "Kirkjufell 意為「教堂山」，海拔 463 公尺，獨特的尖錐外型讓它成為冰島的代表風景。山腳下的 Kirkjufellsfoss 小瀑布與山峰同框，是攝影師拍攝日落與極光的經典機位，也曾出現在《冰與火之歌：權力遊戲》中。",
            highlights: ["瀑布與山峰同框的經典構圖", "冬季極光拍攝熱點", "鄰近漁村格倫達菲厄澤"],
            bestSeason: "夏季日落、冬季極光",
            latitude: 64.9417, longitude: -23.3069
        ),
        Place(
            id: "skogafoss",
            name: "斯科加瀑布",
            localName: "Skógafoss",
            region: "南岸",
            category: .waterfall,
            summary: "寬 25 公尺、落差 60 公尺的壯麗水幕，晴天常見彩虹。",
            description: "斯科加瀑布位於昔日的海岸懸崖上，水量豐沛，水霧瀰漫，陽光充足時幾乎都能看到單道甚至雙道彩虹。沿著瀑布右側的 500 多級階梯可以登上頂端，俯瞰整片南岸平原，也是著名健行路線 Fimmvörðuháls 的起點。",
            highlights: ["瀑布前的雙彩虹", "登上觀景台俯瞰平原", "傳說瀑布後藏有維京寶箱"],
            bestSeason: "5 月 – 9 月",
            latitude: 63.5321, longitude: -19.5114
        ),
        Place(
            id: "aurora",
            name: "北極光",
            localName: "Norðurljós",
            region: "全島・米湖地區尤佳",
            category: .nature,
            summary: "在漆黑的冬夜裡，綠色光帶在天空中舞動。",
            description: "冰島位於極光帶上，從 9 月到隔年 4 月的晴朗夜晚都有機會看到北極光。遠離城市光害、選擇天氣晴朗且太陽活動旺盛的日子，就能看見綠色、紫色的光幕在夜空中流動。北部的米湖與東南部的冰河湖都是熱門觀賞地點。",
            highlights: ["查詢冰島氣象局的極光預報", "遠離光害的郊區最理想", "攜帶三腳架長時間曝光"],
            bestSeason: "9 月 – 4 月",
            latitude: 65.6039, longitude: -16.9961
        ),
        Place(
            id: "reynisfjara",
            name: "黑沙灘",
            localName: "Reynisfjara",
            region: "南岸・維克",
            category: .coast,
            summary: "黑色火山沙、玄武岩柱與海蝕柱構成的狂野海岸。",
            description: "雷尼斯黑沙灘由火山熔岩冷卻後的黑色細沙組成，旁邊是如管風琴般整齊排列的六角玄武岩柱，海面上矗立著傳說中由巨魔化成的 Reynisdrangar 海蝕柱。這裡的「瘋狗浪」非常危險，參觀時務必與海浪保持距離。",
            highlights: ["六角玄武岩柱 Gardar", "Reynisdrangar 海蝕柱", "注意突如其來的瘋狗浪"],
            bestSeason: "全年皆宜",
            latitude: 63.4044, longitude: -19.0450
        ),
        Place(
            id: "seljalandsfoss",
            name: "塞里雅蘭瀑布",
            localName: "Seljalandsfoss",
            region: "南岸",
            category: .waterfall,
            summary: "可以走到瀑布後方的水簾洞，看見截然不同的角度。",
            description: "塞里雅蘭瀑布從 60 公尺高的懸崖傾瀉而下，最特別的是瀑布後方有一條環形步道，遊客可以繞到水簾後面欣賞。傍晚時分夕陽穿過水幕，景色格外迷人。附近步行數分鐘還有隱身在峽谷中的 Gljúfrabúi 秘境瀑布。",
            highlights: ["走進水簾後方的環形步道", "夏季夕陽穿透水幕", "鄰近秘境瀑布 Gljúfrabúi"],
            bestSeason: "5 月 – 9 月",
            latitude: 63.6156, longitude: -19.9886
        ),
        Place(
            id: "gullfoss",
            name: "黃金瀑布",
            localName: "Gullfoss",
            region: "金圈",
            category: .waterfall,
            summary: "兩段式階梯瀑布轟然墜入峽谷，金圈必訪景點。",
            description: "黃金瀑布是冰島最著名的瀑布之一，Hvítá 河水分成兩段，先落下 11 公尺、再墜落 21 公尺沖入 32 公尺深的峽谷。陽光下水霧映出金黃色光芒，因而得名。20 世紀初曾因水力發電計畫面臨危機，最後在當地人的努力下得以保存。",
            highlights: ["上下兩層觀景步道", "峽谷中的壯觀水霧", "冬季冰封的特殊景色"],
            bestSeason: "全年皆宜",
            latitude: 64.3271, longitude: -20.1199
        ),
        Place(
            id: "strokkur",
            name: "史托克間歇泉",
            localName: "Strokkur",
            region: "金圈・蓋歇爾地熱區",
            category: .geothermal,
            summary: "每 5–10 分鐘噴發一次，水柱可高達 20 公尺。",
            description: "史托克間歇泉位於 Haukadalur 地熱谷，是冰島最活躍的間歇泉。噴發前，水面會先鼓起一個湛藍色的水泡，接著滾燙的水柱衝向天際。旁邊的大間歇泉 Geysir 則是英文「geyser」一詞的由來。",
            highlights: ["觀察噴發前的藍色水泡", "Geysir — 間歇泉的命名由來", "周邊冒著蒸氣的地熱步道"],
            bestSeason: "全年皆宜",
            latitude: 64.3127, longitude: -20.3005
        ),
        Place(
            id: "thingvellir",
            name: "辛格韋德利國家公園",
            localName: "Þingvellir",
            region: "金圈",
            category: .nature,
            summary: "北美與歐亞板塊交界，也是世界最古老的議會遺址。",
            description: "辛格韋德利是聯合國世界遺產，西元 930 年冰島人在這裡成立了世界上最早的議會 Alþingi。公園位於北美板塊與歐亞板塊的交界處，可以漫步在大地裂谷之間，還能到 Silfra 裂縫浮潛，在能見度超過 100 公尺的冰川融水中穿梭兩大板塊。",
            highlights: ["漫步大西洋中洋脊裂谷", "Silfra 裂縫浮潛", "古議會遺址 Lögberg"],
            bestSeason: "全年皆宜",
            latitude: 64.2559, longitude: -21.1299
        ),
        Place(
            id: "bluelagoon",
            name: "藍湖溫泉",
            localName: "Bláa lónið",
            region: "雷克雅內斯半島",
            category: .geothermal,
            summary: "乳藍色的地熱溫泉，被熔岩原環繞的露天 SPA。",
            description: "藍湖溫泉位於黑色熔岩原中，富含矽和礦物質的地熱海水呈現夢幻的乳藍色，水溫常年維持在 37–39°C。泡湯時敷上白色矽泥面膜，是遊客最愛的體驗。藍湖距離凱夫拉維克國際機場僅約 20 分鐘車程，很適合安排在抵達或離境當天。",
            highlights: ["矽泥面膜體驗", "湖中酒吧點杯飲料", "距機場僅 20 分鐘"],
            bestSeason: "全年皆宜（需預約）",
            latitude: 63.8804, longitude: -22.4495
        ),
        Place(
            id: "hallgrimskirkja",
            name: "哈爾格林姆教堂",
            localName: "Hallgrímskirkja",
            region: "雷克雅維克",
            category: .city,
            summary: "靈感來自玄武岩柱的教堂，雷克雅維克的地標。",
            description: "哈爾格林姆教堂高 74.5 公尺，是冰島最高的教堂，設計靈感來自冰島常見的玄武岩柱地形，耗時 41 年才完工。搭電梯登上鐘樓，可以 360 度眺望雷克雅維克五彩繽紛的屋頂與遠方的海灣和山脈。",
            highlights: ["登上鐘樓俯瞰全市", "5,275 根管子的巨型管風琴", "教堂前的萊夫・艾瑞克森雕像"],
            bestSeason: "全年皆宜",
            latitude: 64.1417, longitude: -21.9266
        ),
        Place(
            id: "dettifoss",
            name: "黛提瀑布",
            localName: "Dettifoss",
            region: "北部・瓦特納冰川國家公園",
            category: .waterfall,
            summary: "歐洲水量最大的瀑布之一，氣勢震撼人心。",
            description: "黛提瀑布寬約 100 公尺、落差 44 公尺，每秒有數百立方公尺的冰川融水奔流而下，被譽為歐洲最具威力的瀑布。灰白色的河水與周圍荒涼的玄武岩地貌形成強烈對比，電影《普羅米修斯》的開場就在這裡拍攝。",
            highlights: ["感受震耳欲聾的水聲", "上游的 Selfoss 瀑布", "電影《普羅米修斯》取景地"],
            bestSeason: "6 月 – 9 月",
            latitude: 65.8147, longitude: -16.3846
        ),
    ]
}
