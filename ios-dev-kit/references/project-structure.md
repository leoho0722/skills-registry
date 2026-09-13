# Project Structure（專案目錄結構）

Leo Ho 個人 iOS 專案目錄結構規範。

## 目錄

- [Project Structure（專案目錄結構）](#project-structure專案目錄結構)
  - [目錄](#目錄)
  - [分層原則](#分層原則)
    - [Data 層內的兩種型別](#data-層內的兩種型別)
    - [UseCase（可選）](#usecase可選)
    - [Coordinator](#coordinator)
    - [依賴注入](#依賴注入)
  - [根目錄結構](#根目錄結構)
    - [模組化策略](#模組化策略)
  - [Feature 模組結構](#feature-模組結構)
  - [共用程式碼的擺放](#共用程式碼的擺放)
    - [Formatters](#formatters)
  - [測試目錄](#測試目錄)
    - [Mock 與 Preview stub](#mock-與-preview-stub)
  - [常見錯誤檢查清單](#常見錯誤檢查清單)

## 分層原則

架構是 **Feature-first 加內部分層的 MVVM 搭配 Coordinator**：第一刀依功能切成 Feature，每個 Feature 內再依技術層分成 Presentation / Domain / Data，跨 Feature 共用的技術能力放 Core。不是嚴格的 Clean Architecture：沒有 Repository 抽象、UseCase 是可選層、ViewModel 可直接依賴 Service protocol；agent 不得自行補上 Repository、Interactor、Presenter 等本規範沒有的層。Presentation 層另有 TCA 這個第二選擇，由使用者決定、一個專案只用一種；TCA 專案的 Presentation 與 Feature 模組結構見 `tca-architecture.md`，本檔其餘規則不變。

| 層 | 放什麼 | 對應樣板 |
|---|---|---|
| Presentation | View、ViewModel、Coordinator | `presentation/*` |
| Domain | Model、Enum、Error、UseCase（可選） | `domain/*` |
| Data | Service（該 Feature 專屬）與其 Preview stub | `data/*` |
| Core | Client、Store、Database、FormatStyle、Extensions、Environment、RuntimeEnvironment、DesignSystem | `core/*` 與 `data/Service.swift` 改後綴 |

依賴方向固定單向，箭頭指向被依賴者：

```text
Presentation ──▶ Domain ◀── Data
      │             │         │
      └─────────▶ Core ◀──────┘
```

- **要**：Presentation 依賴 Domain 的型別與 Data 的 protocol；ViewModel 持有 `any <Name>ServiceProtocol`，讀寫 Domain 的 Model。
- **要**：Data 依賴 Domain，Service 回傳 Domain 的 Model、丟 Domain 的 Error；Data 依賴 Core 的 Client / Store / Database。
- **要**：Domain 只依賴 Core 與 Foundation；Core 只依賴 Foundation 與 SwiftUI，不知道任何 Feature 存在。
- **要**：跨 Feature 只允許引用對方 **Domain 層的 Model 與 Error**；需要對方 Service 的能力時，由 ViewModel 或 UseCase 組合，不直接注入對方的 Service。
- **避免**：反向依賴：Domain `import SwiftUI`、Domain 知道 Service 存在、Data 知道 ViewModel 或 View 存在、Core 引用任何 Feature 的型別。
- **避免**：跨 Feature 引用對方的 View、ViewModel、Coordinator、Service；Feature 之間的導航一律經由 App 層的根 Coordinator。

### Data 層與 Core 的技術型別

| 種類 | 職責 | 位置 | 可依賴 |
|---|---|---|---|
| Client | 遠端服務的技術入口（HTTP、WebSocket、第三方 SDK） | `Core/Networking/` | 系統 framework、第三方 SDK |
| Store | 無 schema 的本機儲存（UserDefaults、Keychain、檔案、快取） | `Core/Storage/` | 系統 framework |
| Database | 有 schema 與 migration 的結構化本機資料庫入口，SwiftData 以 `@ModelActor` 實作，一個 App 通常只有一個 | `Core/Persistence/` | SwiftData / Core Data |
| Service | 面向業務的一組操作，組合上面三者 | `Features/<Feature>/Data/` | Client / Store / Database，**不可依賴其他 Service** |

後綴與資料夾一對一：看到 `<Name>Client` 就在 `Networking/`，`<Name>Store` 在 `Storage/`，`<App>Database` 在 `Persistence/`；三者之間不互相依賴。

### UseCase（可選）

跨多個 Service 的流程預設放在 ViewModel。只有當同一流程被多個 ViewModel 重複使用時，才在 `Domain/UseCases/` 以 `domain/UseCase.swift` 樣板建立：一個 UseCase 一個檔案，init 注入所需的 Service，對外只暴露一個 `execute` 方法。引入前先確認確實有重複，不預先建立空的 `UseCases/` 資料夾。

### Coordinator

每個 Feature 一個 Coordinator，放在該 Feature 的 `Presentation/` 內，以 `presentation/Coordinator.swift` 樣板建立。App 層有一個根 Coordinator 持有各 Feature 的 Coordinator，負責 Feature 之間的切換；Feature 之間不互相引用。多步驟流程（onboarding、結帳）視為獨立 Feature，以 `presentation/FlowCoordinator.swift` 樣板建立，由呼叫它的 Feature 以 `fullScreenCover` 呈現。

### 依賴注入

init 注入為主；Service 透過 SwiftUI Environment 送到 View。方案 A 的 `@Entry` key 集中放 `Core/Environment/EnvironmentValues+Services.swift` 一個檔案，方案 B、C 隨 Service 所在 module 宣告（見「B 與 C 共通的 package 規則」）。不使用 `.shared` 單例，不引入 DI container。細則見 `file-templates.md` 的 Service 一節。

## 根目錄結構

專案結構有三種方案，差別在 SPM package 切到哪一層。**新專案與既有專案都由使用者決定**，agent 不預設任何一種；對既有專案 agent 只負責偵測並提出建議值。

### 方案判斷

- **新專案**：詢問使用者三選一，附「方案選擇」表的適用情境，沒有特殊需求時建議 A。不自行決定。
- **既有專案**：先依下表偵測，再把偵測結果與依據（看到了哪些目錄與檔案）告訴使用者，請使用者確認或改選。偵測結果只是建議值，使用者可能正打算遷移，或專案結構不完全符合任一方案；決定權在使用者。
- **偵測結果與使用者的選擇不一致時**（例如偵測到 A 但使用者選 C），視為使用者要求遷移，依「方案選擇」的遷移方向處理，並在動手前列出會搬動的目錄讓使用者確認。

| 偵測到 | 方案 |
|---|---|
| 沒有 `Packages/` 目錄，所有程式碼在 App target 內 | A |
| `Packages/` 內有 `Core`、`DesignSystem`、`Shared`，`Features/` 仍在 App target 且只有 `Presentation/` | B |
| `Packages/Features/` 內有 `<Feature>Feature` package | C |

### 方案選擇

| 方案 | 邊界由誰守 | 適合 | 不適合 |
|---|---|---|---|
| A 單一 App target | 紀律與 code review | 單人或小團隊、只有一個 App target、Feature 少於八個 | 已知會有 Widget 或第二個 App |
| B 底層抽成 local package | 底層不可反向依賴由編譯器守，Feature 之間仍靠紀律 | 一開始就有第二個 target，或底層要與另一個 App 共用，但 Feature 由同一組人開發 | 多組人平行開發 |
| C 每個 Feature 一個 package | 全部由編譯器守 | 多組人各自負責 Feature、Feature 超過八個、Feature 要進多個 App | 單人專案，設定與 `public` 噪音的成本高於收益 |

方案之間可以遷移，方向固定 A → B → C：出現第二個 target 時 A 升 B（抽 `Core`、`DesignSystem`、`Shared`）；多組人平行開發或全量編譯超過三分鐘時 B 升 C；也可只把特定 Feature 抽成 package。遷移只在使用者要求時做，agent 看到條件出現只提示，不主動拆。

### 方案 A：單一 App target

資料夾即分層邊界。

```text
<Project>/
├── <Project>.xcodeproj
├── <Project>/                            # App target
│   ├── App/
│   │   ├── <Project>App.swift            # @main；在根部以 .environment 注入正式 Service
│   │   └── AppCoordinator.swift          # 根 Coordinator，持有各 Feature 的 Coordinator，負責 Feature 之間的切換
│   ├── Features/
│   │   ├── <Feature>/                    # 結構見「Feature 模組結構」
│   │   └── <Feature>/
│   ├── Core/
│   │   ├── DesignSystem/                 # Tokens/、Styles/、Components/，見「共用程式碼的擺放」
│   │   ├── Environment/
│   │   │   ├── EnvironmentValues+Services.swift
│   │   │   └── RuntimeEnvironment.swift
│   │   ├── Extensions/                   # <Type>+Extensions.swift
│   │   ├── Formatters/                   # <Name>FormatStyle.swift
│   │   ├── Networking/                   # <Name>Client
│   │   ├── Persistence/                  # <App>Database、@Model、schema、migration；引入 SwiftData / Core Data 時才建
│   │   └── Storage/                      # <Name>Store
│   └── Resources/                        # 不細分子資料夾
│       ├── Assets.xcassets
│       └── Localizable.xcstrings
├── <Project>Tests/                       # 單元測試，結構見「測試目錄」
└── <Project>UITests/
```

- **要**：`App/` 只放進入點與根 Coordinator，不放任何業務程式碼。
- **要**：Client / Store / Database 一律放 `Core/`，不放任何 Feature 的 `Data/`；它們是跨 Feature 共用的技術能力，放進某個 Feature 會造成其他 Feature 反向依賴。
- **要**：`Core/` 的子資料夾依技術能力命名，日後新增能力（`Analytics/`、`Logging/`）比照建立；`Persistence/` 不預先建，引入 SwiftData 或 Core Data 時才建，與 `UseCases/` 同一原則。
- **要**：`Resources/` 不細分子資料夾，字型、JSON 等直接平放；`Assets.xcassets` 內部再依需求分 folder。
- **避免**：根目錄出現 `Utils/`、`Helpers/`、`Common/`、`Misc/` 這類無主資料夾；所有共用程式碼依內容歸入 `Core/` 的對應子資料夾。

### B 與 C 共通的 package 規則

- **`Package.swift` 固定 `swift-tools-version: 6.0`**，`swiftLanguageModes: [.v6]`，`platforms` 與 App 的 deployment target 一致；一個 package 一個 library target 加一個 test target，不在同一 package 內放多個 library。
- **跨 module 使用的型別、init、stored property、方法標 `public`**；同 package 內跨 target 用 `package`。`public` struct 的 memberwise init 不會自動合成，要手寫 `public init`。Model 的 stored property 標 `public let`。
- **只暴露必要的表面**：Feature package 對外只有 `<Feature>RootView`、Coordinator 與 Service protocol；ViewModel、其他畫面的 View、Preview stub 維持 internal。
- **Preview stub 放 package 的 `Sources/<Module>/Preview/`**，整檔 `#if DEBUG`；package 沒有 Development Assets 機制。
- **`@Entry` 隨 Service 所在 module 宣告**，檔名 `EnvironmentValues+<Feature>Service.swift`，放該 module 根目錄；App target 不再有集中檔。
- **測試放各 package 的 `Tests/<Module>Tests/`**，Mock 放該 test target 的 `Mocks/`；App target 的測試只剩留在 App 內的東西。
- **App target 以 local package 依賴引用**（Xcode 的 Add Local Package 或 `xcodeproj` 內的 `XCLocalSwiftPackageReference`），不用 remote URL。

### 方案 B：底層抽成 local package

`Core`、`DesignSystem`、`Shared` 三個 package。`Shared` 收各 Feature 的 Domain 與 Data，`Data/` 必須跟著 `Domain/` 一起出去，因為第二個 target 要的是「拿到資料」，不只是型別。Presentation 留在 App target。代價是一個 Feature 被拆到兩處。

```text
<Project>/
├── Packages/
│   ├── Core/
│   │   ├── Package.swift                 # 無依賴
│   │   ├── Sources/Core/                 # 內容同單一 target 的 Core/，DesignSystem 除外
│   │   └── Tests/CoreTests/
│   ├── DesignSystem/
│   │   ├── Package.swift                 # 無依賴，與 Core 平行
│   │   ├── Sources/DesignSystem/         # Tokens/、Styles/、Components/、Resources/
│   │   └── Tests/DesignSystemTests/
│   └── Shared/
│       ├── Package.swift                 # 依賴 Core
│       ├── Sources/Shared/
│       │   └── <Feature>/
│       │       ├── Domain/               # 型別標 public
│       │       ├── Data/
│       │       └── Preview/              # Preview stub，整檔 #if DEBUG
│       └── Tests/SharedTests/
│           ├── <Feature>/
│           └── Mocks/
├── <Project>/                            # App target，依賴 Core、Shared
│   ├── App/
│   ├── Features/<Feature>/Presentation/  # 只剩 View、ViewModel、Coordinator
│   └── Resources/
├── <Project>Widget/                      # 第二個 target，依賴 Core、Shared
├── <Project>Tests/                       # 只剩 Presentation 的測試與其 Mocks/
└── <Project>UITests/
```

`Packages/Shared/Package.swift`：

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Shared",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "Shared", targets: ["Shared"])
    ],
    dependencies: [
        .package(path: "../Core")
    ],
    targets: [
        .target(name: "Shared", dependencies: ["Core"]),
        .testTarget(name: "SharedTests", dependencies: ["Shared"])
    ],
    swiftLanguageModes: [.v6]
)
```

- **要**：`Shared` 內仍依 Feature 分子資料夾，每個 Feature 的 Domain 與 Data 型別、Service protocol 與正式實作標 `public`。
- **要**：App target 的 `Features/<Feature>/` 只剩 `Presentation/`；ViewModel `import Shared` 取得 Model 與 Service protocol。
- **避免**：把 Presentation 也搬進 `Shared`，那就變成 C 但沒有 Feature 隔離，兩者的缺點都拿到。

### 方案 C：每個 Feature 一個 package

跨 Feature 共用的 Model 與 Error 不能留在任一 Feature package，否則 Feature 互相依賴，所以 `Shared` 只放這類型別。`AppCoordinator` 成為唯一知道所有 Feature 的地方，跨 Feature 導航經由它轉發。

```text
<Project>/
├── Packages/
│   ├── Core/                             # 無依賴
│   ├── DesignSystem/                     # 無依賴，與 Core 平行
│   ├── Shared/                           # 依賴 Core；只放跨 Feature 共用的 Model、Error
│   └── Features/
│       └── <Feature>Feature/
│           ├── Package.swift             # 依賴 Core、DesignSystem、Shared；不依賴其他 Feature
│           ├── Sources/<Feature>Feature/
│           │   ├── Presentation/         # Root/ 的 View 與 Coordinator 標 public，其餘 internal
│           │   ├── Domain/
│           │   ├── Data/
│           │   ├── Preview/              # #if DEBUG
│           │   └── EnvironmentValues+<Feature>Service.swift   # @Entry 隨 module 放
│           └── Tests/<Feature>FeatureTests/
│               └── Mocks/
├── <Project>/                            # App target，依賴所有 Feature package
│   ├── App/
│   │   ├── <Project>App.swift
│   │   └── AppCoordinator.swift          # 跨 Feature 導航的唯一樞紐
│   └── Resources/
├── <Project>Widget/                      # 依賴 Core、Shared 與需要的 Feature
└── <Project>UITests/                     # 跨 Feature 流程在 App 層測
```

`Packages/Features/<Feature>Feature/Package.swift`：

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProfileFeature",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "ProfileFeature", targets: ["ProfileFeature"])
    ],
    dependencies: [
        .package(path: "../../Core"),
        .package(path: "../../DesignSystem"),
        .package(path: "../../Shared")
    ],
    targets: [
        .target(name: "ProfileFeature", dependencies: ["Core", "DesignSystem", "Shared"]),
        .testTarget(name: "ProfileFeatureTests", dependencies: ["ProfileFeature"])
    ],
    swiftLanguageModes: [.v6]
)
```

- **要**：Feature package 的 `dependencies` 只有 `Core`、`DesignSystem`、`Shared`，**不列任何其他 Feature**；需要對方的 Model 時把該 Model 搬進 `Shared`。
- **要**：跨 Feature 導航經由 `AppCoordinator`：Feature 的 Coordinator 以 `public` 的 delegate protocol 或 closure 通知「需要離開本 Feature」，`AppCoordinator` 決定去哪。Feature 不知道其他 Feature 的 `Route`。
- **要**：App target 的 `App/` 只 `import` 各 Feature package 並在 `AppCoordinator` 組裝；`Resources/` 留在 App target，Feature 專屬的 asset 放各自 package 的 `Sources/<Module>/Resources/` 並在 `Package.swift` 宣告 `resources: [.process("Resources")]`。
- **避免**：為了圖方便讓 Feature A 依賴 Feature B；出現這種需求就是 `Shared` 該收東西，或 `AppCoordinator` 該轉發。

## Feature 模組結構

新增一個 Feature 時固定建立的結構，方案 A 放 `Features/<Feature>/`，方案 B 的 Presentation 在 App target、Domain 與 Data 在 `Packages/Shared/Sources/Shared/<Feature>/`，方案 C 整組在 `Packages/Features/<Feature>Feature/Sources/<Feature>Feature/`。

```text
Features/<Feature>/
├── Presentation/
│   ├── <Feature>Coordinator.swift        # presentation/Coordinator.swift；流程型 Feature 用 FlowCoordinator.swift
│   ├── Root/                             # 根畫面：Feature 的進入點，串 NavigationStack
│   │   ├── <Feature>RootView.swift       # presentation/View.swift
│   │   └── <Feature>RootViewModel.swift  # presentation/ViewModel.swift
│   └── <Screen>/                         # 其他畫面，一個畫面一個資料夾
│       ├── <Screen>View.swift
│       ├── <Screen>ViewModel.swift
│       └── <Screen>View+<Part>.swift     # 選用，過大的子 View 拆檔
├── Domain/
│   ├── <Name>.swift                      # domain/Model.swift、domain/Enum.swift、domain/EnumWithAssociatedValue.swift
│   ├── <Feature>Error.swift              # domain/Error.swift
│   └── UseCases/                         # 可選，出現重複流程才建
│       └── <Verb><Noun>UseCase.swift     # domain/UseCase.swift
├── Data/
│   └── <Feature>Service.swift            # data/Service.swift
└── Preview Content/                      # 方案 A；B、C 改為 Preview/ 並整檔 #if DEBUG
    └── <Feature>Service+Preview.swift    # data/Service+Preview.swift
```

### 固定建立的內容

- **要**：新 Feature 一律建 `Presentation/`、`Domain/`、`Data/`、`Preview Content/` 四個資料夾，即使某層暫時只有一個檔案；`UseCases/` 不預先建。
- **要**：最小檔案組六個：Coordinator、`Root/` 的 View 與 ViewModel、Error、Service、Preview stub。缺任一個就不是完整的 Feature。Model 與 Enum 依需求建立。
- **要**：方案 A 的 `Preview Content/` 每個 Feature 各自一個，建立時把路徑加進 App target 的 `DEVELOPMENT_ASSET_PATHS`，Release 不打包。
- **要**：Feature 命名用名詞、單數、UpperCamelCase（`Profile`、`Checkout`、`Onboarding`），資料夾名與型別前綴一致。

### Presentation 依畫面分資料夾

- **要**：每個畫面一個資料夾，內含該畫面的 View 與 ViewModel 各一個檔案；資料夾名、檔名前綴、型別前綴三者一致（`EditProfile/EditProfileView.swift` 內是 `EditProfileView`）。
- **要**：根畫面固定放 `Root/`，型別命名 `<Feature>RootView` 與 `<Feature>RootViewModel`；它是 Feature 的進入點，`NavigationStack`、`navigationDestination`、`sheet` 三行只寫在這裡。套樣板時 `__NAME__` 填 `<Feature>Root`。
- **要**：Coordinator 不屬於任何畫面，放 `Presentation/` 根。
- **要**：只在同一畫面使用、且大到需要獨立檔案的子 View，放該畫面資料夾內，檔名 `<Screen>View+<Part>.swift`，內容是 `extension <Screen>View` 的 Private Views；跨畫面共用的子 View 抽到 `Core/`，位置見「共用程式碼的擺放」。
- **避免**：一個畫面資料夾內出現第二個 ViewModel，那代表它是另一個畫面；畫面資料夾內放 Model 或 Service。

### Service 與拆分

- **要**：一個 Feature 一個 Service，命名 `<Feature>Service`。需要第二個 Service 時，代表責任該拆或它是另一個 Feature，不以 `<Feature>XxxService` 的方式加第二個。
- **要**：流程型 Feature（Onboarding、Checkout）結構相同，只有 Coordinator 換成 `FlowCoordinator.swift` 樣板；各步驟仍是一個畫面一個資料夾。
- **要**：符合任一條件就拆成新 Feature：出現第二個 Service 的需求、畫面之間沒有共用的 Coordinator 導航關係、另一個 Feature 需要引用這裡的 View。

## 共用程式碼的擺放

| 東西 | 位置 | 何時放這裡 |
|---|---|---|
| Client / Store / Database | `Core/Networking/`、`Core/Storage/`、`Core/Persistence/` | 一開始就放，見「根目錄結構」 |
| `@Entry` 清單、`RuntimeEnvironment` | `Core/Environment/` | 一開始就放 |
| 對系統或第三方型別的擴充 | `Core/Extensions/<Type>+Extensions.swift` | 一開始就放，不在 Feature 內寫 extension |
| 自訂 `FormatStyle` | `Core/Formatters/<Name>FormatStyle.swift` | 一開始就放，一個樣式一個檔案 |
| 視覺定義與共用 UI 元件 | `Core/DesignSystem/`，結構見下 | Tokens 與 Styles 一開始就放；Components 在第二個 Feature 要用時才抽 |
| 跨 Feature 共用的 Model 與 Error | 方案 A、B 留在原 Feature 的 `Domain/`（允許跨 Feature 引用 Domain）；方案 C 搬到 `Shared` | 方案 A、B 不搬，方案 C 必搬 |
| 常數 | 只有一個型別用時放該型別的 Nested Types；跨型別的版面尺寸放 `Core/DesignSystem/Tokens/` | 出現第二個使用者才進 Core |

- **要**：抽到 `Core/` 的門檻是「第二個 Feature 出現需求」，不預先抽；唯一例外是 Extensions、Formatters、Tokens、Styles，它們天生跨 Feature。
- **要**：只在同一 Feature 內多個畫面共用的子 View，放該 Feature 的 `Presentation/Components/`，不進 `Core/`。
- **避免**：`Core/` 內出現業務名詞。`Core/DesignSystem/Components/ProfileCard.swift` 是錯的，它該叫 `UserCard` 或留在 Profile Feature。
- **避免**：Feature 之間直接引用對方的 Component 或 Extension；要共用就抽到 `Core/`。
- **避免**：`Core/` 出現 `Utils/`、`Helpers/`、`Common/`，所有東西依上表歸位。

### DesignSystem

視覺相關的東西集中一處，內部分三層，依賴方向固定 Components → Styles → Tokens，不反向：

```text
DesignSystem/
├── Tokens/                               # 語意定義：Color+Semantic.swift、Font+Semantic.swift、Spacing.swift
├── Styles/                               # ButtonStyle、ViewModifier、TextFieldStyle
├── Components/                           # 可直接放進畫面的 View：PrimaryButton、EmptyStateView、LoadingOverlay
└── Resources/                            # 顏色與圖示的 .xcassets（方案 B、C 才需要，方案 A 用 App 的 Assets.xcassets）
```

- **方案 A**：放 `Core/DesignSystem/`，上面三個子資料夾直接建立；顏色與圖示用 App target 的 `Assets.xcassets`。
- **方案 B 與 C**：抽成獨立的 `Packages/DesignSystem/`，與 `Core` 平行、**互不依賴**，兩者都只依賴 SwiftUI；Feature 同時依賴兩者。升級 A → B 時，DesignSystem 與 Core、Shared 一起抽出，A 的資料夾結構就是 package 的 `Sources/DesignSystem/` 結構，不用重排。
- **要**：Tokens 只放語意名稱（`Color.brandPrimary`、`Font.headline`、`Spacing.medium`），不放原始值的直接使用者；畫面內不得出現 `Color(red:green:blue:)` 或 `.padding(13)` 這種未經 Token 的值。
- **要**：Components 一律有 `#Preview`，且 Preview 不依賴任何 Service。
- **要**：package 形式時，`.xcassets` 放 `Sources/DesignSystem/Resources/` 並在 `Package.swift` 宣告 `resources: [.process("Resources")]`，程式內以 `Bundle.module` 取用；自訂字型在 App 啟動時以 `CTFontManagerRegisterFontsForURL` 註冊，不能靠 `Info.plist` 的 `UIAppFonts`。
- **避免**：DesignSystem 依賴 `Core` 或任何 Feature；出現這種需求代表那個東西不屬於 DesignSystem。

### Formatters

自訂 `FormatStyle` 實作放在 `Core/Formatters/`，一個樣式一個檔案，檔名 `<Name>FormatStyle.swift`，對應測試放在測試 target 的鏡像路徑。View 與 ViewModel 都不得自行定義格式化邏輯，規則見 `file-templates.md` 的 View 一節。

## 測試目錄

單元測試 target 鏡像主 target 的資料夾，但只到 Feature 層級，測試檔平放不再依畫面分子資料夾。

```text
<Project>Tests/
├── Features/<Feature>/
│   ├── <Feature>RootViewModelTests.swift   # 鏡像 Presentation，只測 ViewModel
│   ├── <Screen>ViewModelTests.swift
│   ├── <Feature>ServiceTests.swift         # 鏡像 Data
│   └── <Verb><Noun>UseCaseTests.swift      # 鏡像 Domain/UseCases
├── Core/
│   ├── Formatters/<Name>FormatStyleTests.swift
│   ├── Extensions/<Type>+ExtensionsTests.swift
│   └── Networking/<Name>ClientTests.swift
├── Mocks/                                  # 平放，不分子資料夾
│   ├── Mock<Feature>Service.swift          # tests/MockService.swift
│   └── Mock<Name>Client.swift
└── Fixtures/                               # 測試用固定資料
    ├── <Model>+Fixture.swift               # extension <Model> { static func fixture(...) }
    └── <model>.json                        # 只給解碼測試用
```

### 測什麼

- **要**：只為 ViewModel、Service、Client、Store、Database、UseCase、FormatStyle、Extensions 寫單元測試；測試檔名 `<TypeUnderTest>Tests.swift`，位置鏡像該型別在主 target 的資料夾。
- **要**：Model 與 Enum 預設不測；例外是有手寫 `init(from:)` / `encode(to:)`、手寫 `init?(rawValue:)`、或 computed property 含判斷邏輯時，只測那些手寫的部分。
- **避免**：為 View、Coordinator 寫單元測試；View 由 Preview 與 UI Test 覆蓋，Coordinator 的導航由 UI Test 覆蓋。
- **避免**：一個測試檔測多個型別，或測試檔的位置與主 target 不對應。

### Mocks 與 Fixtures

- **要**：Mock 一律放 `Mocks/` 平放，不依 Feature 分子資料夾；跨 Feature 測試共用，命名與內容依 `file-templates.md` 的 `tests/MockService.swift` 一節。
- **要**：Fixture 以 extension 形式提供，一個 Model 一檔 `<Model>+Fixture.swift`，放 `Fixtures/`：

  ```swift
  extension Profile {

      /// 測試用的固定個人資料，參數都有預設值，只覆寫測試關心的欄位。
      ///
      /// - Parameters:
      ///   - id: 識別碼。
      ///   - name: 顯示名稱。
      ///   - isVerified: 是否已驗證。
      /// - Returns: 一筆可直接用於測試的個人資料。
      static func fixture(
          id: UserID = UserID(rawValue: "user-1"),
          name: String = "Leo",
          isVerified: Bool = true
      ) -> Profile {
          Profile(id: id, name: name, isVerified: isVerified)
      }
  }
  ```

- **要**：命名固定 `fixture`，不用 `stub`、`sample`、`mock`、`dummy`；所有參數都有預設值，測試只覆寫它關心的欄位。
- **要**：JSON 檔只給解碼測試用，檔名小寫 `<model>.json`，內容與後端實際回應一致；以 `Bundle(for:)` 或 Swift Testing 的 `Bundle.module` 讀取。
- **避免**：在測試方法內手刻完整的 Model 實例；Fixture 內放隨機值或依賴目前時間。

### Mock 與 Preview stub 的位置

| 型別 | 位置 |
|---|---|
| `Mock<Name>Service` | 測試 target 的 `Mocks/`，不放主 target |
| `Preview<Name>Service` | 方案 A 在該 Feature 的 `Preview Content/`，Xcode 的 Development Assets 設定排除於 Release；方案 B、C 在 package 的 `Preview/`，整檔 `#if DEBUG` |

### 方案 B、C 的測試

各 package 的 `Tests/<Module>Tests/` 內部結構與上面相同：鏡像該 module 的 `Sources/`，`Mocks/` 與 `Fixtures/` 隨 package 平放。App target 的 `<Project>Tests/` 只剩留在 App 內的東西（方案 B 為各 Feature 的 Presentation，方案 C 為 `App/`）。UI Test 不隨 package，一律在 `<Project>UITests/`。

## 常見錯誤檢查清單

- [ ] 出現 Repository、Interactor、Presenter 等本規範沒有的層
- [ ] 反向依賴：Domain `import SwiftUI`、Data 引用 View 或 ViewModel、Core 引用任何 Feature
- [ ] 跨 Feature 引用對方的 View、ViewModel、Coordinator、Service，或 Feature 之間直接導航而未經 `AppCoordinator`
- [ ] 建立新專案未詢問方案，或對既有專案未告知偵測結果就自行決定
- [ ] Client / Store / Database 放在 Feature 的 `Data/` 而非 `Core/`；後綴與資料夾不對應
- [ ] `App/` 出現業務程式碼；根目錄或 `Core/` 出現 `Utils/`、`Helpers/`、`Common/`、`Misc/`
- [ ] 預先建立空的 `UseCases/`、`Persistence/`、`Packages/`
- [ ] 新 Feature 缺四個資料夾或六個最小檔案；根畫面不在 `Root/` 或型別不叫 `<Feature>RootView`
- [ ] 畫面資料夾內有第二個 ViewModel、Model 或 Service；一個 Feature 出現第二個 Service
- [ ] `Core/` 出現業務名詞；只有一個 Feature 用的 Component 被抽進 `Core/`
- [ ] DesignSystem 依賴 `Core` 或 Feature；畫面內出現未經 Token 的顏色、字型、間距
- [ ] Feature package 依賴其他 Feature package；`Package.swift` 缺 `swiftLanguageModes: [.v6]`
- [ ] 測試檔位置未鏡像主 target；為 View 或 Coordinator 寫單元測試；Mocks 或 Fixtures 分了子資料夾
- [ ] Fixture 不叫 `fixture`、參數沒有預設值、內含隨機值或目前時間
