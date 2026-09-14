---
name: ios-dev-kit
description: Leo Ho 個人的 iOS/macOS Swift 開發規範，涵蓋 coding style（命名、存取控制、optional、error handling、concurrency、doc comment）、code formatting 排版（縮排、換行、MARK 分區、import 排序、SwiftUI body）、新檔案的 file template（View、ViewModel、Coordinator、Service、Mock、測試）、專案目錄結構（Feature-first 分層、A/B/C 三種 SPM package 方案、DesignSystem、測試目錄）與 TCA（The Composable Architecture）專案的 Reducer、導航、DependencyKey、TestStore 規範。Use when writing, modifying, or reviewing any Swift / SwiftUI / UIKit code, creating new Swift files, Features, or iOS projects, or when the user mentions coding style、排版、格式、命名規則、檔案樣板、專案結構、SPM package、Coordinator、依賴注入、單元測試、code review、Swift 慣例、TCA、Composable Architecture、Reducer、Store、TestStore、@Dependency。
metadata:
  author: "Leo Ho"
  version: "1.1.2"
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
| 命名、存取控制、型別選擇、optional 處理、error handling、concurrency、註解與 doc comment | [references/coding-style.md](references/coding-style.md) |
| 縮排、換行、參數對齊、空行規則、`// MARK:` 分區順序與 protocol 遵循位置、import 排序、closure、SwiftUI body 排版 | [references/formatting.md](references/formatting.md) |
| 建立新 Swift 檔案、決定用哪個樣板、View / ViewModel / Coordinator / Service / Mock / 測試各樣板的填寫規則、依賴注入 | [references/file-templates.md](references/file-templates.md) |
| 新專案目錄結構、A / B / C 方案的選擇與偵測、分層與依賴方向、Feature 模組結構、DesignSystem、測試目錄 | [references/project-structure.md](references/project-structure.md) |
| TCA 專案：Reducer（Feature 型別）的分區與 Action 分組、Path / Destination 導航、DependencyKey 註冊、@Shared、TestStore 測試、MVVM 與 TCA 的對應 | [references/tca-architecture.md](references/tca-architecture.md) |

樣板實體檔案放在 [assets/templates/](assets/templates/)，依 `presentation/`、`domain/`、`data/`、`core/`、`tests/`、`tca/` 分層；建新檔時先查 `file-templates.md` 的樣板選擇表取得路徑，直接複製再替換佔位符，不要憑記憶重寫。

## 不可違反的鐵則

違反任一條即為 blocker，review 時第一輪就擋；細節與例外的完整說明在對應的 reference。

1. **新檔案一律從 `assets/templates/` 的樣板複製**，替換全部佔位符並刪除未用的空插槽；不得手寫骨架。（`file-templates.md`）
2. **所有宣告一律有 `///`，無例外**：有參數寫 `- Parameter`、有回傳寫 `- Returns`、會 throw 寫 `- Throws`；白話且精簡。（`coding-style.md` 註解一節）
3. **禁止 `!`、`try!`、`as!`**，只有兩個例外：`IBOutlet` 的隱式解包，以及 `static let` 中左側完全由字面值組成的強制解包。（`coding-style.md` Optional 一節）
4. **單元測試一律 Swift Testing，UI Test 才用 XCTest**；測試本體 Given / When / Then。（`file-templates.md` tests 一節）
5. **async/await 是唯一的非同步模型**：禁 GCD、自建 Combine pipeline、`Task.detached`、`nonisolated(unsafe)`；`@unchecked Sendable` 只允許 Mock 與包裝非 Sendable 的第三方物件。（`coding-style.md` Concurrency 一節）
6. **分層依賴單向**：Presentation → Domain ← Data，三者皆可依賴 Core；Service 不依賴同層 Service；跨 Feature 只引用對方 Domain 的 Model 與 Error；不得補 Repository / Interactor / Presenter。TCA 專案的 Presentation 依 `tca-architecture.md`，其餘不變。（`project-structure.md` 分層原則）
7. **Service / Client / Store / Database 的 protocol 一律 `Sendable` 加 typed throws**，以 init 注入且不給預設值；禁 `.shared` 與 DI container。唯一例外是 TCA 專案以 `DependencyKey` 註冊、Feature 型別以 `@Dependency` 取用，Service 本身仍 init 注入。（`file-templates.md` Service 一節、`tca-architecture.md` 依賴注入）
8. **View 的 `body` 只放大框架**，內容抽到 Private Views；View 不寫格式化與業務邏輯，格式化用 `FormatStyle`，業務邏輯在 ViewModel，TCA 專案在 Feature 型別。（`file-templates.md` View 一節）
9. **MARK 六區順序固定**，protocol 遵循放獨立 extension；View、Coordinator、FormatStyle 與 TCA Feature 型別的型別專屬分區依各自樣板，不自創分區名稱；縮排 4 格、行寬 100、無尾隨空白。（`formatting.md`、`tca-architecture.md` 分區順序）
10. **專案結構方案由使用者決定**：新專案先問 A / B / C，既有專案偵測後請使用者確認；agent 不自行決定。（`project-structure.md` 方案判斷）
11. **Presentation 架構由使用者決定：MVVM + Coordinator 或 TCA 二選一，一個專案只用一種**；TCA 專案不得出現 ViewModel、Coordinator、`@Entry`，MVVM 專案不得出現 `@Reducer`。（`tca-architecture.md` 定位與用語）

