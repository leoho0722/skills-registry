---
name: android-dev-kit
description: Leo Ho 個人的 Android Kotlin 開發規範，全部對齊 Kotlin 官方 coding conventions、Google Android Kotlin style guide、Android 架構指南與 Now in Android。涵蓋 coding style（命名、存取控制、null safety、以 Outcome 表達的 error handling、Coroutines 與 Flow、KDoc）、code formatting（ktlint android_studio、.editorconfig、宣告排列順序、import、Compose 排版）、新檔案的 file template（Screen、ViewModel、UiState、Navigation 3 的 NavKey / EntryProvider / Navigator、Repository、data source、UseCase、Hilt module、Fake、測試）與專案目錄結構（UI / domain / data 分層、A/B/C 三種 Gradle module 方案、api / impl、DesignSystem、測試目錄）。Use when writing, modifying, or reviewing any Kotlin / Jetpack Compose / Android code, creating new Kotlin files, Features, or Android projects, or when the user mentions coding style、排版、格式、命名規則、檔案樣板、專案結構、Gradle module、ViewModel、UiState、Repository、UseCase、Navigation 3、Hilt、依賴注入、Coroutines、Flow、單元測試、UI 測試、ktlint、code review、Kotlin 慣例。
metadata:
  author: "Leo Ho"
  version: "1.0.0"
---

# Android Dev Kit：個人 Kotlin 開發規範

寫、改或審任何 Kotlin / Android 程式碼、建立新檔案或新專案時套用。本 skill 集中 Leo Ho 所有個人 Android 開發要求，從專案目錄結構到單一檔案的內容與格式。每條規則都以 Kotlin 官方、Google 官方文件或官方範例（Now in Android、nav3-recipes）為依據；架構為 Jetpack Compose 加官方建議的 UI / domain / data 分層，導航用 Navigation 3，注入用 Hilt。

## 使用方式

1. 先讀本檔的「不可違反的鐵則」。
2. 依當前任務查下方導覽表，只載入相關的 reference 檔，不要全部讀入。
3. 產出或修改程式碼後，逐條對照相關 reference 的「要／避免」自檢，並跑 `./gradlew ktlintFormat`。

## Reference 導覽

| 任務情境 | 讀這份 |
|---|---|
| 命名（Repository、DataSource、UseCase、Fake、泛型、縮寫、常數）、存取控制、型別選擇、extension、null safety、`Outcome` 與 error handling、Coroutines 與 Flow、KDoc | [references/coding-style.md](references/coding-style.md) |
| ktlint `android_studio` 與 `.editorconfig`、換行、參數與 trailing comma、空行、宣告的排列順序、annotation、import、lambda、Compose 排版 | [references/formatting.md](references/formatting.md) |
| 建立新 Kotlin 檔案、決定用哪個樣板、Screen / ViewModel / NavKey / EntryProvider / AppNavHost / Repository / UseCase / Hilt module / Fake / 測試各樣板的填寫規則、狀態產生方式、一次性事件、多步驟流程 | [references/file-templates.md](references/file-templates.md) |
| 新專案目錄結構、A / B / C 方案的選擇與偵測、分層與依賴方向、package 與 module 命名、convention plugin、Feature 結構、DesignSystem、測試目錄、Gradle 設定 | [references/project-structure.md](references/project-structure.md) |

樣板實體檔案放在 [assets/templates/](assets/templates/)，依 `feature/`、`app/`、`core/<module>/`、`tests/`、`project/` 分類；建新檔時先查 `file-templates.md` 的樣板選擇表取得路徑與 package，直接複製再替換佔位符，不要憑記憶重寫。

## 不可違反的鐵則

違反任一條即為 blocker，review 時第一輪就擋；細節與例外的完整說明在對應的 reference。

