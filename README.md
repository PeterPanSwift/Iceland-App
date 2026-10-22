# 冰島之旅 Iceland App

以 SwiftUI 開發的冰島旅遊介紹 App。

- **探索**：精選景點輪播、依類型（瀑布、冰川、海岸、地熱、自然、城市）篩選的景點列表，點擊進入有縮放轉場的景點介紹頁，可加入收藏。
- **地圖**：MapKit 衛星混合地圖標示所有景點，點擊下方卡片即以 3D 視角飛到該景點。
- **收藏**：收藏的景點清單。
- **資訊**：冰島基本資料、旅遊季節、旅遊小提示與照片來源。

## 照片

景點照片來自 [Wikimedia Commons](https://commons.wikimedia.org)，依各自的創用 CC 授權使用。
執行 `python3 scripts/fetch_photos.py` 會下載照片到 `IcelandApp/Photos/`，並將作者與授權寫入 `credits.json`，App 的「資訊」頁會顯示來源。

## 建置

```sh
brew install xcodegen
python3 scripts/fetch_photos.py
xcodegen generate
open IcelandApp.xcodeproj
```

需求：Xcode 26 以上，iOS 18 以上。

App 圖示由 `python3 scripts/make_app_icon.py` 繪製（極光下的草帽山），輸出到 `IcelandApp/Assets.xcassets/AppIcon.appiconset/`。

## 錄製操作影片

`.github/workflows/record-demo.yml` 在 GitHub 的 `xcode-27` runner 上以 Xcode 27 建置 App，
開啟 iPhone 18 Pro Max 模擬器，透過 `simctl io recordVideo` 錄下 `AppTourUITests` 的自動操作，
並將原始影片與時間標記（`marks.json`）推送到 `recordings` 分支。

之後執行 `python3 scripts/edit_video.py <錄影資料夾> demo.mp4`：比對主畫面找出 App 啟動與結束的位置、裁掉 App 以外的畫面、縮短靜止等待的片段，並壓縮成 1280p H.264。
