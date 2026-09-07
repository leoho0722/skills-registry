# Liquid Glass 設計語言與 Materials 最佳實踐

根據 Apple HIG「Materials」與 Technology Overviews「Liquid Glass / Adopting Liquid Glass」官方內容整理。聚焦 iOS/iPadOS App 開發的可執行守則。

## 目錄

- [Liquid Glass 是什麼](#liquid-glass-是什麼)
- [分層原則：functional layer vs content layer](#分層原則functional-layer-vs-content-layer)
- [何時用、絕不用](#何時用絕不用)
- [Variant 選擇：regular vs clear](#variant-選擇regular-vs-clear)
- [Legibility 與 accessibility](#legibility-與-accessibility)
- [與 standard materials 的分工](#與-standard-materials-的分工)
- [系統元件的自動採用與應檢查項目](#系統元件的自動採用與應檢查項目)
- [自訂元件採用 Liquid Glass checklist](#自訂元件採用-liquid-glass-checklist)
- [常見錯誤](#常見錯誤)
- [API 速查](#api-速查)
- [版本與變更紀錄](#版本與變更紀錄)

## Liquid Glass 是什麼

Liquid Glass 是 iOS 26 引入的動態 material，結合玻璃的光學特性（折射、反射、模糊）與流體感，統一 Apple 各平台的設計語言。它讓 controls 與 navigation 浮在內容之上而不遮蔽內容——內容可從元件底下捲動、透出，賦予介面動態與深度，同時維持元件的可讀性。

- 把 Liquid Glass 視為「元件的容器材質」，不是裝飾效果；它的目的是把注意力導向底下的內容。
- SwiftUI、UIKit、AppKit 的標準元件（bars、sheets、popovers、controls）自動採用此材質並隨情境動態調整（元素重疊、focus 狀態等），無需手動處理。
- 既有 App 採用 Liquid Glass 不需要重寫：先用最新版 Xcode 重新 build，觀察介面變化，再依本文檢查項目逐項調整。

## 分層原則：functional layer vs content layer

Liquid Glass 建立兩層明確的視覺階層：

| 層 | 內容 | 使用材質 |
|---|---|---|
| Functional layer（最上層） | controls 與 navigation：tab bar、sidebar、toolbar、sheet、popover、alert | Liquid Glass |
| Content layer（底層） | App 內容：列表、圖片、文字、App 背景 | Standard materials（ultra-thin / thin / regular / thick）與純色 |

- 明確分離內容與導覽元件。清楚、一致的 navigation hierarchy 比以往更重要——tab bar 與 sidebar 必須在視覺上與內容區隔，形成浮在內容之上的獨立功能層。
- 讓內容從 functional 元件底下透出（peek through）。檢查 sidebar／inspector 旁內容的 safe area，確保底層內容正確地從元件下方露出。
- 需要「內容延伸到 sidebar / inspector 底下」的沉浸感時，使用 background extension effect：它鏡射相鄰內容並模糊，營造滿版延伸感而不實際把內容排進元件下方。SwiftUI：`.backgroundExtensionEffect()`；UIKit：`UIBackgroundExtensionView`。

## 何時用、絕不用

**使用 Liquid Glass：**

- 優先透過系統標準元件取得，而非自己實作。標準元件會自動採用並隨系統演進。
- 只把自訂 Liquid Glass 效果用在 App 中最重要的功能性元件（自訂的浮動操作列、播放控制列等）。

**絕不／避免：**

- **絕不在 content layer 使用 Liquid Glass。** 放進內容層會造成不必要的複雜度與混亂的視覺階層；內容層一律用 standard materials（如 App 背景）。唯一例外：內容層中具有暫態互動元素的 controls（slider、toggle 的 knob）在使用者操作當下會短暫呈現 Liquid Glass 外觀以強調互動性——這由系統處理，不要自己模仿。
- **避免過度使用。** 在多個自訂 controls 上到處套 glass 效果會分散對內容的注意力，體驗反而變差。
- 避免在 controls 與 navigation 元件上使用自訂背景（custom backgrounds）。自訂背景會蓋住或干擾系統的 Liquid Glass 與 scroll edge effect；優先移除 split view、tab bar、toolbar 上的自訂背景與外觀，讓系統決定。
- 避免 Liquid Glass 元件互相堆疊或過度擁擠；使用標準間距，不要覆寫 layout metrics。

## Variant 選擇：regular vs clear

Liquid Glass 提供兩種 variant，用於自訂元件或某些系統元件的樣式設定：

**Regular（預設，絕大多數情境）**

- 模糊背景內容並調整亮度（luminosity）以維持前景文字與元素的可讀性；scroll edge effect 進一步模糊、降低背景不透明度強化可讀性。
- 大多數系統元件使用此 variant。
- 使用時機：背景內容可能造成可讀性問題，或元件含大量文字——alerts、sidebars、popovers。拿不準時選 regular。

**Clear（僅限視覺豐富背景）**

- 高度半透明，優先展現底層內容，適合浮在照片、影片等媒體背景上的元件（如播放控制），營造沉浸式體驗。
- **只**在元件下方是視覺豐富背景時使用 clear；一般 UI 背景上用 clear 會犧牲可讀性。
- Dimming layer 判斷：
  - 底層內容偏亮 → 在 clear 元件後方加一層 35% 不透明度的深色 dimming layer。
  - 底層內容夠暗，或使用 AVKit 標準播放控制（自帶 dimming）→ 不需另加。

SwiftUI：`.glassEffect(.regular)` / `.glassEffect(.clear)`；UIKit button configuration：`.glass()`、`.prominentGlass()`、`.clearGlass()`、`.prominentClearGlass()`。

## Legibility 與 accessibility

- 測試各種顯示與輔助使用設定的組合。使用者可以在裝置設定中選擇 Liquid Glass 的偏好外觀，也可能開啟 Reduce Transparency、Increase Contrast、Reduce Motion——這些設定會移除或改變透明與流體動畫效果。標準元件自動適配；自訂元件、自訂色與動畫必須逐一測試。
- 在 material 上的文字與圖示使用系統定義的 vibrant colors，不要用一般不透明色。Vibrant colors 在任何 material 與系統設定下都能維持對比，避免顏色過暗、過亮或對比不足。
- controls 與 navigation 上的用色要克制，讓元件保持可讀、讓內容透出來。若必須上色：使用 system colors，或自訂色時提供 light/dark 兩種 variant，且各自附 increased contrast 版本。
- 內容會捲動到 controls 底下時，確保啟用 scroll edge effect 維持對比。系統 bars 預設具備；自訂 bar 上有 controls、文字、圖示時，需自行註冊。SwiftUI：`.scrollEdgeEffectStyle(_:for:)`；UIKit：`UIScrollEdgeElementContainerInteraction`。
- Toolbar 圖示一律提供 accessibility label，即使畫面上只顯示 icon——VoiceOver / Voice Control 使用者依賴它。

## 與 standard materials 的分工

- Liquid Glass 負責 functional layer；standard materials 負責 content layer 內部的視覺區隔（如 App 背景、內容區塊的層次）。
- iOS/iPadOS 持續提供四種 standard materials：ultra-thin、thin、regular（預設）、thick。越厚（越不透明）對比越好，適合精細文字；越薄（越透明）越能保留背景脈絡感。SwiftUI：`.background(.regularMaterial)` 等；UIKit：`UIBlurEffect` + `UIVisualEffectView`。
- 依語意與用途選 material，不要依它「看起來的顏色」選——系統設定會改變其外觀行為。
- 搭配 material 的 labels/fills 使用系統 vibrancy 層級（default > secondary > tertiary > quaternary，對比遞減）；避免在 thin 與 ultra-thin material 上使用 quaternary（對比太低）。UIKit：`UIVibrancyEffect` + `UIVibrancyEffectStyle`。
- 其他平台一句帶過：tvOS 中元件獲得 focus 時呈現 Liquid Glass（採用標準 focus APIs 即可）；watchOS 變化最小（採用標準 button styles 與 toolbar APIs）；visionOS 用系統固定的 glass 材質，不可自訂。

## 系統元件的自動採用與應檢查項目

用最新 SDK 重 build 後，逐項檢查：

- **Controls**：外形更圓潤（呼應硬體曲率）、新增 extra-large 尺寸。未寫死 layout metrics 就會自動更新；檢查是否有 hard-coded 尺寸。優先用新 button styles 而非自製 glass 按鈕——SwiftUI：`.buttonStyle(.glass)` / `.buttonStyle(.glassProminent)`。
- **Tab bar**：考慮讓 tab bar 依情境自動轉為 sidebar（SwiftUI：`.tabViewStyle(.sidebarAdaptable)`；UIKit：`UITabBarController.Mode.tabSidebar`）。iOS 可選擇捲動時自動縮小 tab bar、反向捲動時展開（SwiftUI：`.tabBarMinimizeBehavior(_:)`）。
- **Sidebar / inspector**：用標準 split view API 建立（SwiftUI：`NavigationSplitView` + `.inspector(...)`），取得跨平台一致行為與流暢的欄位 resize 動畫；檢查相鄰內容的 safe area。
- **Toolbar**：依「相似動作／影響同一介面區域」分組 toolbar items，跨平台維持一致分組與位置；共用背景的 items 之間用 fixed spacer 分隔（SwiftUI：`ToolbarSpacer(.fixed)`）。常用動作優先用標準 icon 而非文字；同一組背景內不要混用文字與 icon。隱藏 item 要隱藏整個 toolbar item 而非其內部 view（SwiftUI：`.hidden(_:)`），否則出現空白膠囊。清查自訂 spacer 與 custom items 是否與系統行為不一致。
- **Menus**：常用動作（Cut/Copy/Paste 等）使用標準 selector 以自動獲得 icon；contextual menu 頂部動作要與同一項目的 swipe actions 一致。
- **Sheets**：圓角加大；half sheet 內縮、與螢幕邊緣留縫讓內容透出，展開至全高時轉為較不透明。檢查 sheet 內部貼近圓角的內容、sheet 外側縫隙透出的內容是否如預期。移除加在 sheet／popover content view 上的自訂 visual effect 背景。
- **Action sheets**：從觸發它的元件位置彈出（不再固定從底部）。務必設定 source view / anchor（SwiftUI：`confirmationDialog` 附 source；UIKit：`popoverPresentationController.sourceView`）。
- **Lists / tables / forms**：row 高度與 padding 加大、section 圓角加大；section headers 改為 title-style capitalization（不再強制全大寫）——更新你提供的字串以符合系統慣例。SwiftUI：`.formStyle(.grouped)`。
- **Search**：iOS 點擊 search field 時欄位隨鍵盤上滑——測試行為與系統 App 一致。search 作為 tab 時使用語意化 API（SwiftUI：`Tab(role: .search)`），系統會將其分離並置於 trailing 端。
- **Windows（iPadOS）**：支援連續縮放至最小尺寸，不再是預設檔位間切換。支援任意視窗尺寸、用 split view 讓欄位流暢 reflow、正確設定 layout guides 與 safe areas 讓系統擺放視窗控制項。
- **App icon**：改用分層設計（前景／中景／背景），讓系統套用反射、折射、陰影、高光；提供 default（light）、dark、clear、tinted 四種外觀。用 Icon Composer 組層與預覽；元素置中避免被系統遮罩裁切。

## 自訂元件採用 Liquid Glass checklist

自訂元件確實需要 glass 效果時，逐項確認：

1. 先確認沒有標準元件可用——能用 `.buttonStyle(.glass)` 就不要手工 `.glassEffect()`。
2. 只套用在最重要的功能性元件；一個畫面出現多個自訂 glass 元件即是警訊。
3. 元件屬於 functional layer（浮在內容上），不在 content layer。
4. 選對 variant：文字多或背景複雜 → regular；媒體背景上的浮動控制 → clear（並判斷是否需要 35% dimming layer）。
5. 多個相鄰的自訂 glass 形狀放進同一個容器合併渲染，兼顧效能與形狀間的流體 morph 動畫。SwiftUI：`GlassEffectContainer`；UIKit：`UIGlassEffect`。
6. 形狀與容器同心（concentric）：圓角呼應視窗／螢幕曲率，與系統元件對齊。SwiftUI：`ConcentricRectangle`。
7. 內容會捲到元件底下時，註冊 scroll edge effect。
8. 用 Reduce Transparency、Increase Contrast、Reduce Motion 以及使用者的 Liquid Glass 偏好外觀設定逐一測試。
9. 深色／淺色背景、Dark Mode 下檢查前景可讀性；上層文字圖示用 vibrant colors。
10. 效能剖析（profile）：glass 是即時渲染效果，重 build 後跨裝置實測。

## 常見錯誤

- 把 `.glassEffect()` 套在內容卡片、列表 cell、App 背景上——glass 只屬於 functional layer；內容層用 standard materials。
- 給 tab bar / toolbar / navigation bar 加自訂背景色或 background image，蓋掉系統 glass 與 scroll edge effect。
- 在純色或一般 UI 背景上使用 clear variant，導致文字對比不足；clear 只配媒體背景。
- 在亮色媒體背景上用 clear 卻忘了 35% dimming layer。
- 為了「品牌感」把多個自訂按鈕全部套 glass，畫面充滿玻璃元件、內容反而失焦。
- 相鄰的自訂 glass 元件各自獨立渲染，未放進 `GlassEffectContainer`——效能差且失去 morph 動畫。
- 只在預設設定下驗收，未測 Reduce Transparency / Increase Contrast / Reduce Motion 與使用者的 Liquid Glass 偏好外觀。
- Toolbar 用「隱藏 item 內的 view」來藏按鈕，留下空白 glass 膠囊；應隱藏整個 toolbar item。
- Section header 字串仍是手動全大寫（如 "SETTINGS"），與系統的 title-style capitalization 慣例衝突。
- 長期保留 `UIDesignRequiresCompatibility` 相容模式，拖延遷移。

## API 速查

| 用途 | SwiftUI | UIKit |
|---|---|---|
| 對 view 套用 Liquid Glass | `.glassEffect(_:in:)` | `UIGlassEffect` + `UIVisualEffectView` |
| 合併多個 glass 形狀／morph | `GlassEffectContainer` | — |
| Glass 按鈕 | `.buttonStyle(.glass)` / `.glassProminent` | `UIButton.Configuration.glass()` / `.prominentGlass()` / `.clearGlass()` / `.prominentClearGlass()` |
| Scroll edge effect | `.scrollEdgeEffectStyle(_:for:)` | `UIScrollEdgeElementContainerInteraction` |
| Background extension | `.backgroundExtensionEffect()` | `UIBackgroundExtensionView` |
| 同心圓角形狀 | `ConcentricRectangle` | corner configuration APIs |
| Tab bar ↔ sidebar 自適應 | `.tabViewStyle(.sidebarAdaptable)` | `UITabBarController.Mode.tabSidebar` |
| Content layer 的 standard material | `.background(.ultraThinMaterial / .thinMaterial / .regularMaterial / .thickMaterial)` | `UIBlurEffect` / `UIVibrancyEffect` |
| 暫緩採用新設計（過渡用） | Info.plist：`UIDesignRequiresCompatibility` | 同左 |

## 版本與變更紀錄

- Liquid Glass 於 iOS 26（2025-06 WWDC）引入；HIG Materials 頁於 2025-06-09 新增 Liquid Glass 指引、2025-09-09 更新指引（正式版行為，包含 variant 與 dimming layer 細節、content layer 例外的釐清）。
- iOS 26.x 起使用者可在裝置設定中選擇 Liquid Glass 的偏好外觀（官方稱「preferred look」，影響 regular/clear 的實際呈現）；App 端不需也不應偵測此設定，只需確保各外觀下皆可讀。
- 目前抓取的官方 HIG 與 Technology Overviews 內容為版本無關（version-agnostic）寫法，未列出 iOS 27 專屬的行為變更；遵循「使用標準元件 + 最新 SDK 重 build」即可自動取得後續調整。
- `UIDesignRequiresCompatibility` 為過渡期相容模式，僅供分階段遷移使用，勿長期依賴。
