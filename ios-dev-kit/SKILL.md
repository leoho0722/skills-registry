---
name: ios-dev-kit
description: Leo Ho 個人的 iOS/macOS Swift 開發規範，涵蓋 coding style（命名、存取控制、optional 與錯誤處理）、code formatting 排版（縮排、換行、MARK 分區、import 排序）、新檔案的 file template 與專案目錄結構。Use when writing, modifying, or reviewing any Swift / SwiftUI / UIKit code, creating new Swift files or iOS projects, or when the user mentions coding style、排版、格式、命名規則、檔案樣板、專案結構、code review、Swift 慣例。
metadata:
  - author: "Leo Ho"
  - version: "2026-09"
---

# iOS Dev Kit：個人 Swift 開發規範

寫、改或審任何 Swift 程式碼、建立新檔案或新專案時套用。本 skill 集中 Leo Ho 所有個人 iOS 開發要求，從專案目錄結構到單一檔案的內容與格式。

## 使用方式

1. 先讀本檔的「不可違反的鐵則」。
2. 依當前任務查下方導覽表，只載入相關的 reference 檔，不要全部讀入。
3. 產出或修改程式碼後，逐條對照相關 reference 的「要／避免」自檢。

## Reference 導覽

| 任務情境 | 讀這份 |
|---|---|
| 命名、存取控制、optional 處理、error handling、註解與 doc comment | [references/coding-style.md](references/coding-style.md) |
| 縮排、換行、參數對齊、`// MARK:` 分區順序、import 排序、空行規則 | [references/formatting.md](references/formatting.md) |
| 建立新 Swift 檔案、決定用哪個樣板、樣板內各區塊的填寫規則 | [references/file-templates.md](references/file-templates.md) |
| 新專案目錄結構、分層方式、新增 Feature 模組時該建哪些資料夾 | [references/project-structure.md](references/project-structure.md) |

樣板實體檔案放在 [assets/templates/](assets/templates/)，依 `presentation/`、`domain/`、`data/`、`core/`、`tests/` 分層；建新檔時先查 `file-templates.md` 的樣板選擇表取得路徑，直接複製再替換佔位符，不要憑記憶重寫。

## 不可違反的鐵則

<!-- TODO：填入你最在意、違反即視為 blocker 的規則。以下為範例格式，請替換。 -->

1. **新檔案一律從 `assets/templates/` 的樣板複製**，不得手寫骨架。
2. **不使用強制解包 `!`**，除非是 `IBOutlet` 或有註解說明的不變量。
3. **所有型別與成員都明確標示存取控制**，預設 `private`，只在需要時放寬。
4. **一個檔案只放一個主要型別**，extension 依 `formatting.md` 的分區順序排列。
5. **公開 API 必須有 doc comment（`///`）**，內部實作只在「為什麼」不明顯時加註解。

## 工作流程

### 建立新專案或新增 Feature 模組

1. 讀 `project-structure.md` 建立資料夾與分層。
2. 每個需要的檔案依下方「建立新檔案」流程從樣板產生。

### 建立新檔案

1. 讀 `file-templates.md` 決定樣板類型。
2. 複製 `assets/templates/` 對應檔案，替換所有 `__PLACEHOLDER__` 佔位符。
3. 刪除沒用到的空 MARK 區塊與空 extension；樣板保留它們只是作為插槽，實際檔案不留空區塊（見 `formatting.md`）。
4. 對照 `coding-style.md` 命名；對照 `formatting.md` 確認分區順序與排版。

### 修改既有檔案

1. 沿用該檔案既有的分區與排版，不順手重排無關區塊。
2. 新增的程式碼依 `coding-style.md` 與 `formatting.md` 撰寫。
3. 若既有程式碼違反鐵則且與本次修改相關，一併修正並在回覆中說明；無關的違規只回報不動手。

### Code review

1. 逐條檢查「不可違反的鐵則」，違反即列為 blocker。
2. 依變更內容載入對應 reference，輸出「違反規範／建議改善」兩級清單，每條附具體修法。
3. 排版問題集中列在最後，不與邏輯問題混雜。