## 工作流程

### 建立新專案

1. **先問使用者要採用哪種專案結構方案**，三選一：A 單一 App target、B 底層抽成 local package、C 每個 Feature 一個 package。每個選項附一句適用情境（見 `project-structure.md` 的「方案選擇」表），沒有特殊需求時建議 A。不要自行決定。
2. **接著問 Presentation 架構**，二選一：MVVM + Coordinator（預設，樣板在 `presentation/`）或 TCA（樣板在 `tca/`，規則見 `tca-architecture.md`）。不要自行決定。
3. 依所選方案讀 `project-structure.md` 對應一節建立根目錄、`Package.swift` 與分層資料夾。
4. 每個需要的檔案依下方「建立新檔案」流程從樣板產生；B、C 方案依該節規則補 `public` 與 `@Entry`（TCA 專案為 `DependencyKey`）位置。

### 新增 Feature 模組

1. 先依 `project-structure.md` 的「方案判斷」偵測既有專案目前是 A、B 還是 C，**把偵測結果與依據告訴使用者，請使用者確認或改選**；偵測只是建議值，決定權在使用者。
2. 偵測 Presentation 架構：有 `import ComposableArchitecture` 即為 TCA 專案，一併告知使用者。
3. 依該方案的「Feature 模組結構」建立資料夾；TCA 專案改依 `tca-architecture.md` 的「Feature 模組結構」。
4. 每個需要的檔案依下方「建立新檔案」流程從樣板產生。

### 建立新檔案

1. 讀 `file-templates.md` 決定樣板類型；TCA 專案的 Feature 型別、View、DependencyKey 與 Feature 測試改用 `tca/` 樣板，選擇表見 `tca-architecture.md`。
2. 複製 `assets/templates/` 對應檔案，替換所有 `__PLACEHOLDER__` 佔位符。
3. 刪除沒用到的空 MARK 區塊與空 extension；樣板保留它們只是作為插槽，實際檔案不留空區塊（見 `formatting.md`）。
4. 所有宣告補上 `///`，樣板示範成員的說明一併改寫（見 `coding-style.md` 註解一節）。
5. 對照 `coding-style.md` 命名；對照 `formatting.md` 確認分區順序與排版。

### 修改既有檔案

1. 沿用該檔案既有的分區與排版，不順手重排無關區塊。
2. 新增的程式碼依 `coding-style.md` 與 `formatting.md` 撰寫。
3. 若既有程式碼違反鐵則且與本次修改相關，一併修正並在回覆中說明；無關的違規只回報不動手。

### Code review

1. 逐條檢查「不可違反的鐵則」，違反即列為 blocker。
2. 依變更內容載入對應 reference，以各 reference 檔末的「常見錯誤檢查清單」逐項對照，輸出「違反規範／建議改善」兩級清單，每條附具體修法。
3. 排版問題集中列在最後，不與邏輯問題混雜。
