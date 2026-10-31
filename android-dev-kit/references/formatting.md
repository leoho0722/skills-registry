# Code Formatting（排版規則）

Leo Ho 個人 Kotlin 排版規範。**排版以 Google 的 [Android Kotlin style guide](https://developer.android.com/kotlin/style-guide) 為準**，以 ktlint 的 `android_studio` code style 自動檢查與修正（ktlint 官方：「This code style is based on Android's Kotlin styleguide」）；Android style guide 沒規定的部分依 Kotlin 官方 [Coding conventions](https://kotlinlang.org/docs/coding-conventions.html)。本檔只補充工具管不到的規則。專案已有 `.editorconfig` 或其他格式化設定時，以專案設定為準。

## 目錄

- [基本設定與工具](#基本設定與工具)
- [換行與斷行](#換行與斷行)
- [參數與引數](#參數與引數)
- [空行規則](#空行規則)
- [宣告的排列順序](#宣告的排列順序)
- [Annotation](#annotation)
- [Import](#import)
- [Lambda](#lambda)
- [Compose 排版](#compose-排版)
- [常見錯誤檢查清單](#常見錯誤檢查清單)

## 基本設定與工具

| 項目 | 規則 | 依據 |
|---|---|---|
| 格式化工具 | ktlint，`ktlint_code_style = android_studio`，版本 1.8.0 以上；新專案複製 `assets/templates/project/.editorconfig` 到專案根目錄 | ktlint code styles |
| 縮排 | 4 個空格，續行也是 +4 | Android |
| 每行長度上限 | 100 字元（`android_studio` 預設） | Android |
| 大括號 | 開括號與宣告同行，閉括號單獨一行 | Android |
| 檔尾 | 保留一個換行 | `.editorconfig` |
| 尾隨空白 | 不允許 | `.editorconfig` |

`.editorconfig` 樣板只在 `android_studio` 之外多設兩項：

| 設定 | 原因 |
|---|---|
| `ij_kotlin_allow_trailing_comma = true` | Kotlin 官方鼓勵宣告端使用 trailing comma（encourage the use of trailing commas at the declaration site），Android style guide 未規定 |
| `ktlint_function_naming_ignore_when_annotated_with = Composable` | 讓回傳 `Unit` 的 composable 可以用 UpperCamelCase（Kotlin 官方與 Compose API guidelines 的例外）；有回傳值的 composable 仍用 lowerCamelCase，由 review 把關 |

- **要**：以 Gradle plugin `org.jlleitschuh.gradle.ktlint` 接上 ktlint，所有 module 套用，並以 `ktlint { version.set(...) }` 指定 ktlint 版本（plugin 的預設版本較舊）；commit 前跑 `./gradlew ktlintFormat`，CI 跑 `./gradlew ktlintCheck`。
- **要**：Android Studio 的 Settings → Editor → Code Style 保持 Enable EditorConfig support，Kotlin 的 Set from 選 Kotlin style guide；`android_studio` code style 與 Android Studio 內建的格式化結果相容，可以照常用 Reformat Code。
- **避免**：在程式碼內用 `@Suppress("ktlint:...")` 關掉規則；真的需要時同一行註解寫明理由。

## 換行與斷行

- **要**：整行放得下就不斷行；超過 100 字元才斷行（Kotlin 與 Android 都只在放不下時換行）。
- **要**：二元運算子（`&&`、`||`、`+`、`==`）與中綴函式在運算子**之後**斷行；`.`、`?.`、`::` 在符號**之前**斷行（Android）。`?:` 放在續行行首（ktlint `chain-wrapping`）。
- **要**：鏈式呼叫要斷行時，每個 `.` 或 `?.` 放在下一行開頭，縮排 4 格（Kotlin）。
- **要**：`if` / `while` 的條件放不下時，依 Kotlin 官方寫法：第一個條件接在 `if (` 之後，其餘條件縮排 4 格，右括號與 `{` 合成 `) {` 單獨一行。
- **要**：屬性的初始值或 expression body 太長時，在 `=` 之後斷行並縮排 4 格（Android、Kotlin）。
- **要**：函式本體只有一個表達式時用 expression body（`fun path(): String = ...`，Kotlin：Prefer using an expression body）。
- **要**：超過行寬的字串字面值單獨放一行：在 `=` 或具名引數的 `=` 之後斷行，字串放下一行；需要多行文字時用 `"""` 加 `trimIndent()`。字串無法再拆時才允許超過 100（Android：Lines where obeying the column limit is not possible）。
- **避免**：用 `+` 串接字串來壓行。

```kotlin
val isEligible =
    user.isVerified &&
        user.age >= 18 &&
        !user.isSuspended

val displayName = profile.nickname
    ?: profile.fullName

if (profile.isComplete &&
    !profile.isArchived &&
    profile.lastSyncedAt > threshold
) {
    showProfile(profile)
}

val visibleOrders = recentOrders
    .filter { it.isVisible }
    .take(maxVisibleCount)
```

## 參數與引數

- **要**：宣告放得下一行就寫一行；放不下時每個參數一行、縮排 4 格，右括號單獨一行，回傳型別接在右括號後（Kotlin、Android）。主建構子的屬性依 `coding-style.md` 各有 KDoc，因此一律每個一行。
- **要**：呼叫端放得下一行就寫一行；放不下時每個引數一行（ktlint `argument-list-wrapping` 要求全部或全不斷行）。
- **要**：斷成多行的**宣告**（參數、主建構子、enum entry 清單）最後一項加 trailing comma；**呼叫端**不加（`android_studio` 會移除，Kotlin 官方交由各專案決定）。
- **要**：同型別的多個基本型別參數，或 `Boolean` 參數，呼叫時用具名引數，除非從上下文就能完全看出意義（Kotlin）：`load(forceRefresh = true)`。
- **避免**：部分換行（前兩個引數同行、第三個換行）。

```kotlin
/** 取得 [id] 的個人資料，[forceRefresh] 為 true 時略過快取，失敗時為對應的 [ProfileError]。 */
suspend fun fetchProfile(id: UserId, forceRefresh: Boolean): Outcome<Profile, ProfileError>

/** 使用者識別碼，與其他識別碼型別不可互換。 */
@JvmInline
value class UserId(
    /** 伺服器給的原始字串。 */
    val value: String,
)

val request = buildRequest(
    endpoint = Endpoint.Profile,
    userId = session.currentUserId,
    cachePolicy = CachePolicy.ReloadIgnoringCache,
    timeout = 10.seconds
)
```

## 空行規則

| 位置 | 空行數 | 依據 |
|---|---|---|
| `package` 與 `import` 之間、`import` 與第一個宣告之間 | 1 | Android |
| 型別本體的開括號之後 | 1（Android 未規定；Kotlin 對多行標頭建議空一行，本規範一律空一行） | Kotlin |
| 型別本體的閉括號之前、函式本體的首尾 | 0 | Android |
| 成員之間（屬性、建構子、方法、nested type） | 1 | Android |
| enum entry 之間、sealed 子型別之間 | 1（每個都有 KDoc） | Android 允許 |
| `when` 的分支之間 | 全部分支都是單行時 0；只要有一個分支是多行，全部分支之間都 1 | ktlint `blank-line-between-when-conditions` |
| 函式內邏輯段落之間 | 最多 1 | Android |
| 測試本體的 `// When`、`// Then` 之前 | 1；`// Given` 寫在本體第一行，前面不空行 | 本規範 |

- **要**：`when` 的短分支寫在條件同一行、不加大括號（Kotlin：Put short branches on the same line as the condition, without braces）；多行的分支才用 `{ }`。
- **避免**：連續兩個以上空行。

```kotlin
/** 伺服器提供的各個資料端點。 */
enum class Endpoint {

    /** 使用者個人資料。 */
    Profile,

    /** 使用者的訂單清單。 */
    Orders,
    ;

    /** 端點在伺服器上的路徑，接在網域之後。 */
    val path: String
        get() = when (this) {
            Profile -> "/v1/profile"
            Orders -> "/v1/orders"
        }
}
```

## 宣告的排列順序

依 Kotlin 官方的 class layout，不使用 `// region` 分區：

1. 屬性與 `init` 區塊（`init` 依初始化順序需要，可以夾在屬性之間）。
2. 次要建構子。
3. 方法。
4. `companion object`。

- **要**：方法**不依可見度或字母排序**，相關的放在一起，讓人由上往下讀得懂流程（Kotlin：Do not sort the method declarations alphabetically or by visibility… put related stuff together）。本規範選「高層在前」：呼叫者在前、被呼叫的 helper 緊接在後；ViewModel 依畫面的使用順序排事件方法（載入 → 使用者操作 → 離開），每個事件方法用到的 private helper 緊接其後。
- **要**：overload 相鄰（Kotlin：Always put overloads next to each other）。
- **要**：實作 interface 的成員順序與 interface 的宣告順序一致，可以穿插實作用的 private 方法（Kotlin）；同一個 interface 的所有實作與 Fake 都照這個順序。
- **要**：nested class 放在使用它的程式碼附近；只給外部用、內部沒有引用的，放在 `companion object` 之後（Kotlin）。
- **要**：檔案有多個頂層宣告時，主要宣告在前，私有的輔助宣告在後：Screen 檔為有狀態的 Screen → 無狀態的 Screen → 私有 composable（依第一次出現的順序）→ 私有的 UI 計算函式 → `@Preview`；ViewModel 檔為 ViewModel → UiState。
- **要**：私有的輔助宣告歸哪一組只看回傳型別：回傳 `Unit` 的 `@Composable` 是私有 composable，包含從 Screen 抽出的內容，以及 `TopAppBar` 的 `actions` 這類抽出的內容；回傳 `Color`、`Dp`、`Modifier` 等值的函式（含有回傳值的 `@Composable`）是 UI 計算函式，即使結果是給 composable 用的。
- **避免**：`// region` / `// endregion` 分區；它常被用來依可見度或種類分組，與上面的原則衝突。

## Annotation

- **要**：宣告上的 annotation 放在 KDoc 之後、宣告之前，每個單獨一行（Android 允許不帶引數的 annotation 寫在同一行，本規範統一分行）：`@HiltViewModel`、`@Composable`、`@Test`、`@Binds` 都單獨一行。
- **要**：`@Inject constructor` 接在 class 名稱之後同一行：`class ProfileViewModel @Inject constructor(`。
- **要**：參數與主建構子屬性上的 annotation 和它同一行：`@IoDispatcher private val ioDispatcher: CoroutineDispatcher`、`@SerialName("user_id") val userId: UserId`。
- **要**：多個 annotation 時，框架要求的在前（`@HiltViewModel`、`@Module`、`@InstallIn`），`@Composable` 永遠緊貼函式宣告，`@Preview`、`@OptIn` 放在它之前。

## Import

- **要**：單一清單、依 ASCII 排序，中間不空行（Android）；`android_studio` 會自動排序。
- **要**：一行一個，不用 wildcard（Android：Wildcard imports (of any type) are not allowed）。
- **要**：移除不使用的 import；import alias 只在兩個同名型別必須在同一檔使用時才用（例如 Feature module 同時用自己的 `R` 與 `:core:designsystem` 的 `R`）。
- **避免**：`core/model`、`core/data`、`core/domain` import `androidx.compose.*`；ViewModel import `androidx.compose.*` 或 `android.content.Context`。
- **避免**：import 其他 Feature 的內部型別；跨 Feature 只透過對方公開的 NavKey 與導航函式（見 `project-structure.md`）。

## Lambda

- **要**：最後一個參數是 lambda 時用 trailing lambda。
- **要**：`it` 只用於簡短且沒有巢狀的 lambda；巢狀的 lambda 只要有參數，每一層都具名（Kotlin：In nested lambdas with parameters, always declare parameters explicitly）。
- **要**：不使用的參數寫 `_`；參數與 `->` 和 `{` 寫在同一行。
- **要**：lambda 只是把參數原封不動轉交給另一個函式時，改用 function reference：`onRetryClick = viewModel::retry`。
- **避免**：明確標註推斷得出的參數型別；在 lambda 內用多個 labeled return（Kotlin：Avoid using multiple labeled returns in a lambda），改寫成 `if` / `else` 或具名函式。
- **避免**：巢狀使用 scope function；`apply` 只用於設定物件、`also` 用於附加的副作用、`let` 用於 nullable 轉換。

## Compose 排版

依 [Compose API guidelines](https://android.googlesource.com/platform/frameworks/support/+/androidx-main/compose/docs/compose-api-guidelines.md)：

- **要**：`@Composable` 函式的參數順序為：必要參數 → `modifier: Modifier = Modifier`（第一個選用參數）→ 其他選用參數 → 最後一個是 composable lambda。有狀態的 Screen 把 `viewModel` 放在 `modifier` 之後。
- **要**：外部傳入的 `modifier` 只套用在最外層元件，且放在 chain 的第一個（`modifier.fillMaxSize()`）；內部元件從 `Modifier` 開始。
- **要**：modifier chain 依一般的鏈式呼叫規則排版；modifier 的順序會改變結果（`clickable` 在 `padding` 前或後，可點範圍不同），依需要的效果排列。
- **要**：無狀態的 Screen 本體只放大框架：容器、私有 composable 的呼叫、套在整個畫面上的設定；實際內容抽到私有 composable，以內容命名（`Header`、`StatsSection`），只傳入需要的資料與 lambda（官方：property drilling is preferable over creating wrapper classes）。
- **要**：畫面上的文字一律 `stringResource(R.string.x)`，只有 Preview 可以寫死字串。
- **避免**：在 composable 內寫業務邏輯；把 ViewModel 往下傳給子 composable。

## 常見錯誤檢查清單

- [ ] 專案根目錄缺 `.editorconfig`、ktlint 不是 `android_studio` code style 或版本低於 1.8.0；`ktlintCheck` 有錯誤
- [ ] 行寬超過 100；用 `+` 串接字串壓行；放得下一行卻斷行
- [ ] 二元運算子放在續行行首；`.`、`?.` 放在行尾
- [ ] 斷成多行的宣告缺 trailing comma；呼叫端加了 trailing comma；呼叫端部分換行
- [ ] 同型別基本型別參數或 `Boolean` 參數的呼叫沒有具名
- [ ] 型別本體開括號後沒空行、成員之間沒空行、`when` 分支的空行不一致、短分支加了大括號
- [ ] 使用 `// region`；方法依可見度分組；overload 不相鄰；interface 實作順序與宣告不一致
- [ ] Screen 檔的頂層宣告不是有狀態 Screen → 無狀態 Screen → 私有 composable → UI 計算函式 → `@Preview`；回傳 `Unit` 的 `@Composable` 排在 UI 計算函式之後，或回傳值的函式混在私有 composable 之間
- [ ] 宣告上的 annotation 與宣告同一行（`@Inject constructor` 除外）
- [ ] wildcard import、未使用的 import、非 ASCII 排序；data / domain / ViewModel import Compose
- [ ] 巢狀 lambda 用 `it`、不使用的參數沒寫 `_`、該用 function reference 卻包一層 lambda、多個 labeled return
- [ ] Composable 參數順序錯誤、外部 `modifier` 沒放 chain 第一個或套在內部元件
- [ ] 無狀態 Screen 本體出現實際內容；子 composable 接收整個 UiState 或 ViewModel；畫面文字寫死
