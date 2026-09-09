# File Templates（檔案樣板）

Leo Ho 個人 Swift 檔案樣板規範，版本 2026-09。實體樣板放在 [`../assets/templates/`](../assets/templates/)，本檔說明「何時用哪個」與各區塊的填寫規則。

## 目錄

- [樣板選擇](#樣板選擇)
- [佔位符](#佔位符)
- [檔頭規則](#檔頭規則)
- [各樣板說明](#各樣板說明)
- [常見錯誤檢查清單](#常見錯誤檢查清單)

## 樣板選擇

| 要建立的東西 | 用這個樣板（相對於 `assets/templates/`） | 檔名規則 |
|---|---|---|
| SwiftUI 畫面 | `presentation/View.swift` | `<Feature>View.swift` |
| 畫面的狀態與邏輯 | `presentation/ViewModel.swift` | `<Feature>ViewModel.swift` |
| 一個 Feature 內的導航（push / sheet）與目的地組裝 | `presentation/Coordinator.swift` | `<Feature>Coordinator.swift` |
| 有起點、終點與完成結果的多步驟流程（onboarding、結帳、註冊精靈） | `presentation/FlowCoordinator.swift` | `<流程名>Coordinator.swift` |
| 純資料模型 | `domain/Model.swift` | `<Name>.swift` |
| 列舉，無 associated value（分類、選項、raw value 對應字串或整數） | `domain/Enum.swift` | `<Name>.swift` |
| 列舉，有 associated value（狀態機、結果、帶資料的事件） | `domain/EnumWithAssociatedValue.swift` | `<Name>.swift` |
| 被多個 ViewModel 重複使用的跨 Service 流程 | `domain/UseCase.swift` | `<Verb><Noun>UseCase.swift` |
| Service / Client / Store 的介面與實作 | `data/Service.swift`（Client / Store 複製後將 `Service` 整批替換） | `<Name>Service.swift`、`<Name>Client.swift`、`<Name>Store.swift` |
| Service 的 Preview stub（固定回傳假資料） | `data/Service+Preview.swift` | `<Name>Service+Preview.swift` |
| Service 的 Mock（記錄呼叫，測試用） | `tests/MockService.swift` | `Mock<Name>Service.swift` |
| 單元測試（Swift Testing） | `tests/Tests.swift` | `<TypeUnderTest>Tests.swift` |
| UI 測試（XCTest / XCUITest） | `tests/UITests.swift` | `<Screen>UITests.swift` |
| 自訂格式化樣式（含業務規則的日期、金額、遮罩等） | `core/FormatStyle.swift` | `<Name>FormatStyle.swift` |
| Service 的 Environment 注入清單（每個專案一份） | `core/EnvironmentValues+Services.swift` | 固定 `EnvironmentValues+Services.swift` |
| 執行環境判斷（Preview / UI Test / 單元測試），每個專案一份 | `core/RuntimeEnvironment.swift` | 固定 `RuntimeEnvironment.swift` |

子資料夾對應 `project-structure.md` 的分層：`presentation/`、`domain/`、`data/`、`core/`、`tests/`。建 Feature 模組時，依要建的層去對應子資料夾取樣板；跨 Feature 共用的基礎型別放 `core/`。

表中沒有的型別先不建樣板，等實際專案出現該型別再補，避免留下沒人用的空樣板；新增時同步在對應子資料夾放檔案並在此表加一列。

## 佔位符

樣板內所有佔位符都是 `__UPPER_SNAKE__` 形式，複製後必須全數替換，殘留即視為錯誤。替換完成後，把沒用到的空 MARK 區塊與空 extension 一併刪除：樣板保留空區塊只是標示插槽位置與順序，實際檔案依 `formatting.md` 不留空區塊。

| 佔位符 | 意義 |
|---|---|
| `__NAME__` | 主要型別名稱（不含後綴），UpperCamelCase |
| `__NAME_LOWER_CAMEL__` | 主要型別名稱的 lowerCamelCase 形式，用於 static 便利存取子 |
| `__VALUE_TYPE__` | 被格式化的輸入型別，例如 `Date`、`Decimal`、`String` |
| `__OUTPUT_TYPE__` | 流程完成時交出的產出型別，例如 `Order`、`Account` |
| `__RAW_TYPE__` | enum 的 raw type，依需求決定，例如 `String`、`Int` |
| `__FILE_NAME__` | 檔名（含 `.swift`） |
| `__PROJECT__` | 專案／模組名稱 |
| `__DATE__` | 建立日期，格式 `YYYY/MM/DD` |
| `__AUTHOR__` | 作者，預設 `Leo Ho` |

## 檔頭規則

- **要**：保留 Xcode 風格檔頭，四行固定為檔名、target 名稱、空行、`Created by <作者> on <日期>.`；日期格式 `YYYY/MM/DD`；測試檔的 target 名稱為 `<Project>Tests` 或 `<Project>UITests`。
- **避免**：版權宣告、修改紀錄、作者以外的任何描述；檔頭不隨修改更新，建立後不再動。

## 各樣板說明

### presentation/View.swift

型別本體只放 Properties、Init 與 Body，其餘以 extension 分區，順序固定為 Private Views → Nested Types → Private Method → Preview。

**Private Views 區塊**：從 `body` 抽出的子 View，以 `private var` 或 `private func` 回傳 `some View`。

**Nested Types 區塊**：只放此 View 專屬、且 ViewModel 完全不碰的型別，例如 `Layout` 常數、`Tab` 列舉。會被 ViewModel 讀寫的狀態型別一律宣告在 ViewModel 的 Nested Types。

**Private Method 區塊的收納規則**：只放**純 UI 計算**，判斷標準三條同時成立：

1. **輸入只來自 View 已持有的值**：props、`@State`、`@Environment`、`GeometryProxy`、viewModel 的公開屬性。不自行取得資料。
2. **輸出是給 modifier 或版面用的值**：`CGFloat`、`Color`、`Font`、`Alignment`、`Bool`（決定顯示與否）。不包含格式化後的 `String`，格式化見下方規則。
3. **沒有副作用**：不改變任何狀態、不呼叫 viewModel 以外的物件、不 `async`、不 `throw`。

一秒判斷：**這個方法值得寫單元測試嗎？** 值得就是 ViewModel 的職責，搬過去；不值得才留在 View。

```swift
// MARK: - Private Method

private extension ProfileView {

    // 留在 View：依可用寬度算欄數，純版面計算
    func columnCount(for width: CGFloat) -> Int {
        width > 600 ? 3 : 2
    }

    // 留在 View：狀態對應圖示，純呈現對應
    func iconName(for state: ProfileViewModel.State) -> String {
        switch state {
        case .idle, .loaded: "person"
        case .loading: "hourglass"
        case .failed: "exclamationmark.triangle"
        }
    }
}
```

常見誤放，以下都屬 ViewModel：

- 過濾、排序、分組業務資料（`items.filter { $0.isActive }`）。
- 驗證輸入（email 格式、密碼強度）。
- 依業務規則決定文案或狀態（「超過三次失敗就鎖定」）。
- 組合多個屬性推導出新的業務狀態（`isFormValid`）。
- 呼叫 Service、觸發導航、發送分析事件。

View 只回答「這個值怎麼畫」，ViewModel 回答「這個值是什麼」。

**格式化（日期、金額、數量、遮罩等）的歸屬**，三條規則：

1. **View 不寫格式化方法**。顯示格式化值一律用 `Text(_:format:)` 或 `value.formatted(_:)` 傳入一個 `FormatStyle`，不在 Private Method 寫 `func formattedPrice()` 之類的東西。
2. **系統樣式就地使用，自訂樣式獨立成型別**。`.dateTime`、`.currency(code:)`、`.number` 這類 Foundation 內建樣式直接在 View 使用；含業務規則的格式化（「三天前」、手機遮罩、`$0` 顯示為「免費」）寫成 `FormatStyle` 實作，用 `core/FormatStyle.swift` 樣板建立，附單元測試。
3. **ViewModel 暴露原始型別，不預先轉成 `String`**。對外提供 `Date`、`Decimal`、`Int`，由 View 決定樣式。**唯一例外**：同一個值在多個 View 必須以完全相同的規則顯示，且該規則含業務判斷，才由 ViewModel 提供已格式化的字串，並在屬性的 doc comment 註明理由。

```swift
// View：系統樣式就地用
Text(profile.createdAt, format: .dateTime.year().month().day())
Text(order.total, format: .currency(code: "TWD"))

// View：自訂樣式，型別定義在 core/
Text(post.publishedAt, format: .relativeDay)

// ViewModel：暴露原始型別
var total: Decimal { order.total }
```

**Properties 的順序**固定為 `@Environment` → `@State` → `@Binding` → 一般 `let` / `var`，同一組內依名稱字母排序。

**`body` 只負責呈現大框架，一律保持簡潔。** `body` 內只允許容器（`NavigationStack`、`VStack`、`List`、`ScrollView` 等）、子 View 的呼叫，以及套在整個畫面上的 modifier（`navigationTitle`、`toolbar`、`task`、`sheet`）。任何實際內容，包括單一 `Text` 加幾個 modifier，都抽到 Private Views 成為具名的子 View。判斷標準：讀 `body` 應該能在三秒內說出這個畫面由哪幾塊組成，而不需要知道每塊長什麼樣。

```swift
var body: some View {
    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                header
                statsSection
                recentActivityList
            }
        }
        .navigationTitle("Profile")
        .task { await viewModel.load() }
    }
}
```

**Private Views 的 `var` 與 `func`**：無參數用 `var`，需要傳入資料（例如 `ForEach` 內的每一列）用 `func`；兩者都回傳 `some View`，不用 `AnyView`。

**`#Preview` 必備**，至少一個；有多種狀態（載入中、空、錯誤）時各一個 `#Preview("名稱")`，Service 一律注入 Preview stub。

### presentation/ViewModel.swift

型別本體只放 Properties 與 Init，其餘一律以 extension 分區，順序固定為 Nested Types → Internal Method → Private Method。

**Nested Types 區塊的收納規則**：只放**此 ViewModel 專屬**的 enum / struct / class，判斷標準三條同時成立：

1. 宣告在 `<Name>ViewModel` 的 extension 內，外部以 `<Name>ViewModel.<Type>` 存取。
2. 只被此 ViewModel 與它對應的 View 使用。
3. 描述的是這個畫面的狀態、動作或呈現用資料，例如 `State`、`Action`、`Section`、`Row`。

任一條不成立就不屬於這裡：會被其他 ViewModel、Service 或 Model 共用的型別，搬到 `domain/` 成為獨立檔案；只給 View 用而 ViewModel 完全不碰的型別，宣告在 View 的 Nested Types。

```swift
// MARK: - Nested Types

extension ProfileViewModel {

    enum State: Equatable {
        case idle
        case loading
        case loaded(Profile)
        case failed(String)
    }

    enum Action {
        case load
        case retry
    }
}
```

- **一律 `@Observable` + `@MainActor`**，不用 `ObservableObject` / `@Published`；既有程式碼新增 ViewModel 時也用 `@Observable`，不與舊寫法混用。
- **Nested Types 預設 internal**，因為對應的 View 需要讀取；只有 ViewModel 內部使用的型別才加 `private`。
- **多個 nested type 的順序**固定為 `State` → `Action` → 其他（`Section`、`Row` 等依字母排序）。

### presentation/Coordinator.swift

一個 Feature 一個 Coordinator，負責該 Feature 內的導航狀態與目的地組裝；View 與 ViewModel 都不直接操作 `NavigationPath`。`@Observable` + `@MainActor` 的 `final class`，透過 `.environment(coordinator)` 以型別注入，子 View 用 `@Environment(<Feature>Coordinator.self)` 取得。

- **`Route` 與 `Sheet` 宣告在 Nested Types**，`Route` 遵循 `Hashable` 供 `navigationDestination(for:)`，`Sheet` 遵循 `Identifiable` 供 `.sheet(item:)`。需要 fullScreenCover 時比照 `Sheet` 再加一個 `FullScreen` enum，不與 `Sheet` 混用。
- **Internal Method 只放狀態操作**（`push`、`pop`、`popToRoot`、`present`、`dismissSheet`），不含業務判斷；「按下按鈕後該去哪」由 ViewModel 決定後呼叫 Coordinator。
- **`// MARK: - Destinations` 是 Coordinator 專屬分區**，放 `destination(for:)` 與 `view(for:)` 兩個 `@ViewBuilder`，排在 Internal Method 之後、Private Method 之前。目的地 View 需要的 Service 由 View 自己從 `@Environment` 取，Coordinator 不轉傳依賴。
- **根 View 負責串接**：`NavigationStack(path: $coordinator.path)`、`.navigationDestination(for: Route.self)`、`.sheet(item: $coordinator.sheet)` 三行固定寫在 Feature 的根 View，其他 View 不重複。
- 跨 Feature 的導航由上層 Coordinator 持有子 Coordinator 處理，Feature 之間不互相引用對方的 `Route`。

### presentation/FlowCoordinator.swift

**流程**的定義：有明確起點與終點、完成時產出一個結果、中途可取消、以 modal 呈現的多步驟畫面序列。Onboarding、結帳、註冊精靈、KYC 都是。流程仍用 Coordinator，不另立 `Flow` 型別，命名維持 `<流程名>Coordinator`（`CheckoutCoordinator`、`OnboardingCoordinator`）。與一般 Feature Coordinator 的差異：

| 面向 | Feature Coordinator | 流程型 Coordinator |
|---|---|---|
| 生命週期 | 與 Feature 同壽 | 流程開始時建立，結束即釋放 |
| 呈現 | 嵌在父層的 stack | `fullScreenCover` 或 `sheet`，自帶 `NavigationStack` |
| 結束 | 無 | `onFinish: (Result) -> Void` 由父層傳入；`Result` 至少有 `completed(<產出>)` 與 `cancelled` |
| Route | 任意目的地 | case 依步驟順序排列，加 doc comment 註明 |
| 跨步驟資料 | 無 | Nested Types 內的 `Draft`（`@Observable` class），Coordinator 持有並以 `.environment(coordinator.draft)` 注入 |

**動詞固定四個**，不自創：

```swift
func proceed(from step: Route)     // 完成某一步，Coordinator 依 draft 決定下一步
func pop()                         // 退回上一步，沿用一般 Coordinator
func finish(with result: Result)   // 整個流程完成，呼叫 onFinish；父層負責 dismiss
func cancel()                      // 中途放棄，等同 finish(with: .cancelled)
```

- **`proceed(from:)` 帶目前步驟**，Coordinator 不靠 `path.last` 推算；最後一步不呼叫 `proceed`，由該步驟的 ViewModel 把 draft 轉成產出後呼叫 `finish(with: .completed(...))`。draft 轉正式 Model 是業務邏輯，屬 ViewModel，Coordinator 不做。
- **Private Method 的 `nextStep(after:)` 是規範中唯一允許 Coordinator 讀業務資料的地方**，用來依 draft 跳步或分支（例如貨到付款跳過刷卡頁）。步驟排序屬導航邏輯；真正的業務驗證（地址格式、金額上限）仍在各步驟的 ViewModel。
- **父層不持有流程 Coordinator**，只在 `fullScreenCover` 的 content 內建立流程根 View 並傳入 `onFinish` closure；流程根 View 以 `@State` 持有 Coordinator，並同時注入 `coordinator` 與 `coordinator.draft`。
- 步驟 View 以 `@Environment(<流程名>Coordinator.self)` 與 `@Environment(<流程名>Coordinator.Draft.self)` 取得兩者，各步驟的 ViewModel 以 init 注入 draft。
- `Draft` 隨 Coordinator 釋放，不透過 `Result` 外洩；`Result.completed` 只帶轉換後的正式 Model。

### domain/Model.swift

- **預設遵循 `Identifiable`、`Codable`、`Equatable`、`Sendable` 四個**，用不到的再拿掉；`Hashable` 只在要放進 `Set` 或當 dictionary key 時加。
- **`CodingKeys` 放 `// MARK: - Nested Types` extension**，只有欄位名稱與 JSON 不一致時才寫，全部一致就不寫讓編譯器合成。
- stored properties 一律 `let`；需要修改的 Model 用 `var` 但整個型別仍是 `struct`，透過複製修改，不改成 class。

### domain/Enum.swift

無 associated value 的列舉。預設遵循 `CaseIterable`、`Codable`、`Sendable`。

**Raw type 依實際需求決定，不預設為 `String`。** 選型原則：

| 需求 | Raw type |
|---|---|
| 值要與 API、資料庫或 UserDefaults 的字串對應 | `String` |
| 值要與後端的數字代碼對應，或需要天然的排序 | `Int` |
| 純粹在程式內分類，不需要任何外部表示 | 不加 raw type |

不加 raw type 時 `Codable` 仍可自動合成，會以 case 名稱的字串編碼；若連 `Codable` 都不需要就一併拿掉。本體只放 cases，computed properties 一律放 `// MARK: - Computed Properties` extension（enum 沒有 stored property，此為 `formatting.md` 分區順序的型別特例）。

**樣板不含 init，`init?(rawValue:)` 交由編譯器合成。** 只有「raw value 與 case 名稱不一一對應」或需要容錯解析（例如未知值落到 `.unknown`）時才手寫，放在本體 cases 之後的 `// MARK: - Init` 區塊；手寫版必須列出所有 case，`default` 只允許 `return nil` 或 `self = .unknown`。

```swift
// MARK: - Init

init?(rawValue: String) {
    switch rawValue.lowercased() {
    case "active": self = .active
    case "inactive", "disabled": self = .inactive
    default: return nil
    }
}
```

- **`CaseIterable` 預設加**，即使目前沒用到；它沒有成本，且 Picker、測試參數化幾乎一定會用到。
- **switch 禁止 `default`**，每個 case 明確列出，新增 case 時讓編譯器指出所有需要更新的地方。唯一例外是手寫 `init?(rawValue:)` 的 `default`。

### domain/EnumWithAssociatedValue.swift

有 associated value 的列舉。不帶 raw value，預設遵循 `Equatable`、`Sendable`。分區順序：本體放 cases 與 Init，extension 依序為 Nested Types → Computed Properties → Internal Method → Private Method。

**Init 只在需要時才寫，一般情況整組省略。** 樣板內的 `init(from:)`、`CodingKeys`、`encode(to:)` 與 `Codable` 遵循是一組，只有在這個 enum 需要與 JSON 互轉時才保留；不需要時把這四樣一起刪掉，只留空的 `// MARK: - Init` 與 Nested Types 插槽。不要只刪一半，例如留著 `Codable` 卻刪掉 `init(from:)`，那會退回自動合成的 `{"exampleWithValue": {"_0": "x"}}` 形狀。

樣板的 `Codable` 實作假設後端 JSON 是 discriminator 形式，`type` 欄位放 case 名稱、`value` 欄位放 associated value：

```json
{ "type": "exampleWithValue", "value": "x" }
```

若 API 的欄位名稱或形狀不同，改 `CodingKeys` 與兩個方法內的字串即可；associated value 有多個欄位時，在 `CodingKeys` 補 key 並逐一 decode / encode。

之所以不用 `init?(rawValue:)`：raw value 是 case 與常數的一對一對應，associated value 是每個實例不同的資料，無法從單一字串還原。

- **associated value 超過一個時強制加 label**，單一值可省略：`case loaded(Profile)`、`case failed(code: Int, message: String)`。
- **payload 超過三個欄位改用 struct**：`case loaded(ProfilePayload)`，struct 依 `domain/Model.swift` 樣板建立。
- **`Equatable` 無法自動合成時**（associated value 含 closure 或非 `Equatable` 型別），手寫 `==` 放 `// MARK: - Internal Method` extension，只比對有意義的欄位並以註解說明忽略了什麼。
- **switch 內統一用 `case .x(let v)`**，`let` 放在各個 value 前，不用 `case let .x(v)`；與樣板一致。
- **switch 同樣禁止 `default`**。

### domain/UseCase.swift

只在「同一個跨 Service 流程被多個 ViewModel 重複使用」時建立，單一 ViewModel 用到的流程直接寫在 ViewModel。命名 `<動詞><名詞>UseCase`，例如 `PlaceOrderUseCase`、`SyncProfileUseCase`。

- Protocol 與實作同檔，結構與 Service 相同；型別為 `struct`，init 注入所需的 Service（可注入多個），**不注入 Client / Store**，也不注入其他 UseCase。
- **對外只有一個 `execute`**，參數與回傳型別依需求調整，其餘輔助方法放 Private Method。一個 UseCase 需要第二個公開方法時，代表它是兩個 UseCase。
- ViewModel 以 `any <Name>UseCaseProtocol` init 注入，注入方式與 Service 相同，`@Entry` 同樣集中在 `EnvironmentValues+Services.swift`。
- Mock 套用 `tests/MockService.swift`，把 `Service` 整批替換成 `UseCase`。

### data/Service.swift

Protocol 與正式實作同檔，protocol 先、實作後；protocol 遵循放在獨立 extension，以 protocol 名稱作 MARK。Preview stub 與 mock 各自獨立檔案，不與正式碼同檔：

| 型別 | 位置 | 檔名 | 樣板 |
|---|---|---|---|
| Protocol + 正式實作 | 主 target，`Data/` | `<Name>Service.swift` | `data/Service.swift` |
| Preview stub（固定回傳假資料，給 `#Preview` 用） | 主 target，`Preview Content/` | `<Name>Service+Preview.swift` | `data/Service+Preview.swift` |
| Mock（記錄呼叫次數與參數，給測試用） | 測試 target | `Mock<Name>Service.swift` | `tests/MockService.swift` |

- Mock 不放主 target：它需要 `var` 記錄狀態，會讓 `Sendable` 檢查複雜化，也會被打進 App binary。
- Preview stub 與 mock 職責不同，不互相代用：stub 只回傳固定資料，mock 只記錄呼叫。
- `Preview Content/` 由 Xcode 的 Development Assets 設定排除於 Release，樣板仍以 `#if DEBUG` 包住作為雙重保險。
- Mock 用 `final class` + `@unchecked Sendable`，這是 Service 選型表第四列以外唯一允許 `@unchecked` 的情境，理由是測試為單執行緒存取；型別上方的 doc comment 要保留這句說明。

**Protocol 過大時的處理順序：先拆責任，再拆檔案，最後拆型別。**

1. **方法超過七個，先檢查是否混了多種責任。** 抓取、更新、快取、驗證是不同的事，依責任拆成多個小 protocol，需要整組能力時用 `typealias` 組合。ViewModel 只依賴用到的那個小 protocol，mock 也只需實作那幾個方法。

   ```swift
   protocol ProfileFetching: Sendable {
       func fetchProfile(id: String) async throws -> Profile
   }

   protocol ProfileUpdating: Sendable {
       func updateProfile(_ profile: Profile) async throws
   }

   typealias ProfileServiceProtocol = ProfileFetching & ProfileUpdating
   ```

2. **責任單一但方法確實多（例如包一整組 API endpoint 的 client），單檔超過 `formatting.md` 的長度上限時用 extension 分檔。** 主檔只放 protocol、型別宣告、stored properties 與 init；每個子領域一個 `<Name>+<Domain>.swift`，內容是 `extension <Name>` 實作該領域的方法。Protocol 遵循仍宣告在主檔。

   ```text
   Data/
   ├── APIClient.swift            # protocol + struct + init
   ├── APIClient+Profile.swift    # extension APIClient { profile 相關方法 }
   ├── APIClient+Orders.swift
   └── APIClient+Auth.swift
   ```

3. **兩者都做了還是長，代表這個型別在做太多事，拆成多個 Service。**

**Service protocol 一律遵循 `Sendable`**，因為 Service 會被注入到 `@MainActor` 的 ViewModel 與背景 Task，必須能跨 actor 傳遞。實作型別因此也必須是 `Sendable`，**依有無可變狀態決定型別**，三選一：

| 實作的狀態 | 型別 | 說明 |
|---|---|---|
| 沒有可變狀態，只持有注入的依賴 | `struct` | 樣板預設。stored properties 皆為 `Sendable` 時自動符合 `Sendable`；protocol 方法非 `mutating`，想加狀態會立刻編譯失敗，由編譯器保證無狀態 |
| 有可變狀態（cache、token、連線池、進行中的 Task） | `actor` | 由 actor 隔離保護，呼叫端需 `await` |
| 框架要求 reference 型別（作為 delegate、需要 `deinit` 清理）且無可變狀態 | `final class`，stored properties 全部 `let` 且為 `Sendable` | 只因外部限制才用，不是設計偏好 |
| 包裝本身非 `Sendable` 的第三方物件，且已自行以 lock / queue 保證執行緒安全 | `final class` + `@unchecked Sendable` | 必須在型別上方以註解寫明同步機制，且是最後手段 |

判斷口訣：**寫下第一個 `var` 的當下就改成 `actor`**。`struct` 內的 `var` 會因 protocol 方法非 `mutating` 而無法修改；`final class` 標了 `Sendable` 又持有 `var`，Swift 6 語言模式直接是編譯錯誤：

```text
error: stored property 'cache' of 'Sendable'-conforming class 'Service' is mutable
```

不要用 `mutating`、`nonisolated(unsafe)` 或 `@unchecked` 來壓掉這些錯誤，那是第四列的情境專用，不是可變狀態的解法。

Mock 的型別與正式實作無關，測試 target 內的 mock 可以用 `final class` 記錄呼叫次數與參數，不影響正式實作選 `struct`。

改成 `actor` 時，protocol 內的方法宣告要加 `async`，讓 mock 與其他實作不受 actor 隔離限制：

```swift
protocol ProfileServiceProtocol: Sendable {
    func fetchProfile(id: String) async throws -> Profile
}

actor ProfileService: ProfileServiceProtocol {
    private var cache: [String: Profile] = [:]

    func fetchProfile(id: String) async throws -> Profile { ... }
}
```

**依賴注入：init 注入為主，SwiftUI Environment 負責把 Service 送到 View，不引入 DI container。**

- **Service → ViewModel**：init 注入，參數型別是 protocol 的 existential（`any <Name>ServiceProtocol`），**不給預設值**。預設值會把依賴藏起來，測試時也容易忘了換成 mock。
- **Service → View**：View 以 `@State` 建立 ViewModel 時，Service 來源是 `@Environment`。在 App 根部注入一次正式實作，`#Preview` 注入 Preview stub。Key 以 `@Entry` 宣告在 `EnvironmentValues` 的 extension，放 `Core/Environment/`。
- **禁止 `.shared` 單例**。唯一例外是 Service 內部包裝系統本身就是單例的物件（`URLSession.shared`、`UserDefaults.standard`、`NotificationCenter.default`），且不得外洩到 ViewModel。
- **不引入第三方 DI container**。Environment 就是 composition root；所有型別都已是 init 注入，日後真要換 container 也只動根部。

```swift
// Core/Environment/EnvironmentValues+Services.swift
extension EnvironmentValues {
    @Entry var profileService: any ProfileServiceProtocol = PreviewProfileService()
}

// App 根部
ContentView()
    .environment(\.profileService, ProfileService())

// View
struct ProfileView: View {
    @Environment(\.profileService) private var profileService
    @State private var viewModel: ProfileViewModel?

    var body: some View {
        content
            .task {
                if viewModel == nil {
                    viewModel = ProfileViewModel(profileService: profileService)
                }
            }
    }
}

// ViewModel
init(profileService: any ProfileServiceProtocol) {
    self.profileService = profileService
}
```

`@Entry` 的預設值填 Preview stub 而非正式實作，這樣忘記在根部注入時 Preview 與測試不會意外打到真實 API；正式 App 一定要在根部覆寫，忘記時 Preview stub init 內的 `assert` 會在 Debug 執行時中止（見 `data/Service+Preview.swift` 一節）。

**Service 之間的依賴：只允許向下依賴基礎設施，禁止 Service 依賴同層 Service。**

Data 層的型別分兩種：

| 種類 | 職責 | 例子 |
|---|---|---|
| Client / Store | 純技術能力，不含業務語意 | `APIClient`、`KeychainStore`、`DatabaseStore` |
| Service | 面向業務的一組操作，組合 Client / Store | `ProfileService`、`OrderService` |

- Service 可以 init 注入 Client / Store。
- **Service 不可注入另一個 Service**。需要跨多個 Service 的流程放在 ViewModel；同一流程被多個 ViewModel 重複使用時，才抽成 Domain 層的 UseCase（目前專案未使用此層，見 `project-structure.md`）。
- Client / Store 之間不互相依賴。

依賴圖因此固定為兩層且無環：mock 一個 Service 時不必連帶處理它底下的東西。

**Client / Store 共用 `data/Service.swift` 樣板**，複製後把 `Service` 字樣整批替換成 `Client` 或 `Store`；Preview stub 與 Mock 樣板同樣處理，得到 `PreviewAPIClient`、`MockKeychainStore`。不另建樣板，因為三者檔案結構完全相同。

- 後綴固定三選一：`Service`、`Client`、`Store`。不用 `Manager`、`Helper`、`Provider`、`Handler` 這類語意模糊的字。
- 選型表同樣適用：Client 包 `URLSession` 通常是 `struct`；Store 包 SwiftData 的 `ModelContext` 這類非 `Sendable` 物件時用 `@ModelActor` 或 `actor`，落在選型表第二列。
- Client / Store 的 protocol 方法只暴露技術操作（`request`、`read`、`write`、`delete`），簽章中不出現業務名詞；一旦出現 `Profile`、`Order` 這種詞，它就該是 Service。

**`@Entry` 集中在 `Core/Environment/EnvironmentValues+Services.swift` 一個檔案**，不一個 Service 一檔。這個檔案就是「App 可注入哪些 Service」的清單，等同 composition root 的目錄。

- 一行一個 entry，依名稱字母排序。
- 預設值一律填 Preview stub。
- 專案拆成多個 SPM module 時才改為 entry 隨 Service 所在 module 放，屆時集中檔自然消失。

### data/Service+Preview.swift

給 `#Preview` 用的固定回傳實作，型別名稱固定 `Preview<Name>Service`。方法內只回傳寫死的假資料或立即 `return`，不記錄呼叫、不含邏輯。放在 `Preview Content/`，整檔以 `#if DEBUG` 包住。

**init 內固定放一行 `assert(RuntimeEnvironment.allowsPreviewStub, ...)`**，正式 App 忘記在根部覆寫 `@Entry` 時，Debug 執行會立刻中止而非靜默使用 stub；Release 因 `assert` 被移除且整檔在 `#if DEBUG` 內，不受影響。`RuntimeEnvironment` 由 `core/RuntimeEnvironment.swift` 樣板建立，每個專案一份。

### tests/MockService.swift

給單元測試用的記錄型實作，型別名稱固定 `Mock<Name>Service`。每個 protocol 方法對應三個屬性，命名固定：

- `<method>CallCount`：呼叫次數，`private(set) var`。
- `<method>ReceivedArguments`：依序記錄每次傳入的參數，`private(set) var`；無參數的方法省略。
- `<method>Result`：測試端設定的回傳值或錯誤，`var`，型別用 `Result<Output, any Error>`，方法內以 `try <method>Result.get()` 取出。

樣板內的 `example(_:)` 是示範用，替換成實際 protocol 方法後刪除。

### core/FormatStyle.swift

遵循 Foundation 的 `FormatStyle` protocol，不自訂平行的 formatter protocol，也避免命名為 `<Name>Formatter` 以免與 Foundation 的 `Formatter` 類別混淆。

- `FormatStyle` 要求 `Codable` 與 `Hashable`，因此 stored properties 只能是同樣遵循兩者的型別（`Locale`、`TimeZone`、`Calendar`、基本型別都可以）。
- `format(_:)` 是唯一必要實作；輸入型別填入 `__VALUE_TYPE__`，輸出固定 `String`。
- 樣板底部的 `extension FormatStyle where Self == ...` 提供 `.relativeDay` 這種點語法便利存取子，讓 View 可以寫 `Text(date, format: .relativeDay)`。有參數的樣式改成 static func。
- 使用 `Locale`、`TimeZone` 時透過 init 注入並給預設值，不在 `format(_:)` 內直接讀 `.current`，方便測試固定環境。

- **便利存取子必備**，讓 View 能寫 `.formatted(.relativeDay)`；不提供則等同沒有完成這個樣式。
- **不要求 `ParseableFormatStyle`**，只在確實需要從字串解析回值時才加。
- **測試至少涵蓋三種情境**：預設 locale、一個非預設 locale（`zh_TW` 與 `en_US` 至少各一）、邊界值（0、負數、極大值、跨日或跨年）。

### core/EnvironmentValues+Services.swift

每個專案只有一份，檔名固定，不使用 `__FILE_NAME__` 佔位符。內容是 `EnvironmentValues` 的 extension，每個 Service 一行 `@Entry`，型別為 protocol existential，預設值為 Preview stub。樣板內的示範 entry 替換成第一個實際 Service 後，之後新增 Service 時直接在此檔加一行並維持字母排序，不再從樣板複製。

entry 旁不加註解。正式實作的注入位置固定在 App 根部的 `.environment(\.xxx, ...)`，這條規則寫在本節即可，不需要每行重複。

### core/RuntimeEnvironment.swift

每個專案一份，檔名固定。無 case 的 `enum` 作為命名空間，四個 static computed property 放 `// MARK: - Computed Properties` extension：`isPreview`（`XCODE_RUNNING_FOR_PREVIEWS`）、`isUITesting`（`-uiTesting` launch argument）、`isUnitTesting`（`XCTestConfigurationFilePath` / `XCTestBundlePath`）、`allowsPreviewStub`（前三者任一）。App 根部依 `isUITesting` 決定注入正式實作或 Preview stub；Preview stub 的 init 以 `allowsPreviewStub` 做 assert。不在此型別加入其他與環境無關的判斷。

### tests/Tests.swift

**Unit Test 一律採用 Swift Testing**（`import Testing`、`@Test`、`#expect` / `#require`），不使用 XCTest。既有的 XCTest 單元測試新增案例時亦改寫為 Swift Testing，不在同一檔案混用兩套框架。

測試本體採 Given / When / Then 三段式，以 `// Given`、`// When`、`// Then` 註解分隔，不使用 Arrange / Act / Assert。

- 測試型別用 `struct`，只有需要跨測試共享可變狀態或 `deinit` 清理時才改用 `final class`。
- 斷言用 `#expect`；前置條件不成立就沒必要繼續時用 `try #require`。
- 同一邏輯多組輸入用 `@Test(arguments:)` 參數化，不複製貼上多個測試。
- 非同步測試直接 `async throws`，不用 expectation。

- **命名格式**：`<方法或行為>_<情境>_<預期>`，lowerCamel 加底線分段，不加 `test` 前綴（Swift Testing 靠 `@Test` 探測）。例：`fetchProfile_whenCacheHit_returnsCachedProfile`、`submit_withEmptyEmail_throwsValidationError`。`@Test("顯示名稱")` 只在名稱無法表達意圖時加。
- **三段註解必備**，即使某段只有一行；Given 為空時仍保留註解並留空行，讓結構一致。
- **一個測試只允許一組 When / Then**；需要驗證多個結果時用多個 `#expect`，需要多個動作時拆成多個測試或改用 `@Test(arguments:)`。
- **`@Suite` 只在需要共用 setup、tag 或序列化執行（`.serialized`）時使用**，單純分組不加。

### tests/UITests.swift

**唯一允許使用 XCTest 的情境是 UI Test**，因為 `XCUIApplication` 與 `XCUIElement` 只存在於 XCTest，Swift Testing 沒有對應能力。

- 型別用 `final class` 繼承 `XCTestCase`，`app` 在 `setUpWithError` 建立並 `launch()`，`tearDownWithError` 釋放。
- `continueAfterFailure = false`，UI 流程一步失敗後續步驟沒有意義。
- 測試方法沿用 `test` 前綴（XCTest 靠前綴探測），本體同樣採 Given / When / Then。
- 元素查詢一律透過 accessibility identifier，不用顯示文字或索引定位。

- **launch argument 固定 `-uiTesting`**，在 `setUpWithError` 以 `app.launchArguments = ["-uiTesting"]` 傳入；App 端在根部檢查 `CommandLine.arguments` 含此旗標時注入 Preview stub，UI Test 不打真實 API。需要特定資料情境時用 `app.launchEnvironment["UITEST_SCENARIO"]` 傳場景名稱。
- **不強制 Page Object**；單一畫面的測試直接查詢元素，超過三個畫面的流程才為每個畫面建立 `<Screen>Screen` struct 封裝元素查詢與操作。
- **失敗時的截圖由 XCTest 自動附加**，不手動 `XCTAttachment`；只有在需要對比視覺結果時才手動截圖並命名。

## 常見錯誤檢查清單

- [ ] 佔位符全數替換
- [ ] 未使用的空 MARK 區塊與空 extension 已刪除
- [ ] 檔名與主要型別名稱一致
- [ ]