1. **新檔案一律從 `assets/templates/` 的樣板複製**，替換全部佔位符後跑 `ktlintFormat`；不得手寫骨架。（`file-templates.md`）
2. **所有宣告一律有 KDoc**，格式依官方：摘要以句號結尾，參數與回傳以 `[名稱]` 連結併入內文，`@param`／`@return` 只在描述太長時使用。（`coding-style.md` 註解一節）
3. **禁止 `!!`、不安全的 `as`、`runCatching` 系列、吞掉 `CancellationException` 的廣泛 catch**；`lateinit` 只用於依賴注入與測試 setup。（`coding-style.md`）
4. **單元測試一律 JUnit 4 加 `kotlin.test`，UI 測試用 Compose UI test（`junit4.v2`）**；測試替身手寫 `Fake<Name>`，禁 MockK / Mockito；UI 測試優先以文字與 contentDescription 找元件；測試本體 Given / When / Then。（`file-templates.md` tests 一節）
5. **Coroutines 與 Flow 是唯一的非同步模型**：禁 RxJava、LiveData、`GlobalScope`、`runBlocking`、寫死 `Dispatchers.IO`；做阻塞或大量計算的類別自己以注入的 dispatcher `withContext`；ViewModel 的 `init` 不啟動非同步工作。（`coding-style.md` Concurrency 一節）
6. **分層依官方**：UI → domain（選用）→ data；Repository 依資料類型切分、可依賴其他 Repository；ViewModel 與 UseCase 不直接使用 data source；不得使用 Service / Client / Store、Presenter、Interactor 等非官方名稱或層。（`project-structure.md` 分層原則）
7. **資料層一律 Repository（interface 加有意義名稱的實作）與 data source**，可能失敗的操作回傳 `Outcome<T, <資料類型>Error>`；一律 Hilt 建構子注入，綁定寫在 `DataModule` 等清單；UseCase 是具體 class。（`file-templates.md` core/data、core/domain）
8. **畫面依 Now in Android 寫成同名的有狀態與無狀態 `<Screen>Screen`**：無狀態版本只收 `uiState`、每個事件一個 lambda、`modifier`；ViewModel 每個事件一個動詞方法，不用單一 `onAction`；UiState 放原始型別，一次性事件表達成 UiState 欄位。（`file-templates.md` feature 一節）
9. **整個 App 只有一個 `NavDisplay`**：導航只經由 `Navigator` 與各 Feature 的 `navigateTo…()` 函式，Feature 以 `<feature>Entry(navigator)` 註冊畫面，NavKey 一律 `@Serializable`；多步驟流程由 NavKey 帶資料，不另建共用 ViewModel。（`file-templates.md` 導航一節）
10. **排版以 Google Android Kotlin style guide 為準**，以 ktlint `android_studio`（1.8.0 以上）檢查；宣告依 Kotlin 官方 class layout 排列，不依可見度分組、不用 `// region`。（`formatting.md`）
11. **專案結構方案由使用者決定**：新專案先問 A / B / C，既有專案偵測後請使用者確認；agent 不自行決定。（`project-structure.md` 方案判斷）

## 工作流程

### 建立新專案

1. **先問使用者要採用哪種專案結構方案**，三選一：A 單一 `:app`、B core 抽成 module、C Feature 也抽成 api / impl module。每個選項附一句適用情境（見 `project-structure.md` 的「方案選擇」表），沒有特殊需求時建議 A。不要自行決定。
2. 問使用者 `minSdk`（至少 26）與根 package。
3. 依所選方案讀 `project-structure.md` 對應一節，建立 `settings.gradle.kts`、`gradle/libs.versions.toml`（`project/libs.versions.toml`，版本查當下最新穩定版）、`.editorconfig`（`project/.editorconfig`）與各 module 的 `build.gradle.kts`；B、C 另建 `build-logic/`。
4. 建立每個專案一份的檔案：`core/common/Outcome.kt`、`core/common/DispatchersModule.kt`、`core/navigation/Navigator.kt`、`core/data/DataModule.kt`、`core/designsystem/AppTheme.kt`、`ui/AppNavHost.kt`、`core/testing/MainDispatcherRule.kt`、`HiltTestRunner.kt`、`TestDataModule.kt`，以及 `<App>Application`、`MainActivity`（`project-structure.md` 的「App 層」）。
5. 每個需要的檔案依下方「建立新檔案」流程從樣板產生，最後跑 `./gradlew ktlintFormat` 與 `./gradlew testDebugUnitTest` 確認能建置。

### 新增 Feature

1. 先依 `project-structure.md` 的「方案判斷」偵測既有專案目前是 A、B 還是 C，**把偵測結果與依據告訴使用者，請使用者確認或改選**。
2. 依「Feature 結構」建立最小四個檔案：Screen、ViewModel、NavKey、EntryProvider；方案 C 另建 `:feature:<feature>:api` 與 `:impl` 並加進 `settings.gradle.kts` 與 `:app` 的依賴。
3. 在 `AppNavHost` 的 `entryProvider` 加一行 `<feature>Entry(navigator)`。
4. Feature 需要新的資料時，在 `core/` 新增 Model、錯誤型別、Repository、data source，並在 `DataModule`、`TestDataModule` 各加一行，另建對應的 Fake。

### 建立新檔案

1. 讀 `file-templates.md` 決定樣板類型、package 與 source set（`main`、`test`、`testFixtures` 或 `:core:testing`、`androidTest`）。
2. 複製 `assets/templates/` 對應檔案，替換所有 `__PLACEHOLDER__` 佔位符。
3. 改寫樣板示範成員的 KDoc（見 `coding-style.md` 註解一節）。
4. 跑 `./gradlew ktlintFormat`，再對照 `coding-style.md` 命名與 `formatting.md` 的排列順序。

### 修改既有檔案

1. 沿用該檔案既有的排列與排版，不順手重排無關區塊。
2. 新增的程式碼依 `coding-style.md` 與 `formatting.md` 撰寫。
3. 若既有程式碼違反鐵則且與本次修改相關，一併修正並在回覆中說明；無關的違規只回報不動手。

### Code review

1. 逐條檢查「不可違反的鐵則」，違反即列為 blocker。
2. 依變更內容載入對應 reference，以各 reference 檔末的「常見錯誤檢查清單」逐項對照，輸出「違反規範／建議改善」兩級清單，每條附具體修法與官方依據。
3. 排版問題集中列在最後；ktlint 抓得到的只寫「跑 `ktlintFormat`」，不逐條列。
