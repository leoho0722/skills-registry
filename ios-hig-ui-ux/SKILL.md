---
name: ios-hig-ui-ux
description: 依 Apple Human Interface Guidelines（HIG，Liquid Glass 世代，涵蓋 iOS 26/27）提供 iOS/iPadOS App 的 UI/UX 交互設計最佳實踐。Use when designing, implementing, or reviewing iOS app UI/UX — 包括畫面版面與自適應、導航結構（tab bar/sheet/alert）、元件選用、手勢與輸入、Liquid Glass 與視覺樣式、無障礙，以及 onboarding/通知/設定等 UX patterns；或當使用者提到 HIG、Apple 設計規範、Liquid Glass、iOS 設計審查時。
metadata: 
  - author: "Apple Human Interface Guidelines"
  - source: "https://developer.apple.com/design/human-interface-guidelines/"
  - license: "https://developer.apple.com/terms/"
  - version: "2026-06"
---

# iOS HIG UI/UX 最佳實踐

依據 Apple Human Interface Guidelines 最新規範（Liquid Glass 設計語言，iOS 26 引入、iOS 27 調整）整理的 iOS/iPadOS UI/UX 交互指南。設計、實作或審查 iOS App UI 時使用。

## 使用方式

1. 先讀本檔的「不可違反的鐵則」與「核心設計原則」。
2. 依當前任務查下方導覽表，只載入相關的 reference 檔，不要全部讀入。
3. 產出 UI 程式碼或設計審查意見時，逐條對照相關 reference 的「要／避免」。

## Reference 導覽

| 任務情境 | 讀這份 |
|---|---|
| 使用 Liquid Glass、materials、自訂控制項外觀 | [references/liquid-glass.md](references/liquid-glass.md) |
| 色彩、深色模式、字型、SF Symbols、app icon、文案 | [references/visual-foundations.md](references/visual-foundations.md) |
| 版面配置、safe area、自適應、iPad 多工、捲動 | [references/layout.md](references/layout.md) |
| 導航結構、tab bar、搜尋、sheet/alert/popover | [references/navigation.md](references/navigation.md) |
| 手勢、觸控目標、鍵盤輸入、haptics、拖放、undo | [references/interaction.md](references/interaction.md) |
| 選用與使用按鈕、選單、清單、picker 等元件 | [references/components.md](references/components.md) |
| 啟動、onboarding、載入、錯誤回饋、設定、通知、評分、帳號、widget | [references/ux-patterns.md](references/ux-patterns.md) |
| VoiceOver、Dynamic Type、對比、Reduce Motion、RTL | [references/accessibility.md](references/accessibility.md) |

多數 UI 任務至少涉及 2–3 份（例如新畫面 = layout + navigation + components）。無障礙適用於所有任務，審查時一律納入。

## 核心設計原則（HIG 八大原則，2026-06 版）

- **Purpose**：先確認畫面要幫使用者完成什麼，砍掉不服務該目的的元素。
- **Agency**：讓人用自己的方式操作——可跳過、可返回、可復原，不鎖流程。
- **Responsibility**：最小化資料收集，請求權限前先說明理由，透明可信。
- **Familiarity**：建立在人們已知的系統慣例上；同一行為全 App 一致。
- **Flexibility**：適應各種情境——裝置尺寸、方向、Dynamic Type、多種輸入方式。
- **Simplicity**：只留必要之物；清楚的層級勝過裝飾；文案精確簡潔。
- **Craft**：細節決定品質——對齊、動畫、措辭、音效都要刻意為之。
- **Delight**：情感體驗來自整體用心，不是來自堆疊裝飾；別讓趣味妨礙任務。

## 不可違反的鐵則

1. **觸控目標最小 44x44 pt**；並排控制項之間留足間距。
2. **優先使用系統標準元件與慣例**，自訂前先確認沒有現成元件可用；自訂元件必須跟隨系統行為（Dynamic Type、dark mode、無障礙）。
3. **Liquid Glass 只用於浮在內容之上的 functional layer**（導航、控制項）；絕不放進 content layer，也不要玻璃疊玻璃。
4. **所有文字用系統 text styles 並支援 Dynamic Type**，任何尺寸下不截斷、不重疊。
5. **尊重 safe area 與系統手勢區**；內容可延伸到螢幕邊緣，但控制項不侵入。
6. **不只靠顏色傳達資訊**；文字對比至少 4.5:1；使用 semantic colors 自動適配 dark mode。
7. **Modal 要克制**：只在需要聚焦或阻斷時使用；能用 push 就不用 modal；破壞性動作前必先確認。
8. **每個手勢都要有可見的替代操作**；不覆寫系統手勢。
9. **權限請求要有情境**：在使用者做出相關動作時才請求，並先說明用途。
10. **回饋即時且克制**：操作要有立即回應；錯誤訊息說明「發生什麼＋怎麼辦」，不責怪使用者。

## 工作流程

### 設計／實作新畫面

1. 定義畫面目的與主要任務（Purpose），列出必要元素。
2. 讀 `layout.md` + `navigation.md` 決定結構；確認在 iPhone/iPad、直橫向、Dynamic Type 最大級距下都成立。
3. 讀 `components.md` 為每個互動選擇標準元件；需要自訂外觀時再讀 `liquid-glass.md` 與 `visual-foundations.md`。
4. 讀 `interaction.md` 確認觸控目標、鍵盤與手勢行為。
5. 對照 `accessibility.md` 補齊 VoiceOver 標籤與各項系統設定的因應。

### 審查現有 UI

1. 逐條檢查「不可違反的鐵則」，違反即列為 blocker。
2. 依畫面涉及的領域載入對應 reference，輸出「違反規範／建議改善」兩級清單，每條附 HIG 依據與具體修法。
3. 以 Simplicity 與 Craft 收尾：找出可刪除的元素與不一致的細節。
