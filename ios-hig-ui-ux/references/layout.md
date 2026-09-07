# 版面配置與自適應設計（Layout & Adaptivity）

依據 Apple HIG 官方內容整理（涵蓋 iOS 26 Liquid Glass 設計系統與 iOS 27 更新，HIG 更新至 2026-06）。聚焦 iOS／iPadOS。

## 目錄

- [核心原則](#核心原則)
- [Safe Area 與 Layout Guides](#safe-area-與-layout-guides)
- [自適應設計](#自適應設計)
- [Liquid Glass 與 edge-to-edge 內容](#liquid-glass-與-edge-to-edge-內容)
- [Scroll Views](#scroll-views)
- [iPad 視窗與 Multitasking](#ipad-視窗與-multitasking)
- [Split Views](#split-views)
- [全螢幕模式](#全螢幕模式)
- [規格速查](#規格速查)
- [常見錯誤檢查清單](#常見錯誤檢查清單)

## 核心原則

- 依閱讀順序安排重要性：最重要的內容放在視窗的頂部與 leading 側（由上而下、leading → trailing）。注意閱讀順序隨語言而異，支援 right-to-left 語言時介面需鏡像。SwiftUI：使用 `.leading`/`.trailing` 而非 `.left`/`.right`。
- 用群組傳達關聯：以負空間、背景形狀、色彩、material 或分隔線群組相關項目；確保 content 與 controls 視覺上清楚區分。
- 給重要資訊足夠空間，不要讓次要細節擠壓它；次要資訊移到其他區域或額外的 view。
- 對齊元件以利掃視：對齊 + 縮排傳達組織與資訊階層，捲動時也更容易追蹤內容。
- 運用 progressive disclosure：無法一次顯示全部內容時，露出部分項目（partial content）暗示可捲動或展開，不要讓內容看起來「已到底」。
- 控制項周圍留足空間並分邏輯群組；不相關的控制項靠太近會難以辨別。

## Safe Area 與 Layout Guides

- 永遠尊重 safe area：safe area 是 view 中不被 toolbar、tab bar、Dynamic Island、camera controls、Home Screen indicator 等遮蔽的區域。所有互動元素與關鍵內容必須放在 safe area 內。SwiftUI 預設自動處理；UIKit 用 `safeAreaLayoutGuide`。
- 用 layout guides 定位內容：使用系統預定義的 layout margins 與 readable content guide（限制文字寬度以利閱讀），不要自己發明邊距常數。UIKit：`layoutMarginsGuide`、`readableContentGuide`。
- Safe area 是動態的：bars 顯示／隱藏、裝置旋轉、iPad 視窗縮放時 safe area 會變，讓內容跟著 safe area 重新排版，不要快取其數值。
- 避免全寬按鈕：按鈕應尊重系統邊距、從螢幕邊緣內縮。若必須全寬，確保與硬體圓角協調並對齊相鄰 safe area。
- 只在有價值時隱藏 status bar（如遊戲、觀看媒體）；status bar 佔用的區域多數 App 本來就用不到。
- SwiftUI：`.safeAreaInset()`、`.safeAreaPadding()`、`.ignoresSafeArea()`（僅用於背景，不用於內容與控制項）。
- 需要各平台 guides 與 safe areas 的設計模板時，參考 Apple Design Resources。

## 自適應設計

- 絕不硬編座標或以裝置型號分支：不要寫 `if UIDevice.model == ...` 或針對特定螢幕尺寸寫死 frame。改用 SwiftUI layout 系統或 Auto Layout，讓介面隨系統定義的 traits 動態調適。
- 以 size class 做版型決策：size class 只有 `regular` 與 `compact` 兩值。iPhone 直向一律 compact width；iPad 全螢幕為 regular × regular；Pro Max／Plus／Air 機種橫向是 regular width，其餘 iPhone 橫向是 compact width。同一 iPad 上分割視窗時 size class 也會改變，因此「size class ≠ 裝置」。SwiftUI：`@Environment(\.horizontalSizeClass)`。
- 必須處理的環境變化：不同螢幕尺寸與解析度、直橫向、Dynamic Island 與 camera controls、Display Zoom、iPad 可縮放視窗、外接顯示器、Dynamic Type 字級、locale（RTL、日期／數字格式、文字長度）。
- 支援 Dynamic Type 並準備好版面因此改變：字級放大後，橫排元素應轉為直排、行數不可寫死、容器高度不可固定。SwiftUI：`ViewThatFits`、`@ScaledMetric`、`dynamicTypeSize` 環境值；避免對 `Text` 設固定 `frame` 高度。
- 盡量同時支援直向與橫向：若只支援單一方向，兩種旋轉方向（左轉／右轉）都必須正常運作，且不要跳提示叫使用者轉裝置。
- 藝術素材因長寬比不合而被裁切時，縮放而非改變長寬比，確保重要視覺內容可見。
- 準備好外接顯示器與 Display Zoom：兩者都會改變可用的邏輯尺寸，版面必須不假設固定螢幕大小。
- 用最大與最小版面先行測試：先測最小裝置（iPhone SE 320pt 寬）＋最大 Dynamic Type，以及最大裝置＋最小字級，兩個極端都成立中間通常沒問題。並以不同 localization 與方向預覽。

## Liquid Glass 與 edge-to-edge 內容

iOS 26 起，controls 與導航元件（sidebar、tab bar、toolbar）使用 Liquid Glass material，浮在 content layer「之上」而非同一平面。版面設計必須以此分層為前提。

- 內容延伸至填滿螢幕：背景與全螢幕素材延伸到顯示器邊緣；可捲動版面持續延伸到螢幕底部與左右兩側（穿過浮動的 bars 底下），不要讓內容在 bar 邊緣「停住」。
- 內容未滿版時使用 background extension view：在 sidebar 或 inspector 側邊，用背景延伸效果製造內容延伸到控制層底下的視覺。SwiftUI：`.backgroundExtensionEffect()`。
- 用 scroll edge effect 取代 bar 背景：不要給 bar 加不透明背景，改用 scroll edge effect 作為 content 與控制區之間的過渡。
- 靠 Liquid Glass 區分控制項與內容：控制項用系統 material 取得跨 iOS／iPadOS／macOS 一致的外觀，不要自訂 bar 底色去模仿。
- 遊戲偏好 full-bleed 介面：填滿螢幕同時避讓硬體圓角、感光元件與 Dynamic Island；必要時提供 letterbox／pillarbox 選項。

## Scroll Views

- 支援系統預設捲動手勢與彈性（elastic）行為；自訂捲動也要保留使用者習慣的慣性與回彈。
- 讓「可捲動」顯而易見：scroll indicators 不常駐，用 partial content（在邊緣露出下一項的一部分）暗示還有內容。
- 避免同向巢狀捲動：同方向的 scroll view 互相嵌套會產生無法預期的操作行為；橫向嵌在直向內（或反之）則可以。
- 內容適合時支援逐頁捲動（paging）：頁的大小通常等於目前 view 的高或寬；可扣除一個重疊單位（如一行文字）幫助使用者維持上下文。SwiftUI：`.scrollTargetBehavior(.paging)`。
- 顯示 page control 時，同軸不要再顯示 scroll indicator，避免重複控制項使人混淆。
- 自動捲動僅在必要時使用（搜尋結果選取、插入點移出可視範圍、拖曳選取超出邊緣），且只捲動到「足以恢復上下文」的最小幅度。
- 支援縮放時設定合理的最小／最大 scale。
- 其他平台一句帶過：visionOS 於 2026 新增 Look to Scroll（閱讀／瀏覽視圖以視線捲動）；watchOS 偏好垂直捲動搭配 Digital Crown 與 tab view 分頁。

### Scroll edge effects（iOS 26 新增；2026-06 更新指引）

- 偏好 automatic 樣式：對控制項較多的 toolbar、Liquid Glass 之外的文字、pinned table headers，automatic 提供較不透明的視覺分離。若改用 soft 樣式，務必多情境測試控制項可讀性。
- scroll edge effect 不是裝飾：只在 scroll view 位於浮動介面元素底下時使用，目的是保持控制項清晰可辨，不是 overlay、不壓暗內容。
- 每個 view 只套一個 scroll edge effect；iPad／Mac 的 split view 各 pane 可各有一個，但高度需一致以維持對齊。
- 若用自訂 bars 需要額外清晰度，可手動加上或在 hard／soft 間調整。SwiftUI：`.scrollEdgeEffectStyle(_:for:)`。

## iPad 視窗與 Multitasking

iPadOS 26 起使用者可自由縮放視窗（類似 macOS），可最小到系統下限；系統提供二分／三分／四分平鋪的視窗控制。App 無法控制也無法得知 multitasking 配置，只能自適應。

- 以全螢幕版面為優先設計，縮小時盡量延後切換到 compact 版型：完整版面放不下才降級，讓 UI 感覺穩定。複雜版面（如三欄 split view）收窄時優先隱藏第三欄（inspector）。
- 在系統提供的常見尺寸測試：半屏、三分之一、四分之一，以及最小與最大視窗，確保切換過程平順、無突兀跳動。
- 考慮 convertible tab bar：可在 sidebar 與 tab bar 之間切換的 tab bar 樣式，視窗縮放時呈現方式自動配合寬度。SwiftUI：`.tabViewStyle(.sidebarAdaptable)`。
- 避免把控制項或關鍵資訊放在視窗底部：使用者常把視窗下緣拖出螢幕外。
- 避免內容顯示在視窗頂緣的 camera housing 區域。
- 視窗化時注意視窗控制鈕（leading 側）可能遮住 toolbar 的 leading 按鈕，需讓按鈕內移避讓。
- 隨時準備被切換走：切換 App 時暫停需要注意力的活動（遊戲、影片），返回時無縫續播；使用者發起的任務（下載、轉檔）在背景完成；通知節制使用。
- App 支援多視窗時，開新視窗要有正當理由（如 Mail 撰寫新信保留原信可見）；不要把開新視窗當預設行為，過多視窗造成混亂。以 context menu 提供「在新視窗開啟」選項即可，也可考慮 pinch 手勢將項目展開為新視窗。SwiftUI：`WindowGroup`、`openWindow`。
- 不要自訂視窗框架或視窗控制鈕，也不要模仿系統外觀；使用者面前一律稱「視窗（window）」，不要用「scene」等實作術語。
- 影片與 FaceTime 可能以 Picture in Picture 浮在你的 App 之上，不論全螢幕或視窗化；不要假設 App 獨佔螢幕。

## Split Views

- 用 split view 同時呈現多層階層並支援導航：leading pane 列頂層項目（常為 sidebar），secondary／tertiary pane 顯示子集合與詳細內容。
- 只在 regular width 環境使用多欄並排；compact（iPhone 直向）下難以並排多欄，應退化為堆疊導航。SwiftUI：`NavigationSplitView`（自動處理 compact 退化）。
- 為 narrow、compact 與中間寬度都設計版型：iPad 視窗可流暢縮放，確保任何寬度下都能合理地在各 pane 間導航。
- 持續高亮通往 detail view 的目前選取項，讓各 pane 內容之間的關係一目了然。
- 考慮支援跨 pane 拖放內容。
- 考慮讓使用者隱藏非主要 pane（如編輯情境隱藏 navigator／inspector）以減少干擾，並提供多種喚回方式（toolbar 按鈕、選單命令、鍵盤快捷鍵）。
- 補充資訊優先用 split view（如 inspector 欄），不要開新視窗；需要使用者先完成的小任務用 sheet。
- 其他平台一句帶過：macOS 可拖曳 divider 調整 pane 且偏好 1pt 細分隔線；watchOS 的 split view 以全螢幕輪替呈現 list 與 detail。

## 全螢幕模式

- 在合理情境才提供：遊戲、觀看影片／幻燈片、需要沉浸的深度任務。
- 進入與退出都由使用者決定：不要自動結束全螢幕；切換走再回來時從原處續行（遊戲、幻燈片自動暫停）。
- 全螢幕下持續提供必要控制：如媒體播放控制常駐或易於喚出，使用者不必退出全螢幕才能完成任務。
- 以「暫時隱藏 bars」達成無干擾閱讀／看圖：內容為主的情境可隱藏 toolbar 與導航，但要能用熟悉手勢（點按、下滑）喚回；導航必需的控制不可隱藏。
- 全螢幕遊戲考慮延遲系統手勢（deferring system gestures）防止誤退出：預設 Home Screen indicator 會自動隱藏、互動底部才出現，盡量保留此預設；誤觸頻繁時才改為需滑兩次退出。
- 除遊戲外，iPadOS 全螢幕仍應允許使用者喚出 Dock。
- 若在全螢幕調整版面，只做比例微調、不改變出現的項目，且不要以程式改變視窗大小，避免模式切換時視覺跳動。
- macOS 一句帶過：使用系統提供的全螢幕機制（自動避讓相機艙），遊戲進入全螢幕時不要改變 display mode。

## 規格速查

代表性裝置的邏輯尺寸（pt，直向），做為版面測試矩陣的取樣點；完整清單見 HIG「Layout > Specifications」：

| 裝置 | 直向尺寸（pt） | 備註 |
|---|---|---|
| iPhone SE（4 吋） | 320 × 568 | 最小寬度基準，@2x |
| iPhone 16e | 390 × 844 | @3x |
| iPhone 17 / 16 Pro | 402 × 874 | @3x |
| iPhone Air | 420 × 912 | @3x，橫向 regular width |
| iPhone 17 Pro Max | 440 × 956 | 最大 iPhone，橫向 regular width |
| iPad mini（8.3 吋） | 744 × 1133 | @2x |
| iPad Air 11 吋 | 820 × 1180 | @2x |
| iPad Pro 13 吋 | 1032 × 1376 | 最大 iPad，@2x |

Size class 判斷規則（勿背裝置清單，執行期查詢環境值即可）：

- 所有 iPhone 直向：compact width × regular height。
- iPhone 橫向：Pro Max／Plus／Air 為 regular width × compact height；其餘為 compact × compact。
- iPad 全螢幕（任一方向）：regular × regular；分割或縮小視窗時可能降為 compact width。
- 表中的 scale factor 為 UIKit scale factor，可能與 native scale 不同；勿用像素值做版面運算，一律用 pt。

## 常見錯誤檢查清單

- 以裝置型號或螢幕尺寸硬編版面 → 改用 size classes 與 layout 系統。
- 內容或按鈕被 Dynamic Island、Home indicator、bars 遮住 → 檢查 safe area 使用。
- 給 tab bar／toolbar 加不透明背景 → 改用 Liquid Glass ＋ scroll edge effect。
- 可捲動內容在 bar 邊緣被截斷、未延伸至螢幕邊緣 → 讓 scroll view 穿過 bars 底下。
- 同向巢狀 scroll view → 重構為單一捲動容器（如 `LazyVStack` in one `ScrollView`）。
- Dynamic Type 放大後文字截斷、版面破版 → 移除固定高度、採 `ViewThatFits` 或轉直排。
- iPad 視窗縮到中間寬度時版面跳動或無法導航 → 補中間寬度的版型與平滑過渡。
- 只在單一模擬器尺寸測試 → 至少測最小 iPhone、最大 iPhone、iPad 分割視窗、RTL 與最大字級。
