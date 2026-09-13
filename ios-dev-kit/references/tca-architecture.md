# TCA Architecture（Composable Architecture 專案規範）

Leo Ho 個人 iOS 專案採用 [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)（以下稱 TCA）時的規範。依據 TCA 1.x 系列的官方文件與 API，不綁定特定小版本，以 `@Reducer`、`@ObservableState`、`@Presents`、`StackState` 這一代 API 為準；平台下限 iOS 17，因為 `@ObservableState` 與 `@Presents` 依賴 Observation。本檔只規範 Presentation 層，Domain / Data / Core 的規則與 `project-structure.md`、`coding-style.md`、`formatting.md` 完全相同，本檔不重述。

## 目錄

- [TCA Architecture（Composable Architecture 專案規範）](#tca-architecturecomposable-architecture-專案規範)
  - [目錄](#目錄)
  - [定位與用語](#定位與用語)
    - [MVVM 與 TCA 的對應](#mvvm-與-tca-的對應)
  - [Feature 模組結構](#feature-模組結構)
  - [Feature 型別（Reducer）](#feature-型別reducer)
    - [分區順序](#分區順序)
    - [State](#state)
    - [Action](#action)
    - [Body 與 Effect](#body-與-effect)
    - [拆分](#拆分)
  - [View](#view)
  - [導航](#導航)
    - [Stack：根畫面的 Path](#stack根畫面的-path)
    - [Tree：畫面內的 Destination](#tree畫面內的-destination)
    - [動詞對應](#動詞對應)
    - [跨 Feature 模組導航](#跨-feature-模組導航)
  - [依賴注入](#依賴注入)
  - [@Shared](#shared)
  - [測試](#測試)
  - [常見錯誤檢查清單](#常見錯誤檢查清單)

## 定位與用語

TCA 是 **Presentation 層的第二種架構**，與 MVVM + Coordinator 並列；一個專案只用一種，**由使用者決定，agent 不自行選擇**。新專案在問完 A / B / C 結構方案後接著問 Presentation 架構；既有專案偵測到 `import ComposableArchitecture` 即視為 TCA 專案，告知使用者後依本檔進行，不得在 TCA 專案內新增 ViewModel 或 Coordinator，也不得在 MVVM 專案內新增 Reducer。

本檔內「Feature」有兩種用法，依上下文區分：

| 用語 | 意義 | 例子 |
|---|---|---|
| Feature 模組 | `project-structure.md` 定義的功能單位，一個資料夾 | `Features/Profile/` |
| Feature 型別 | TCA 的 `@Reducer` 型別，一個畫面一個 | `EditProfileFeature` |

型別後綴採 TCA 社群慣例 `Feature`，不用 `Reducer`。

### MVVM 與 TCA 的對應

| MVVM + Coordinator | TCA | 說明 |
|---|---|---|
| `<Screen>ViewModel` | `<Screen>Feature` | 狀態與邏輯的所在 |
| ViewModel 的 `State` / `Action` nested type | Feature 的 `State` / `Action` | 位置改在型別本體 |
| `<Feature>Coordinator` 的 `Route` | 根 Feature 的 `Path` | Stack 導航 |
| `<Feature>Coordinator` 的 `Sheet` / `FullScreen` | 該畫面 Feature 的 `Destination` | Tree 導航 |
| `FlowCoordinator` 的 `proceed` / `pop` / `finish` / `cancel` | 子畫面的 `delegate` action 與父層的 `path` 操作 | 見「動詞對應」 |
| `@Entry` 與 `EnvironmentValues+Services.swift` | `DependencyKey` 與 `<Name>Service+Dependency.swift` | 每個 Service 一檔 |
| ViewModel init 注入 Service | `@Dependency(\.xxxService)` | Service 本身仍以 init 注入 Client / Store |
| 測試以 init 注入 `Mock<Name>Service` | `TestStore` 的 `withDependencies` 注入同一個 Mock | Mock 樣板不變 |
| `@Observable` ViewModel 的單元測試 | `TestStore` 測試 | 一律 exhaustive |

不變的部分：Model、Enum、Error、UseCase、Service、Client、Store、Database、FormatStyle、DesignSystem、RuntimeEnvironment、UITests 的規則與樣板完全沿用。

## Feature 模組結構

與 `project-structure.md` 的「Feature 模組結構」相同，只有 Presentation 與 Data 兩處不同：Presentation 沒有 Coordinator，每個畫面的 ViewModel 換成 Feature 型別；Data 多一個 `DependencyKey` 註冊檔。

```text
Features/<Feature>/
├── Presentation/
│   ├── Root/
│   │   ├── <Feature>RootFeature.swift    # tca/Feature.swift；持有 Path，串 NavigationStack
│   │   └── <Feature>RootView.swift       # tca/FeatureView.swift
│   └── <Screen>/
│       ├── <Screen>Feature.swift         # tca/Feature.swift
│       ├── <Screen>Feature+Path.swift    # 選用，Path / Destination 子 reducer 過大時拆檔
│       ├── <Screen>View.swift            # tca/FeatureView.swift
│       └── <Screen>View+<Part>.swift     # 選用，同 MVVM
├── Domain/                               # 同 MVVM
├── Data/
│   ├── <Feature>Service.swift            # data/Service.swift
│   └── <Feature>Service+Dependency.swift # tca/DependencyKey.swift
└── Preview Content/
    └── <Feature>Service+Preview.swift    # data/Service+Preview.swift
```

- **要**：最小檔案組六個：`Root/` 的 Feature 與 View、Error、Service、Service 的 DependencyKey、Preview stub。
- **要**：根畫面型別固定 `<Feature>RootFeature` 與 `<Feature>RootView`，套樣板時 `__NAME__` 填 `<Feature>Root`。
- **要**：`Core/` 的 Client、Store、Database 同樣各自一個 `<Name>+Dependency.swift`，與型別同資料夾。
- **避免**：`Presentation/` 出現 ViewModel、Coordinator、`EnvironmentValues+Services.swift`；同一個畫面資料夾出現第二個 Feature 型別。

## Feature 型別（Reducer）

從 `tca/Feature.swift` 複製。`@Reducer` 巨集要求 `State`、`Action`、`body` 宣告在型別本體，因此 Feature 型別不套 `formatting.md` 的六區順序，改用下列 TCA 專屬分區；這是與 View 的 Body / Private Views 同性質的型別專屬例外。

### 分區順序

型別本體只放無法搬到 extension 的成員，固定四區，順序與官方文件範例一致，不可調換：

1. `State`：`@ObservableState struct State: Equatable`
2. `Action`：`enum Action` 與其內的 `View`、`Delegate`
3. `Dependencies`：全部 `@Dependency` 屬性，一律 `private`
4. `Body`：`var body: some ReducerOf<Self>`

本體以外依既有規範以同檔 extension 分區，順序固定：

5. `Nested Types`（extension）：`Path`、`Destination`、`CancelID` 等 Feature 專屬型別；順序固定 `Path` → `Destination` → `CancelID` → 其他依字母排序。`@Reducer enum` 放 extension 內與放本體內效果相同，已驗證。
6. `Private Method`（`private extension`）：第一個方法固定是 `core(state:action:)`，其後是抽出的 Effect 方法。

`State` 與 `Action` 必須在本體：`@Reducer` 巨集只會替本體內的 `Action` 加上 `@CasePathable`，搬到 extension 會失去 case key path。`@Dependency` 是 property wrapper，展開後是 stored property，Swift 不允許 extension 宣告 stored property，所以也必須在本體；官方文件一律寫在 `Action` 之後、`body` 之前，本規範以 `Dependencies` 區名固定這個位置。`body` 留本體則比照 SwiftUI `View` 的 Body 例外。`@Reducer`、`@ObservableState`、`@CasePathable`、`@Dependency` 各自獨立一行，寫在被修飾的宣告正上方，doc comment 在巨集之上；`@Dependency(\.xxx)` 與 `private var xxx` 也分兩行，避免 key path 拉長單行。用不到的區塊直接省略，不留空 MARK。

完整骨架如下，方法本體省略：

```swift
/// 個人資料畫面要顯示什麼、事件發生後做什麼，都由它決定。
@Reducer
struct ProfileFeature {

    // MARK: - State

    /// 畫面的全部狀態。
    @ObservableState
    struct State: Equatable {

        /// 是否正在載入。
        var isLoading = false

        /// 目前呈現的目的地，`nil` 代表沒有。
        @Presents var destination: Destination.State?
    }

    // MARK: - Action

    /// 畫面會發生的所有事件。
    enum Action {

        /// 使用者在畫面上的操作。
        ///
        /// - Parameter action: 實際的操作。
        case view(View)

        /// 交給父 reducer 處理的結果。
        ///
        /// - Parameter action: 要交給父層的結果。
        case delegate(Delegate)

        /// 目的地畫面的事件。
        ///
        /// - Parameter action: 呈現、關閉或目的地內部的事件。
        case destination(PresentationAction<Destination.Action>)

        /// Service 回傳個人資料的結果。
        ///
        /// - Parameter result: 成功帶回資料，失敗帶回錯誤。
        case profileResponse(Result<Profile, any Error>)

        /// 使用者在畫面上的操作。
        @CasePathable
        enum View {

            /// 畫面出現。
            case task

            /// 按下編輯按鈕。
            case editButtonTapped
        }

        /// 交給父 reducer 的結果。
        @CasePathable
        enum Delegate: Equatable {

            /// 個人資料已更新。
            ///
            /// - Parameter profile: 更新後的資料。
            case profileUpdated(Profile)
        }
    }

    // MARK: - Dependencies

    /// 讀取與更新個人資料的 Service。
    @Dependency(\.profileService)
    private var service

    // MARK: - Body

    /// 只負責組合 reducer，本畫面自己的邏輯在 `core(state:action:)`。
    var body: some ReducerOf<Self> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - Nested Types

extension ProfileFeature {

    /// 畫面內可呈現的目的地。
    @Reducer
    enum Destination {

        /// 編輯個人資料的表單。
        case edit(EditProfileFeature)
    }
}

// MARK: - Equatable

extension ProfileFeature.Destination.State: Equatable {}

// MARK: - Private Method

private extension ProfileFeature {

    /// 依收到的 Action 更新 State，並回傳要執行的 Effect。
    ///
    /// - Parameters:
    ///   - state: 目前的畫面狀態，直接就地修改。
    ///   - action: 這次收到的事件。
    /// - Returns: 接下來要執行的 Effect，沒有就回 `.none`。
    func core(state: inout State, action: Action) -> Effect<Action> {
        // ...
    }

    /// 向 Service 取得個人資料，結果以 `profileResponse` 送回。
    ///
    /// - Returns: 載入個人資料的 Effect。
    func loadProfile() -> Effect<Action> {
        // ...
    }
}
```

### State

- **要**：一律 `@ObservableState` 且遵循 `Equatable`，否則 `TestStore` 無法比對狀態。
- **要**：只放畫面需要的最小狀態；能從其他狀態算出的值改為 computed property，放同一個 `State` 內、stored property 之後。
- **要**：子畫面的狀態以 `@Presents var destination: Destination.State?` 或 `var path = StackState<Path.State>()` 持有，見「導航」。
- **避免**：把 Service 或 Client 放進 `State`；把 `Model` 的欄位攤平複製進 `State`，直接持有 `Model`。

### Action

`Action` 固定三組，依來源分：

| 組別 | 宣告 | 誰能送 | 命名 |
|---|---|---|---|
| 使用者操作 | `case view(View)`，`View` 為 `@CasePathable enum` | 只有對應的 View | 以「發生了什麼」命名：`saveButtonTapped`、`task`、`searchTextChanged(String)`；不用命令式 `save`、`load`；畫面出現固定叫 `task`，不用 `onAppear` |
| 交給父層的結果 | `case delegate(Delegate)`，`Delegate` 為 `@CasePathable enum`，遵循 `Equatable` | 只有本 Feature 的 `body` | 以「結果」命名：`finished(Order)`、`cancelled`、`profileUpdated(Profile)` |
| 內部回應 | 直接平放在 `Action` | 只有本 Feature 的 Effect | `<名詞>Response(Result<..., any Error>)`；導航相關為 `path(...)`、`destination(...)` |

- **要**：`Action` 內 case 順序固定 `view` → `delegate` → `path` / `destination` → 其他內部回應依字母排序；nested enum 順序 `View` → `Delegate`。
- **要**：`body` 收到 `.delegate` 一律 `return .none`，由父 reducer 在自己的 `body` 處理。
- **要**：需要 `BindableAction` 時 `Action` 遵循它並加 `case binding(BindingAction<State>)`，排在 `view` 之前；`body` 的第一個 reducer 為 `BindingReducer()`。
- **避免**：View 送 `view` 以外的 action；一個 case 同時代表使用者操作與內部回應；把 `Result` 拆成兩個 case（`succeeded` / `failed`）。

### Body 與 Effect

- **要**：`body` 只負責組合，本畫面自己的邏輯放 Private Method 的 `core(state: inout State, action: Action) -> Effect<Action>`，`body` 以 `Reduce(core)` 引用；不在 `body` 內寫 `Reduce { state, action in ... }` 閉包。
- **要**：`body` 的組合順序固定：`BindingReducer()`（有才寫）→ `Scope`（固定子 Feature）→ `Reduce(core)`；`.ifLet` 與 `.forEach` 以 modifier 形式接在 `Reduce(core)` 之後。
- **要**：`core` 內 `switch action` 的 case 順序與 `Action` 宣告順序一致；每個 case 本體換行，同 `formatting.md`。
- **要**：Effect 只用 `.run`，內部是 async/await；`Task.detached`、GCD、Combine 依鐵則 5 禁用。Service 的 typed throws 在 `.run` 內以 `do` / `catch` 接住，轉成 `Result` 送回 Action。
- **要**：畫面出現時要啟動的 Effect（初次載入、`AsyncStream` / `.values` 監聽）一律綁在 `.view(.task)`，由 View 的 `.task` modifier 觸發，離開畫面時 SwiftUI 自動取消，不需要 `CancelID`。
- **要**：只有使用者動作觸發、且需要手動取消或去重的 Effect（搜尋防抖、可取消的送出）才用 `CancelID`（Nested Types 內的 `enum`）配 `.cancellable(id:cancelInFlight:)` 與 `.cancel(id:)`。
- **要**：同一個 case 超過十行時，把 Effect 或狀態更新抽成 Private Method，方法名稱以動詞開頭並回傳 `Effect<Action>`，排在 `core` 之後。
- **避免**：在 `Reduce` 內直接呼叫 Service（同步阻塞 reducer）；在 Effect 內讀寫 `state`（只能讀取閉包捕獲的值）；`return .send` 以外的方式串多個 Action。

```swift
    // MARK: - Body

    /// 只負責組合 reducer，本畫面自己的邏輯在 `core(state:action:)`。
    var body: some ReducerOf<Self> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - Private Method

private extension ProfileFeature {

    /// 依收到的 Action 更新 State，並回傳要執行的 Effect。
    ///
    /// - Parameters:
    ///   - state: 目前的畫面狀態，直接就地修改。
    ///   - action: 這次收到的事件。
    /// - Returns: 接下來要執行的 Effect，沒有就回 `.none`。
    func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .view(.task):
            state.isLoading = true
            return loadProfile()

        case let .profileResponse(.success(profile)):
            state.isLoading = false
            state.profile = profile
            return .none

        case let .profileResponse(.failure(error)):
            state.isLoading = false
            state.errorMessage = error.localizedDescription
            return .none

        case .delegate, .destination:
            return .none
        }
    }

    /// 向 Service 取得個人資料，結果以 `profileResponse` 送回。
    ///
    /// - Returns: 載入個人資料的 Effect。
    func loadProfile() -> Effect<Action> {
        .run { send in
            do {
                let profile = try await service.fetchProfile()
                await send(.profileResponse(.success(profile)))
            } catch {
                await send(.profileResponse(.failure(error)))
            }
        }
    }
}
```

### 拆分

單檔 300 行上限沿用 `formatting.md`，超過依序處理：

1. `Path` / `Destination` 子 reducer 過大，搬到 `<Screen>Feature+Path.swift` 或 `<Screen>Feature+Destination.swift`，內容是 `extension <Screen>Feature` 內的 `@Reducer enum`。
2. 還是長，代表這個畫面做太多事：把可獨立的區塊抽成子 Feature 型別，以 `Scope` 組合。
3. 一個畫面資料夾內出現第二個 Feature 型別且它有自己的 View，就是另一個畫面，另開資料夾。

## View

從 `tca/FeatureView.swift` 複製。分區與 `presentation/View.swift` 相同（Properties → Body → Private Views → Nested Types → Private Method → Preview），差別只在 Properties 與 Init：

- **要**：唯一的 stored property 是 `@Bindable var store: StoreOf<<Screen>Feature>`，由父 View 以 `store.scope` 或 App 進入點以 `Store(initialState:reducer:)` 建立後傳入；不寫 Init。
- **要**：畫面出現時的載入固定寫 `.task { await store.send(.view(.task)).finish() }`，不用 `onAppear`；`finish()` 讓 Effect 跟著 View 生命週期，離開畫面自動取消。
- **要**：畫面只讀 `store` 的狀態、只送 `store.send(.view(...))`；`@State` 只允許純 UI 狀態（捲動位置、焦點、動畫旗標）且 Feature 完全不碰。
- **要**：`body` 只放大框架，內容抽 Private Views；格式化用 `FormatStyle`，同鐵則 8。
- **要**：Preview 直接建 `Store`，不覆寫依賴：TCA 在 Preview 自動使用 `previewValue`。
- **避免**：`onAppear` 觸發載入；`@Environment` 取 Service；`WithViewStore`、`ViewStore`、`WithPerceptionTracking`（iOS 17 以上不需要）；View 內用 `store.state` 之外的方式讀取狀態。

## 導航

TCA 原生導航取代 Coordinator：Stack 導航由根 Feature 的 `Path` 管理，畫面內的 sheet / alert / fullScreenCover 由該畫面 Feature 的 `Destination` 管理。「按下按鈕後該去哪」由 Feature 的 `body` 決定，View 不做判斷。

### Stack：根畫面的 Path

- **要**：`<Feature>RootFeature.State` 持有 `var path = StackState<Path.State>()`；`Path` 為 Nested Types 內的 `@Reducer enum Path`，一個 case 一個可 push 的畫面；`Action` 加 `case path(StackActionOf<Path>)`；`body` 的 `Reduce` 後接 `.forEach(\.path, action: \.path)`。
- **要**：`NavigationStack(path: $store.scope(\.path, action: \.path))` 與 `destination:` 閉包內的 `switch store.case` 只寫在 `<Feature>RootView`，其他 View 不重複。
- **要**：子畫面完成或取消時送 `delegate`，根 Feature 在 `case .path(.element(id:action:))` 接住並操作 `state.path`；子畫面不知道自己在 stack 的哪裡。
- **避免**：非根畫面持有 `StackState`；View 內直接 `NavigationLink(state:)` 跳到其他 Feature 模組；用 `path.append` 之外的方式（例如手動 `NavigationPath`）推畫面。

### Tree：畫面內的 Destination

- **要**：需要 sheet、alert、confirmationDialog 或 fullScreenCover 的畫面，在 `State` 加 `@Presents var destination: Destination.State?`，`Destination` 為 Nested Types 內的 `@Reducer enum Destination`；`Action` 加 `case destination(PresentationAction<Destination.Action>)`；`body` 的 `Reduce` 後接 `.ifLet(\.$destination, action: \.destination)`。
- **要**：View 以 `.sheet(item: $store.scope(\.destination?.<case>, action: \.destination.<case>))` 綁定；alert 用 `.alert($store.scope(\.destination?.alert, action: \.destination.alert))`。
- **要**：一個畫面只有一個 `destination`，所有可呈現的目的地都是它的 case；不為 sheet 與 alert 各開一個 optional。
- **要**：`@Reducer enum` 產生的 `Path.State` / `Destination.State` 不會自動 `Equatable`，在 Nested Types extension 之後補一個 `// MARK: - Equatable` 的空 extension：`extension <Screen>Feature.Destination.State: Equatable {}`，否則父 `State` 無法 `Equatable`。
- **避免**：跨畫面的 push 走 `Destination`（那是 `Path` 的事）；`Destination` 的 case 指向其他 Feature 模組的畫面。

### 動詞對應

`FlowCoordinator` 的四個動詞在 TCA 專案對應如下，命名固定，讓流程型 Feature 模組（Onboarding、Checkout）兩種架構讀起來一致：

| FlowCoordinator | TCA：子畫面送出 | TCA：根 Feature 收到後 |
|---|---|---|
| `proceed(from:)` | `.delegate(.proceeded)` 或帶資料的 `.delegate(.proceeded(<Output>))` | `state.path.append(.<next>(...))` |
| `pop()` | 不送 action，交給系統返回手勢與返回鍵 | `.forEach` 自動移除 |
| `finish(with:)` | `.delegate(.finished(<Output>))` | 清空 `path`，再向自己的父層送 `.delegate(.finished(<Output>))` |
| `cancel()` | `.delegate(.cancelled)` | 清空 `path`，再向自己的父層送 `.delegate(.cancelled)` |

### 跨 Feature 模組導航

- **要**：由 App 層的 `AppFeature` 持有各 Feature 模組的 `<Feature>RootFeature` 並以 `Scope` 或 `Path` 組合；Feature 模組之間不互相 `import` 或引用對方的 Feature 型別。跨模組只可引用對方 Domain 的 Model 與 Error，這條鐵則不變；`AppFeature` 引用各 `<Feature>RootFeature` 與 `<Feature>RootView` 是唯一例外，比照 MVVM 專案的 `AppCoordinator` 持有子 Coordinator。
- **要**：方案 B、C 的 Feature package 對外只 `public` 它的 `<Feature>RootFeature`、`<Feature>RootView` 與 `RootFeature.State` 的 `init`，其他畫面的 Feature 型別維持 internal。

## 依賴注入

Service 的形式不變：protocol 加 struct / actor 實作，init 注入 Client / Store，禁 `.shared`。差別只在**誰把 Service 交給 Feature**：MVVM 用 `@Entry` 與 View 的 `@Environment`，TCA 用 `DependencyKey`。

- **要**：每個 Service、Client、Store、Database 一個 `<Name>+Dependency.swift`，從 `tca/DependencyKey.swift` 複製，放在該型別同資料夾；內容固定 `enum <Name>Key: DependencyKey` 與 `extension DependencyValues` 兩區。
- **要**：`liveValue` 為 computed property，在裡面以 `@Dependency` 取得 Client / Store 後傳入 Service 的 init；Service 不自己建 Client。
- **要**：`previewValue` 以 `#if DEBUG` 包住，回傳既有的 `Preview<Name>Service`；stub 的 `RuntimeEnvironment.allowsPreviewStub` 斷言保留。
- **要**：**不宣告 `testValue`**。TCA 對只有 `liveValue` 的依賴，在測試中未經 `withDependencies` 覆寫就存取時會直接讓測試失敗，這正是要的效果：每個測試都必須明確注入 Mock。
- **要**：Feature 型別以 `@Dependency(\.<name>Service)` 換行接 `private var service` 取用，放 Dependencies 區；`Effect` 內直接用捕獲的 `service`。
- **避免**：TCA 專案出現 `@Entry`、`EnvironmentValues+Services.swift` 或 View 的 `@Environment(\.xxxService)`；`liveValue` 內 `.shared`；把 Mock 放進主 target 當 `testValue`；用 TCA 慣例的 struct-of-closures client 取代 protocol。

```swift
// MARK: - DependencyKey

/// 把 `ProfileServiceProtocol` 註冊進 TCA 依賴系統：正式 App 用正式實作，Preview 用 stub。
enum ProfileServiceKey: DependencyKey {

    /// 正式 App 使用的實作，Client 由依賴系統取得後注入。
    static var liveValue: any ProfileServiceProtocol {
        @Dependency(\.apiClient) var apiClient
        return ProfileService(client: apiClient)
    }

    #if DEBUG

    /// Preview 使用的 stub，固定回傳假資料。
    static var previewValue: any ProfileServiceProtocol {
        PreviewProfileService()
    }

    #endif
}
```

## @Shared

- **要**：`@Shared` 只用於父子 Feature 之間的**記憶體內**狀態共享：父層 `State` 宣告 `@Shared var cart: Cart`，建立子 `State` 時以 `Shared<Cart>` 傳入。
- **避免**：`.appStorage`、`.fileStorage`、`.inMemory` 與任何自訂 persistence key。持久化是 Data 層的事，走 Store / Database，維持分層單向；`@Shared` 不是 UserDefaults 的替代品。
- **避免**：跨 Feature 模組共享 `@Shared`；能用 `Scope` 傳遞或 `delegate` 回傳就不用 `@Shared`。

## 測試

單元測試規則沿用 `project-structure.md` 的「測試目錄」，差別只在 Feature 型別取代 ViewModel：

- **要**：每個 Feature 型別一個 `<Screen>FeatureTests.swift`，從 `tca/FeatureTests.swift` 複製，位置鏡像到 Feature 模組層級；型別標 `@MainActor`。
- **要**：一律用 `TestStore`，**不關 exhaustivity**：每個 `send` 與 `receive` 都寫出完整的狀態變化，未接收的 Action 與未斷言的變化就是測試失敗。
- **要**：`receive` 用 case key path（`store.receive(\.profileResponse.success)`），不依賴 `Action: Equatable`。成功值為 `Void` 的 `Result` 不可再接 `.success`（Swift 6.3.3 會在 IR 產生階段崩潰，已驗證），改為 `store.receive(\.xxxResponse)`。
- **要**：Mock 沿用 `tests/MockService.swift`，在 `TestStore` 的 `withDependencies` 閉包注入；一個測試只覆寫它用到的依賴。時間、UUID 等系統依賴用 TCA 內建的 `continuousClock`、`uuid` 覆寫，不自建。
- **要**：測試本體 Given / When / Then，`send` 為 When、`receive` 與 `#expect` 為 Then。
- **避免**：`exhaustivity = .off`；測 View；在測試裡直接呼叫 `Feature().reduce(into:action:)`；為 `Path` / `Destination` 子 reducer 單獨開測試檔（它們透過父 Feature 的測試覆蓋，除非本身是獨立畫面）。

## 常見錯誤檢查清單

- [ ] TCA 專案出現 ViewModel、Coordinator、`@Entry`、`EnvironmentValues+Services.swift`，或 MVVM 專案出現 `@Reducer`
- [ ] Feature 型別本體分區順序不是 State → Action → Dependencies → Body；`Path` / `Destination` / `CancelID` 寫在本體內而非 Nested Types extension；`Destination.State` 缺 `Equatable` extension
- [ ] `body` 內直接寫 `Reduce { state, action in ... }` 閉包，而不是 `Reduce(core)`
- [ ] `State` 缺 `@ObservableState` 或 `Equatable`；`State` 持有 Service
- [ ] `Action` 缺 `view` / `delegate` 分組；View 送了 `view` 以外的 action；view case 用命令式命名
- [ ] `body` 收到 `.delegate` 沒有 `return .none`；`.delegate` 在本 Feature 內被處理
- [ ] Effect 用 `.run` 以外的方式；`Reduce` 內直接呼叫 Service；畫面出現的載入用 `onAppear` 而非 `.task` 加 `finish()`
- [ ] `NavigationStack` 不在 `<Feature>RootView`；非根畫面持有 `StackState`；一個畫面有兩個 `@Presents`
- [ ] Feature 模組之間引用對方的 Feature 型別（`AppFeature` 引用 `RootFeature` 除外）
- [ ] Service 缺 `<Name>+Dependency.swift`；`liveValue` 內 `.shared`；宣告了 `testValue`；`previewValue` 未包 `#if DEBUG`
- [ ] `@Shared` 帶 persistence key；跨 Feature 模組共享
- [ ] 測試關閉 exhaustivity；未經 `withDependencies` 注入 Mock；`receive` 依賴 `Action: Equatable`
- [ ] Feature 型別超過 300 行卻未拆 `Path` / `Destination` 或子 Feature
