# Code Formatting（排版規則）

Leo Ho 個人 Swift 排版規範，版本 2026-09。若專案有 `.swiftformat` 或 `.swift-format` 設定檔，以設定檔為準；本檔補充設定檔無法表達的規則。

## 目錄

- [基本設定](#基本設定)
- [換行與斷行](#換行與斷行)
- [參數與引數對齊](#參數與引數對齊)
- [空行規則](#空行規則)
- [MARK 分區與順序](#mark-分區與順序)
- [Import 排序](#import-排序)
- [Closure 與 Trailing Closure](#closure-與-trailing-closure)
- [SwiftUI View Body 排版](#swiftui-view-body-排版)
- [常見錯誤檢查清單](#常見錯誤檢查清單)

## 基本設定

<!-- TODO：縮排（空格數）、每行長度上限、檔尾換行、尾隨空白、大括號位置。 -->

| 項目 | 規則 |
|---|---|
| 縮排 | |
| 每行長度上限 | |
| 單檔長度上限 | 300 行（不含檔頭與空行）；超過時依 `file-templates.md` 的規則以 extension 分檔，不放寬上限 |
| 大括號 | |
| 檔尾 | |

## 換行與斷行

<!-- TODO：超過長度上限時的斷行位置、運算子放行首或行尾、長條件式的排法。 -->

- **要**：
- **避免**：

## 參數與引數對齊

<!-- TODO：多參數函式宣告與呼叫的換行方式、每個參數一行的門檻、右括號位置。 -->

```swift
// 範例：請替換為你的規則
func fetch(
    id: String,
    includeDetails: Bool = false
) async throws -> Item
```

## 空行規則

<!-- TODO：型別成員之間、MARK 前後、import 與第一個宣告之間、函式內邏輯區塊之間的空行數。 -->

- **要**：
- **避免**：

## MARK 分區與順序

<!-- TODO：填入每種型別內部的固定分區順序。以下為範例，請替換。 -->

型別本體只放 stored properties 與 Init，其餘一律以同檔 extension 分區，每區以 `// MARK: - <區名>` 開頭，順序固定：

1. Properties（型別本體內，只放 stored properties；SwiftUI View 的 `body` 另立 `Body` 區，緊接在 Init 之後）
2. Init（型別本體內）
3. Nested Types（extension；只放此型別專屬的 enum / struct / class，判斷標準見 `file-templates.md`）
4. Computed Properties（extension；所有 computed properties 不論存取層級都放這裡，不放型別本體）
5. Internal Method（extension）
6. Private Method（`private extension`）

用不到的區塊直接省略，不留空的 MARK；順序不可調換。Protocol 遵循各自獨立一個 extension，以 protocol 名稱作為 MARK 名稱（例如 `// MARK: - __NAME__ServiceProtocol`），排在 Computed Properties 之後、Internal Method 之前。

型別專屬的額外分區（View 的 `Body`、`Private Views`、`Preview`，Coordinator 與流程型 Coordinator 的 `Destinations`，FormatStyle 的 `Convenience`）以各樣板為準，位置見 `file-templates.md` 對應一節；不自創其他分區名稱。

Extension 的使用時機與順序：

- **要**：
- **避免**：

## Import 排序

<!-- TODO：排序規則（字母序？系統 framework 優先？）、@testable import 位置、是否允許 import 整個模組以外的形式。 -->

- **要**：
- **避免**：

## Closure 與 Trailing Closure

<!-- TODO：何時用 trailing closure、多個 closure 參數的排法、closure 內參數命名（$0 的使用上限）。 -->

- **要**：
- **避免**：

## SwiftUI View Body 排版

<!-- TODO：modifier 一行一個、modifier 順序、子 View 抽取的門檻（行數／層數）、@ViewBuilder 私有屬性的命名。 -->

- **要**：
- **避免**：

## 常見錯誤檢查清單

- [ ]
- [ ]
