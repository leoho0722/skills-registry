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
    - [Service](#service)
    - [Client、Store、Database](#clientstoredatabase)
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

型別後綴採 TCA 社群慣例 `Feature`，不用 `Reducer`。依賴型別則不採社群慣例的 `XxxClient`，維持 `<Feature>Service`：本規範的 `Client` 專指 Core 的網路層，後綴與資料夾一對一（見 `project-structure.md`），Feature 的依賴也叫 Client 會讓同一個後綴代表兩層。

### MVVM 與 TCA 的對應

| MVVM + Coordinator | TCA | 說明 |
|---|---|---|
| `<Screen>ViewModel` | `<Screen>Feature` | 狀態與邏輯的所在 |
| ViewModel 的 `State` / `Action` nested type | Feature 的 `State` / `Action` | 位置改在型別本體 |
| `<Feature>Coordinator` 的 `Route` | 根 Feature 的 `Path` | Stack 導航 |
| `<Feature>Coordinator` 的 `Sheet` / `FullScreen` | 該畫面 Feature 的 `Destination` | Tree 導航 |
| `FlowCoordinator` 的 `proceed` / `pop` / `finish` / `cancel` | 子畫面的 `delegate` action 與父層的 `path` 操作 | 見「動詞對應」 |
| `@Entry` 與 `EnvironmentValues+Services.swift` | `DependencyKey` 與 `<Name>Service+Dependency.swift` | 每個 Service 一檔 |
| `<Name>ServiceProtocol` 加 `<Name>Service` 實作 | struct 裝 closure 的 `<Name>Service`，正式實作在 `liveValue` | 見「依賴注入」 |
| ViewModel init 注入 Service | `@Dependency(\.xxxService)` | Service 的 `liveValue` 以 `@Dependency` 取得 Client / Store |
| `Preview<Name>Service` | `<Name>Service` 的 `previewValue` | 位置同樣在 `Preview Content/` |
| 測試以 init 注入 `Mock<Name>Service` | `withDependencies` 只覆寫用到的 closure，`testValue` 全為 `unimplemented` | Service 沒有 Mock，呼叫紀錄用 `LockIsolated` |
| `@Observable` ViewModel 的單元測試 | `TestStore` 測試 | 一律 exhaustive |

不變的部分：Model、Enum、Error、Client、Store、Database、FormatStyle、DesignSystem、RuntimeEnvironment、UITests 的規則與樣板完全沿用。Service 改用 struct 裝 closure，TCA 專案有 UseCase 時比照 Service，見「依賴注入」。

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
│   ├── <Feature>Service.swift            # tca/Service.swift
│   └── <Feature>Service+Dependency.swift # tca/Service+Dependency.swift
└── Preview Content/                      # 方案 A；B、C 改為 Preview/ 並整檔 #if DEBUG
    └── <Feature>Service+Preview.swift    # tca/Service+Preview.swift
```

- **要**：最小檔案組六個：`Root/` 的 Feature 與 View、Error、Service、Service 的 `+Dependency`、Service 的 `+Preview`。
- **要**：根畫面型別固定 `<Feature>RootFeature` 與 `<Feature>RootView`，套樣板時 `__NAME__` 填 `<Feature>Root`。
- **要**：`Core/` 的 Client、Store、Database 同樣各自一個 `<Name>+Dependency.swift`，從 `tca/DependencyKey.swift` 複製，與型別同資料夾。
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
6. `Private Method`（`private extension`）：第一個方法固定是 `core(state:action:)`，其後是抽出的 Effect 方法，依 `formatting.md` 的呼叫者在前、深度優先排列；`core` 排第一本身就符合這條通則。有 private static method 時也排在 `core` 之後，這是 `formatting.md`「區內排序」static 在前的例外，讓 reducer 的入口一打開就看得到；private computed property 仍依該節排在所有方法之前。

`State` 與 `Action` 必須在本體：`@Reducer` 巨集只會替本體內的 `Action` 加上 `@CasePathable`，搬到 extension 會失去 case key path。`@Dependency` 是 property wrapper，展開後是 stored property，Swift 不允許 extension 宣告 stored property，所以也必須在本體；官方文件一律寫在 `Action` 之後、`body` 之前，本規範以 `Dependencies` 區名固定這個位置。`body` 留本體則比照 SwiftUI `View` 的 Body 例外。`@Reducer`、`@ObservableState`、`@CasePathable`、`@Dependency` 各自獨立一行，寫在被修飾的宣告正上方，doc comment 在巨集之上；`@Dependency(\.xxx)` 與 `private var xxx` 也分兩行，避免 key path 拉長單行。用不到的區塊直接省略，不留空 MARK。

完整骨架如下，方法本體省略：

```swift
/// 個人資料畫面要顯示什麼、事件發生後做什麼，都由它決定
@Reducer
struct ProfileFeature {

    // MARK: - State

    /// 畫面的全部狀態
    @ObservableState
    struct State: Equatable {

        /// 是否正在載入
        var isLoading = false

        /// 目前呈現的目的地，`nil` 代表沒有
        @Presents var destination: Destination.State?
    }

    // MARK: - Action

    /// 畫面會發生的所有事件
    enum Action {

        /// 使用者在畫面上的操作
        ///
        /// - Parameter action: 實際的操作
        case view(View)

        /// 交給父 reducer 處理的結果
        ///
        /// - Parameter action: 要交給父層的結果
        case delegate(Delegate)

        /// 目的地畫面的事件
        ///
        /// - Parameter action: 呈現、關閉或目的地內部的事件
        case destination(PresentationAction<Destination.Action>)

        /// Service 回傳個人資料的結果
        ///
        /// - Parameter result: 成功帶回資料，失敗帶回錯誤
        case profileResponse(Result<Profile, any Error>)

        /// 使用者在畫面上的操作
        @CasePathable
        enum View {

            /// 畫面出現
            case task

            /// 按下編輯按鈕
            case editButtonTapped
        }

        /// 交給父 reducer 的結果
        @CasePathable
        enum Delegate: Equatable {

            /// 個人資料已更新
            ///
            /// - Parameter profile: 更新後的資料
            case profileUpdated(Profile)
        }
    }

    // MARK: - Dependencies

    /// 讀取與更新個人資料的 Service
    @Dependency(\.profileService)
    private var service

    // MARK: - Body

    /// 只負責組合 reducer，本畫面自己的邏輯在 `core(state:action:)`
    var body: some ReducerOf<Self> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - Nested Types

extension ProfileFeature {

    /// 畫面內可呈現的目的地
    @Reducer
    enum Destination {

        /// 編輯個人資料的表單
        case edit(EditProfileFeature)
    }
}

// MARK: - Equatable

extension ProfileFeature.Destination.State: Equatable {}

// MARK: - Private Method

private extension ProfileFeature {

    /// 依收到的 Action 更新 State，並回傳要執行的 Effect
    ///
    /// - Parameters:
    ///   - state: 目前的畫面狀態，直接就地修改
    ///   - action: 這次收到的事件
    /// - Returns: 接下來要執行的 Effect，沒有就回 `.none`
    func core(state: inout State, action: Action) -> Effect<Action> {
        // ...
    }

    /// 向 Service 取得個人資料，結果以 `profileResponse` 送回
    ///
    /// - Returns: 載入個人資料的 Effect
    func loadProfile() -> Effect<Action> {
        // ...
    }
}
```

### State

- **要**：一律 `@ObservableState` 且遵循 `Equatable`，否則 `TestStore` 無法比對狀態。
- **要**：只放畫面需要的最小狀態；能從其他狀態算出的值改為 computed property，放同一個 `State` 內、stored property 之後。`State` 是巢狀型別，依 `formatting.md` 的「巢狀型別」就地寫，不另開 `extension <Screen>Feature.State`。
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
- **要**：`core` 內 `switch action` 的 case 順序與 `Action` 宣告順序一致；每個 case 本體換行、case 之間空一行，同 `formatting.md`。
- **要**：Effect 只用 `.run`，內部是 async/await；`Task.detached`、GCD、Combine 依鐵則 5 禁用。Service 的 typed throws 在 `.run` 內以 `do` / `catch` 接住，轉成 `Result` 送回 Action。
- **要**：畫面出現時要啟動的 Effect（初次載入、`AsyncStream` / `.values` 監聽）一律綁在 `.view(.task)`，由 View 的 `.task` modifier 觸發，離開畫面時 SwiftUI 自動取消，不需要 `CancelID`。
- **要**：只有使用者動作觸發、且需要手動取消或去重的 Effect（搜尋防抖、可取消的送出）才用 `CancelID`（Nested Types 內的 `enum`）配 `.cancellable(id:cancelInFlight:)` 與 `.cancel(id:)`。
- **要**：同一個 case 超過十行時，把 Effect 或狀態更新抽成 Private Method，方法名稱以動詞開頭並回傳 `Effect<Action>`，排在 `core` 之後。
- **避免**：在 `Reduce` 內直接呼叫 Service（同步阻塞 reducer）；在 Effect 內讀寫 `state`（只能讀取閉包捕獲的值）；`return .send` 以外的方式串多個 Action。

```swift
    // MARK: - Body

    /// 只負責組合 reducer，本畫面自己的邏輯在 `core(state:action:)`
    var body: some ReducerOf<Self> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - Private Method

private extension ProfileFeature {

    /// 依收到的 Action 更新 State，並回傳要執行的 Effect
    ///
    /// - Parameters:
    ///   - state: 目前的畫面狀態，直接就地修改
    ///   - action: 這次收到的事件
    /// - Returns: 接下來要執行的 Effect，沒有就回 `.none`
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

    /// 向 Service 取得個人資料，結果以 `profileResponse` 送回
    ///
    /// - Returns: 載入個人資料的 Effect
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

Feature 型別直接取用的 Service 改用 TCA 慣例的 struct 裝 closure；Service 內部使用的 Client、Store、Database 維持 protocol 加 struct / actor 實作與 init 注入，禁 `.shared`，與 MVVM 專案共用同一份程式碼與樣板。TCA 專案有 UseCase 時比照 Service，套用樣板時把 `Service` 換成 `UseCase`。

- **要**：所有依賴一律以 `DependencyKey` 註冊、`DependencyValues` 的屬性取用。
- **避免**：TCA 專案出現 `@Entry`、`EnvironmentValues+Services.swift` 或 View 的 `@Environment(\.xxxService)`；`liveValue` 內 `.shared`；把 Mock 放進主 target 當 `testValue`。

### Service

從 `tca/Service.swift`、`tca/Service+Dependency.swift`、`tca/Service+Preview.swift` 複製，檔案位置見「Feature 模組結構」。

- **要**：`<Feature>Service` 是遵循 `Sendable` 的 struct，每個操作一個 closure 屬性，型別一律 `@Sendable` 加 typed throws；TCA 專案不出現 `<Feature>ServiceProtocol`、`Preview<Feature>Service`、`Mock<Feature>Service`。
- **要**：每個 closure 屬性一律宣告 typealias，名稱為屬性名稱首字大寫（`addCategory` → `AddCategory`），放 Nested Types，順序與屬性一致，參數名稱保留在 typealias 內。完整的 `///`（`- Parameter`、`- Returns`、`- Throws`）寫在屬性上，因為呼叫端的 Quick Help 顯示的是屬性的說明；typealias 只寫一行「`addCategory` 的函式型別」。
- **要**：Service 直接遵循 `DependencyKey`（`extension <Feature>Service: DependencyKey`），不另建 Key enum。Feature 型別以 `@Dependency(\.<feature>Service)` 換行接 `private var service` 取用，放 Dependencies 區，`Effect` 內直接用捕獲的 `service`。
- **要**：`liveValue` 是 computed property（`static var`），在裡面以 `@Dependency` 取得 Client / Store，再組出每個 closure；本體會 throw 的 closure 依 `formatting.md` 只補 `throws(E)`。不寫成 `static let`：`static let` 只在第一次取用時建立，之後固定住當時的 Client / Store，測 Service 時無法用 `withDependencies` 換成 Mock。
- **要**：`testValue` 必須宣告，每個 closure 都是 `unimplemented("<Feature>Service.<屬性>")`，有回傳值的加 `placeholder:`，填空集合、`nil`、空字串這類中性的值。少了 `testValue`，測試在 `withDependencies` 只覆寫一個 closure 時，其他 closure 會悄悄改用 `previewValue`，不會報錯（swift-dependencies 在設定依賴期間的預設行為，已實測）。
- **要**：`previewValue` 放在 `+Preview` 檔，整檔 `#if DEBUG`，getter 第一行 `assert(RuntimeEnvironment.allowsPreviewStub, ...)`，closure 只回傳固定的假資料。
- **避免**：`@DependencyClient` 巨集。它替每個 closure 產生的未實作預設會丟出自己的 `Unimplemented` 錯誤，與 typed throws 衝突而編譯失敗；closure 型別改成 typealias 後，巨集又認不出是 closure，什麼都不產生（swift-dependencies 1.17 實測）。
- **避免**：以型別下標取用（`$0[<Feature>Service.self]`、`@Dependency(<Feature>Service.self)`），一律用 `DependencyValues` 的屬性。

`CategoryService.swift`：

```swift
/// 類別資料的讀寫；正式實作在 `liveValue`、測試預設值在 `testValue`、假資料在 `previewValue`
struct CategoryService: Sendable {

    // MARK: - Properties

    /// 讀取目前所有類別名稱並排序
    ///
    /// - Returns: 已排序的類別名稱
    /// - Throws: 讀取持久化資料失敗時丟出
    var fetchCategories: FetchCategories

    /// 加入新類別；去除前後空白後若為空字串則不處理
    ///
    /// - Parameter rawName: 尚未去除前後空白的名稱
    /// - Throws: 寫入持久化資料失敗時丟出
    var addCategory: AddCategory
}

// MARK: - Nested Types

extension CategoryService {

    /// `fetchCategories` 的函式型別
    typealias FetchCategories = @Sendable () async throws(PersistenceError) -> [String]

    /// `addCategory` 的函式型別
    typealias AddCategory = @Sendable (_ rawName: String) async throws(PersistenceError) -> Void
}
```

`CategoryService+Dependency.swift`：

```swift
// MARK: - DependencyKey

extension CategoryService: DependencyKey {

    /// 正式 App 使用的實作，Store 由依賴系統取得
    static var liveValue: Self {
        @Dependency(\.categoryStore) var store
        return Self(
            fetchCategories: { () throws(PersistenceError) in
                try await store.fetchAll().sorted()
            },
            addCategory: { rawName throws(PersistenceError) in
                let name = rawName.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else {
                    return
                }
                try await store.add(name)
            }
        )
    }

    /// 測試用的預設值，每個 closure 都未實作，測試沒覆寫就呼叫會直接失敗
    static var testValue: Self {
        Self(
            fetchCategories: unimplemented("CategoryService.fetchCategories", placeholder: []),
            addCategory: unimplemented("CategoryService.addCategory")
        )
    }
}

// MARK: - DependencyValues

extension DependencyValues {

    /// 供 reducer 以 `@Dependency(\.categoryService)` 取得的類別 Service
    var categoryService: CategoryService {
        get { self[CategoryService.self] }
        set { self[CategoryService.self] = newValue }
    }
}
```

`CategoryService+Preview.swift`：

```swift
#if DEBUG

// MARK: - DependencyKey

extension CategoryService {

    /// Preview 使用的假資料，只回傳固定內容；在正式 App 中誤用時 Debug 會立刻中止
    static var previewValue: Self {
        assert(
            RuntimeEnvironment.allowsPreviewStub,
            "CategoryService.previewValue 只能在 Preview、UI Test 或單元測試中使用"
        )
        return Self(
            fetchCategories: {
                ["餐飲", "交通", "娛樂"]
            },
            addCategory: { _ in }
        )
    }
}

#endif
```

### Client、Store、Database

- **要**：每個 Client、Store、Database 一個 `<Name>+Dependency.swift`，從 `tca/DependencyKey.swift` 複製，`__NAME__` 填完整型別名稱（例如 `APIClient`），放在該型別同資料夾；內容固定 `enum <Name>Key: DependencyKey` 與 `extension DependencyValues` 兩區。
- **要**：`liveValue` 為 computed property，回傳正式實作。
- **要**：`previewValue` 以 `#if DEBUG` 包住，回傳既有的 `Preview<Name>`（例如 `PreviewAPIClient`）；stub 的 `RuntimeEnvironment.allowsPreviewStub` 斷言保留。
- **要**：**不宣告 `testValue`**。只有 `liveValue` 的依賴在測試中未經 `withDependencies` 覆寫就存取時，TCA 會直接讓測試失敗；測 Service 的 `liveValue` 時漏注入 Mock 就會被擋下，不會連到真正的網路或資料庫。

## @Shared

- **要**：`@Shared` 只用於父子 Feature 之間的**記憶體內**狀態共享：父層 `State` 宣告 `@Shared var cart: Cart`，建立子 `State` 時以 `Shared<Cart>` 傳入。
- **避免**：`.appStorage`、`.fileStorage`、`.inMemory` 與任何自訂 persistence key。持久化是 Data 層的事，走 Store / Database，維持分層單向；`@Shared` 不是 UserDefaults 的替代品。
- **避免**：跨 Feature 模組共享 `@Shared`；能用 `Scope` 傳遞或 `delegate` 回傳就不用 `@Shared`。

## 測試

單元測試規則沿用 `project-structure.md` 的「測試目錄」，差別只在 Feature 型別取代 ViewModel：

- **要**：每個 Feature 型別一個 `<Screen>FeatureTests.swift`，從 `tca/FeatureTests.swift` 複製，位置鏡像到 Feature 模組層級；型別標 `@MainActor`，因為每個測試都用到 `@MainActor` 的 `TestStore`。測 Service 本身的 `<Feature>ServiceTests.swift` 不用 `TestStore`，不加 `@MainActor`（`file-templates.md` 測試一節）。
- **要**：一律用 `TestStore`，**不關 exhaustivity**：每個 `send` 與 `receive` 都寫出完整的狀態變化，未接收的 Action 與未斷言的變化就是測試失敗。
- **要**：`receive` 用 case key path（`store.receive(\.profileResponse.success)`），不依賴 `Action: Equatable`。成功值為 `Void` 的 `Result` 不可再接 `.success`（Swift 6.3.3 會在 IR 產生階段崩潰，已驗證），改為 `store.receive(\.xxxResponse)`。
- **要**：Service 沒有 Mock。`TestStore` 的 `withDependencies` 只覆寫這個測試用到的 closure（`$0.categoryService.addCategory = ...`），不整個替換 Service；沒覆寫的 closure 被呼叫時，`testValue` 的 `unimplemented` 會讓測試失敗。時間、UUID 等系統依賴用 TCA 內建的 `continuousClock`、`uuid` 覆寫，不自建。
- **要**：會失敗的 closure 先以 typealias 宣告成常數再注入：`let failingAdd: CategoryService.AddCategory = { _ in throw .saveFailed }`。以 `let` 加型別宣告、而且位置在函式本體、不在任何 closure 裡時，Swift 推斷得出 typed throws，closure 不用任何標註；寫在其他 closure 本體內（例如整個測試本體包在 `withDependencies` 或 `withIsolatedStorage` 內）或直接賦值給屬性時，要依 `formatting.md` 補 `throws(E)`。回傳特定值的 stub 直接在 `withDependencies` 內賦值，本體不會 throw，不用任何標註。
- **要**：要驗證呼叫次數或收到的參數時，用 `LockIsolated` 記錄，取代 Mock 的 `callCount` 與 `receivedArguments`。
- **要**：Service 本身的邏輯在 `<Feature>ServiceTests.swift` 測，位置同 `project-structure.md` 的測試目錄：以 `withDependencies` 把 Client / Store 換成 Mock，再取 `<Feature>Service.liveValue` 測正式實作。Client / Store 的 Mock 沿用 `tests/MockService.swift`，把 `Service` 換成 `Client` / `Store`。`testValue` 是給 Feature 測試用的替身，裡面沒有邏輯，不測它。驗證 Service 丟出的錯誤時用 `file-templates.md` 測試一節的 `actualError` 寫法，不用 `#expect(throws:)`。
- **要**：測試名稱的方法或行為段寫受測 Feature 自己的 Action case，也就是 When 那一次 `send` 最外層的那一層，和受測 Feature `core` 的 `switch` case 對得上；子層的動作寫進情境段。`view` 分組不算一層，改取裡面的 case：`.view(.task)` 寫 `task_`；`.binding(...)` 寫 `binding_`。父層送子層動作時照最外層取名，`path`、`destination` 同理：
  - `.lookupManagements(.element(id: id, action: .view(.saveButtonTapped)))` 寫 `lookupManagements_分類改名_同步更新訂單`，不寫內層的 `saveButtonTapped_`。
  - `.destination(.presented(.add(.view(.saveButtonTapped))))` 寫 `destination_新增頁按下儲存_關閉新增頁`。
- **要**：測試本體 Given / When / Then，受測的那一次 `send` 連同它的狀態 closure 都算 When，`receive` 與 `#expect` 為 Then。三個標記的位置照 `file-templates.md` 測試一節：寫在同一縮排層級，不寫進 `send` 的 closure。
- **要**：只有 `send`、沒有 `receive` 的測試，`// Then` 不寫進 `send` 的 closure：`send` 之後空一行寫 `// Then`，再用 `#expect(store.state.x == 值)` 斷言關鍵結果。`send` 的 closure 屬於 When，Then 段要有自己的斷言。有 `receive` 時照舊，`receive` 放 Then。
- **要**：前置狀態能直接設進初始 State 的就直接設，不用 `send` 走一遍：先 `var initial = CategoryListFeature.State()`、`initial.errorMessage = "儲存失敗"`，再建 `TestStore(initialState: initial)`。必須跑過 reducer 或 effect 才會有的前置狀態（例如正在執行的計時 effect），Given 可以 `send`／`receive`，一樣寫出完整的狀態變化。When 只留受測的那一次 `send`；Given 裡用來建立前置狀態的 `send` 不算 `file-templates.md`「一個測試只允許一組 When / Then」的第二個動作。
- **要**：`send`、`receive` 的狀態斷言 closure 與 `withDependencies` 的 closure 用 `$0`，本體有多個敘述也一樣，不另取參數名。這是 TCA 官方寫法，這三處的 `$0` 固定代表要修改的 State 或依賴，不會被誤讀，屬於 `formatting.md` `$0` 規則的「修改 `inout` 值的 closure」例外；其他 closure 照常具名。
- **避免**：`exhaustivity = .off`；測 View；在測試裡直接呼叫 `Feature().reduce(into:action:)`；為 `Path` / `Destination` 子 reducer 單獨開測試檔（它們透過父 Feature 的測試覆蓋，除非本身是獨立畫面）。

```swift
/// 新增類別時儲存失敗，畫面要顯示錯誤提示
@Test
func addButtonTapped_儲存失敗_顯示錯誤提示() async {
    // Given
    let failingAdd: CategoryService.AddCategory = { _ in
        throw .saveFailed
    }
    let store = TestStore(initialState: CategoryListFeature.State()) {
        CategoryListFeature()
    } withDependencies: {
        $0.categoryService.addCategory = failingAdd
    }

    // When
    ...
}

/// 只有 send 沒有 receive：send 連同狀態 closure 是 When，send 之後另寫 Then 斷言關鍵結果
@Test
func unpaidOnlyToggled_開啟_只顯示未付款() async {
    // Given
    let store = TestStore(initialState: PurchaseListFeature.State()) {
        PurchaseListFeature()
    }

    // When
    await store.send(.view(.unpaidOnlyToggled(true))) {
        $0.showsUnpaidOnly = true
    }

    // Then
    #expect(store.state.showsUnpaidOnly)
}

/// 計時中按下停止要取消計時；正在執行的 effect 無法設進初始 State，所以 Given 用 send／receive 啟動
@Test
func stopButtonTapped_計時中_停止計時() async {
    // Given
    let clock = TestClock()
    let store = TestStore(initialState: StopwatchFeature.State()) {
        StopwatchFeature()
    } withDependencies: {
        $0.continuousClock = clock
    }
    await store.send(.view(.startButtonTapped)) {
        $0.isRunning = true
    }
    await clock.advance(by: .seconds(1))
    await store.receive(\.timerTicked) {
        $0.elapsedSeconds = 1
    }

    // When
    await store.send(.view(.stopButtonTapped)) {
        $0.isRunning = false
    }

    // Then
    #expect(store.state.isRunning == false)
}

/// 按下儲存時，把輸入的名稱交給 Service 一次
@Test
func saveButtonTapped_名稱有效_新增類別一次() async {
    // Given
    let addedNames = LockIsolated<[String]>([])
    let store = TestStore(initialState: CategoryListFeature.State()) {
        CategoryListFeature()
    } withDependencies: {
        $0.categoryService.addCategory = { name in
            addedNames.withValue {
                $0.append(name)
            }
        }
    }

    // When
    ...

    // Then
    #expect(addedNames.value == ["新類別"])
}

/// Service 本身：名稱前後的空白要先去掉再存
@Test
func addCategory_名稱前後有空白_存入去掉空白的名稱() async throws {
    // Given
    let store = MockCategoryStore()
    let service = withDependencies {
        $0.categoryStore = store
    } operation: {
        CategoryService.liveValue
    }

    // When
    try await service.addCategory("  新類別  ")

    // Then
    #expect(store.addReceivedArguments == ["新類別"])
}
```

## 常見錯誤檢查清單

- [ ] TCA 專案出現 ViewModel、Coordinator、`@Entry`、`EnvironmentValues+Services.swift`，或 MVVM 專案出現 `@Reducer`
- [ ] Feature 型別本體分區順序不是 State → Action → Dependencies → Body；`Path` / `Destination` / `CancelID` 寫在本體內而非 Nested Types extension；`Destination.State` 缺 `Equatable` extension
- [ ] `body` 內直接寫 `Reduce { state, action in ... }` 閉包，而不是 `Reduce(core)`；`core` 不是 Private Method 區的第一個方法
- [ ] `State` 的 computed property 另開 `extension <Screen>Feature.State`，而非寫在 `State` 本體
- [ ] `State` 缺 `@ObservableState` 或 `Equatable`；`State` 持有 Service
- [ ] `Action` 缺 `view` / `delegate` 分組；View 送了 `view` 以外的 action；view case 用命令式命名
- [ ] `body` 收到 `.delegate` 沒有 `return .none`；`.delegate` 在本 Feature 內被處理
- [ ] Effect 用 `.run` 以外的方式；`Reduce` 內直接呼叫 Service；畫面出現的載入用 `onAppear` 而非 `.task` 加 `finish()`
- [ ] `NavigationStack` 不在 `<Feature>RootView`；非根畫面持有 `StackState`；一個畫面有兩個 `@Presents`
- [ ] Feature 模組之間引用對方的 Feature 型別（`AppFeature` 引用 `RootFeature` 除外）
- [ ] Service 寫成 protocol 加實作；用了 `@DependencyClient`、`XxxClient` 命名或型別下標取用；closure 屬性缺 typealias
- [ ] Service 缺 `testValue`，或 `testValue` 不是全部 `unimplemented`；`liveValue` 寫成 `static let` 或內有 `.shared`；`previewValue` 未包 `#if DEBUG` 或缺 `assert`
- [ ] Client / Store / Database 缺 `<Name>+Dependency.swift`，或宣告了 `testValue`
- [ ] `@Shared` 帶 persistence key；跨 Feature 模組共享
- [ ] 測試關閉 exhaustivity；Feature 測試整個替換 Service 而非只覆寫用到的 closure；用 Mock class 記錄 Service 呼叫而非 `LockIsolated`；`receive` 依賴 `Action: Equatable`
- [ ] 父層測試的名稱第一段寫了子層的內層 Action（如 `saveButtonTapped_`）而非受測 Feature 最外層的 case；`view` 分組被當成一層寫成 `view_`
- [ ] 能直接設進初始 State 的前置狀態卻在 Given 用 `send` 走一遍；When 有兩個以上的 `send`
- [ ] `// Then` 寫進 `send` 的 closure；只有 `send` 的測試在 `send` 之後缺 `// Then` 與 `#expect(store.state...)`
- [ ] Feature 型別超過 300 行卻未拆 `Path` / `Destination` 或子 Feature
