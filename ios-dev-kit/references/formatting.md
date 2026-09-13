# Code Formatting（排版規則）

Leo Ho 個人 Swift 排版規範。若專案有 `.swiftformat` 或 `.swift-format` 設定檔，以設定檔為準；本檔補充設定檔無法表達的規則。

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

| 項目 | 規則 |
|---|---|
| 縮排 | 4 個空格，不用 tab；續行（斷行後的下一行）同樣縮排 4 格 |
| 每行長度上限 | 100 字元，含縮排；超過時依「換行與斷行」一節處理，不以縮短命名或刪除標籤來壓行 |
| 單檔長度上限 | 300 行（不含檔頭與空行）；超過時依 `file-templates.md` 的規則以 extension 分檔，不放寬上限 |
| 大括號 | 開括號與宣告同行（`func foo() {`），閉括號單獨一行並對齊宣告起始；不使用 Allman 風格 |
| 檔尾 | 保留一個換行，不多不少 |
| 尾隨空白 | 不允許，包含空行與只含縮排的行 |

Xcode 設定對應：Settings → Text Editing → Indentation 設 Spaces / 4；Editing 勾選 Automatically trim trailing whitespace 與 Including whitespace-only lines；Display 的 Page guide at column 設 100。

## 換行與斷行

- **要**：超過 100 字元時，在逗號之後或運算子**之前**斷行，運算子（`&&`、`||`、`+`、`??`、`.`）放在續行行首；一般敘述的續行固定縮排 4 格。
- **要**：`if` / `guard` 有多個條件且整行超過 100 時，每個條件獨立一行；第一個條件與關鍵字同行，其餘條件**對齊第一個條件的起始欄位**（`guard` 加一個空格後為第 6 欄、`if` 加一個空格後為第 3 欄），這是 Xcode 自動縮排的預設行為。
- **要**：`guard` 的 `else {` 與最後一個條件同行；`if` 的 `{` 與最後一個條件同行。
- **要**：超長字串不斷行，允許超過 100；需要多行時用 `"""` 多行字串字面值。
- **避免**：用 `+` 串接字串來壓行，會讓搜尋字串失效。
- **避免**：`if` / `guard` 的條件續行用固定 4 格，會與本體同層而失去視覺分界。
- **避免**：在 `import`、`case` 宣告、單一參數的函式簽章斷行，這三種超過 100 也維持一行。
- **要**：`switch` 的每個 `case` 本體一律另起一行縮排 4 格，即使只有一個表達式；不寫成 `case .x: value` 單行，`default` 同樣適用。`case` 之間不空行。

運算子放行首：

```swift
let isEligible = user.isVerified
    && user.age >= 18
    && !user.isSuspended

let displayName = profile.nickname
    ?? profile.fullName
    ?? "Unknown"
```

`if` 多條件，續行對齊第一個條件（3 格），`{` 與最後一個條件同行：

```swift
if let profile = viewModel.profile,
   profile.isComplete,
   !profile.isArchived {
    showProfile(profile)
}
```

`guard` 多條件，續行對齊第一個條件（6 格），`else {` 與最後一個條件同行：

```swift
guard let profile = viewModel.profile,
      profile.isComplete,
      !profile.isArchived else {
    return
}
```

`while` 同 `if` 對齊（6 格）。條件對齊只適用於 `if` / `guard` / `while` 的條件列表；運算子斷行與其他敘述的續行仍固定 4 格，兩者不混用。

## 參數與引數對齊

適用於函式與方法的宣告、`init` 宣告，以及所有呼叫端，四者同一套規則。

- **要**：二選一，所有參數放同一行，或每個參數獨立一行；換行時每個參數一行，續行縮排 4 格。
- **要**：符合以下任一條件即每個參數獨立一行：整行超過 100 字元（即使參數不超過三個）；參數數量超過三個（即使整行不超過 100）。
- **要**：換行時右括號單獨一行，對齊宣告或呼叫的起始欄位；回傳型別、`async throws`、`{` 接在右括號後同一行。
- **避免**：部分換行（前兩個參數同行、第三個換行），diff 中會讓無關的參數跟著移動。
- **避免**：右括號緊接最後一個參數，回傳型別會藏在參數尾巴，且參數區塊與本體失去分界。
- **避免**：為了塞進一行而縮短參數標籤或省略預設值。

```swift
// 宣告：超過三個參數，每個一行，右括號單獨一行
/// 取得使用者的個人資料。
///
/// - Parameters:
///   - id: 使用者識別碼。
///   - includeDetails: 是否連同詳細欄位一起取得。
///   - cachePolicy: 要不要用先前抓過的資料。
///   - timeout: 最多等多久。
/// - Returns: 該使用者的個人資料。
/// - Throws: 找不到使用者、逾時或網路失敗時丟出。
func fetchProfile(
    id: String,
    includeDetails: Bool = false,
    cachePolicy: CachePolicy = .default,
    timeout: Duration = .seconds(30)
) async throws -> Profile {
    ...
}

// 宣告：兩個參數且未超過 100，維持一行
/// 取得使用者的個人資料。
///
/// - Parameters:
///   - id: 使用者識別碼。
///   - includeDetails: 是否連同詳細欄位一起取得。
/// - Returns: 該使用者的個人資料。
/// - Throws: 找不到使用者或網路失敗時丟出。
func fetchProfile(id: String, includeDetails: Bool = false) async throws -> Profile

// 呼叫：與宣告同一套規則
let profile = try await service.fetchProfile(
    id: user.id,
    includeDetails: true,
    cachePolicy: .reloadIgnoringCache,
    timeout: .seconds(10)
)

// init：同上
/// 建立結帳畫面的 ViewModel，四個來源缺一不可。
///
/// - Parameters:
///   - profileService: 取得個人資料的物件。
///   - orderService: 取得與建立訂單的物件。
///   - paymentService: 執行付款的物件。
///   - analytics: 回報使用行為的物件。
init(
    profileService: any ProfileServiceProtocol,
    orderService: any OrderServiceProtocol,
    paymentService: any PaymentServiceProtocol,
    analytics: any AnalyticsClientProtocol
) {
    self.profileService = profileService
    self.orderService = orderService
    self.paymentService = paymentService
    self.analytics = analytics
}
```

## 空行規則

| 位置 | 空行數 |
|---|---|
| 檔頭註解與 `import` 之間 | 1 |
| `import` 區塊與第一個宣告之間 | 1 |
| 型別、extension 的開括號之後 | 1 |
| 型別、extension 的閉括號之前 | 0 |
| `// MARK:` 前後 | 各 1 |
| stored property 之間、computed property 之間 | 1 |
| `case` 之間 | 1，不論數量多寡與有無 associated value，一律空行 |
| 方法之間 | 1 |
| 頂層宣告之間（型別與 extension、extension 與 extension） | 1 |
| 函式內邏輯區塊之間 | 最多 1，不連續兩個空行 |
| 函式本體的第一行之前與最後一行之後 | 0，本體不以空行開頭或結尾 |
| 檔尾 | 1 個換行 |

- **要**：空行只用來分隔「不同的東西」（不同成員、不同邏輯段落），同一段邏輯內的連續敘述不空行。
- **避免**：連續兩個以上空行；用空行對齊或美化，例如在 `switch` 的 `case` 之間空行。
- **避免**：`case` 很多時為了縮短而連續排列，規則一致比省行數重要。

```swift
/// 伺服器提供的各個資料端點。
enum Endpoint: String, CaseIterable, Codable, Sendable {

    /// 使用者個人資料。
    case profile

    /// 使用者的訂單清單。
    case orders

    /// App 設定。
    case settings
}

// MARK: - Computed Properties

extension Endpoint {

    /// 端點在伺服器上的路徑，接在網域之後。
    var path: String {
        switch self {
        case .profile:
            "/v1/profile"
        case .orders:
            "/v1/orders"
        case .settings:
            "/v1/settings"
        }
    }

    /// 呼叫這個端點是否需要先登入。
    var requiresAuth: Bool {
        self != .settings
    }
}
```

## MARK 分區與順序

型別本體只放 stored properties 與 Init，其餘一律以同檔 extension 分區，每區以 `// MARK: - <區名>` 開頭，順序固定：

1. Properties（型別本體內，只放 stored properties；SwiftUI View 的 `body` 另立 `Body` 區，緊接在 Init 之後）
2. Init（型別本體內）
3. Nested Types（extension；只放此型別專屬的 enum / struct / class，判斷標準見 `file-templates.md`）
4. Computed Properties（extension；所有 computed properties 不論存取層級都放這裡，不放型別本體）
5. Internal Method（extension）
6. Private Method（`private extension`）

用不到的區塊直接省略，不留空的 MARK；順序不可調換。Protocol 遵循各自獨立一個 extension，以 protocol 名稱作為 MARK 名稱（例如 `// MARK: - __NAME__ServiceProtocol`、`// MARK: - Codable`），**排在 Internal Method 之後、Private Method 之前**；多個 protocol 遵循依 protocol 名稱字母排序。閱讀順序因此固定為：型別是什麼 → 自己提供什麼 → 履行什麼契約 → 內部怎麼做。

型別專屬的額外分區（View 的 `Body`、`Private Views`、`Preview`，Coordinator 與流程型 Coordinator 的 `Destinations`，FormatStyle 的 `Convenience`，TCA Feature 型別的 `State`、`Action`、`Dependencies`、`Body`）以各樣板為準，位置見 `file-templates.md` 與 `tca-architecture.md` 對應一節；不自創其他分區名稱。

### 遵循宣告在型別行還是 extension

- **自動合成的 protocol**（`Codable`、`Equatable`、`Hashable`、`Sendable`、`Identifiable`、`CaseIterable`）寫在型別宣告行，沒有實作可放。
- **需要手寫實作的 protocol** 在 extension 宣告遵循並放**全部**實作，包含 protocol 要求的 `init`（例如 `init(from:)`），不放本體的 Init 區。`Codable` 有手寫 `init(from:)` / `encode(to:)` 時視為手寫 protocol，整組放 `// MARK: - Codable` extension。
- **例外一**：SwiftUI `View` 的 `body` 留在本體的 Body 區，遵循宣告在型別行。
- **例外二**：class 的 `required init` 語言規定必須在本體，此時遵循宣告在型別行，該 init 留本體 Init 區，其餘實作仍放 extension。
- **例外三**：Nested Types 內的小型別（`Route`、`Sheet`、`CodingKeys`）遵循宣告在型別行並就地實作，不再拆 extension。
- **例外四**：`@unchecked Sendable` 必須與型別宣告同行，不可放 extension。

### Extension 的使用時機

- **要**：extension 只用於三件事：依上述順序分區、遵循 protocol、為非自己的型別加功能。
- **要**：為非自己的型別（`Date`、`String`、`View`、系統或第三方型別）加功能時，放 `Core/Extensions/`，預設一個型別一檔 `<Type>+Extensions.swift`，檔內依功能以 `// MARK: - <功能>` 分區。該檔超過 300 行，或其中某個功能明顯自成一組（例如 `Date` 的相對時間計算）時，拆成 `<Type>+<Feature>.swift`，一個關注點一檔；拆分後不再保留 `<Type>+Extensions.swift`，全部改為功能命名，同一型別不混用兩種檔名。唯一例外是 `EnvironmentValues+Services.swift`，它是 `@Entry` 清單而非一般擴充。
- **避免**：同一區塊拆成兩個 extension，例如兩個 `// MARK: - Internal Method`。
- **避免**：跨檔 extension 自己的型別，除非依 `file-templates.md` 的分檔規則（單檔超過 300 行時以 `<Name>+<Domain>.swift` 分檔）。
- **避免**：用 extension 對非自己的型別加 protocol 遵循（retroactive conformance），會與其他模組的遵循衝突；需要時改用 wrapper 型別。

## Import 排序

- **要**：依模組名稱字母排序，不分大小寫，不分系統或第三方，一行一個。
- **要**：`@testable import` 放在所有一般 import 之後，中間空一行；多個 `@testable import` 之間同樣字母排序。
- **要**：不重複 import 已被其他模組帶入的模組：`import SwiftUI` 已涵蓋 `Foundation` 與 `Observation`，寫了 `SwiftUI` 就不再寫那兩個；`import XCTest` 已涵蓋 `Foundation`。唯一例外是編譯器明確要求顯式 import 時（例如 Swift 6 對 `@Observable` 巨集在某些 target 的要求），依錯誤訊息補上。
- **要**：不使用的 import 移除，包含 Xcode 樣板預設加的。
- **避免**：import 子模組或單一符號（`import struct Foundation.Date`、`import UIKit.UIColor`），一律整個模組。
- **避免**：ViewModel、Model、Service、UseCase 這些非 UI 層 `import SwiftUI` 或 `UIKit`；需要 `@Observable` 時明確 `import Observation`。
- **避免**：`#if canImport(...)` 條件 import，除非確實要跨平台編譯。

```swift
// App target 的 View
import SwiftUI

// ViewModel：非 UI 層，不 import SwiftUI
import Foundation
import Observation

// 測試 target
import Foundation
import Testing

@testable import MyApp
```

## Closure 與 Trailing Closure

- **要**：最後一個參數是 closure 時一律用 trailing closure：`.task { }`、`map { }`、`Button("Save") { }`。
- **要**：連續多個 closure 參數時一律用多重 trailing closure 語法，第一個 closure 省略標籤，其餘以 `} label: {` 形式接在後面；不寫成 `Button(action: { }, label: { })`。
- **要**：`$0` 只用於單一表達式且只有一個參數的 closure；closure 超過一行，或有兩個以上參數，一律具名。
- **要**：只有在 closure 會被物件長期持有（儲存在屬性、傳給第三方 SDK 的 callback、`NotificationCenter` observer）時才加 `[weak self]`；`Task { }`、SwiftUI modifier、`map` / `filter` 這類即時執行的 closure 不加。
- **要**：寫了 `[weak self]` 就在 closure 第一行 `guard let self else { return }`，之後直接用 `self`；不用 `self?.` 逐行解包。
- **要**：多行 closure 的 `{` 與呼叫同行，`}` 單獨一行對齊呼叫起始，本體縮排 4 格；單行 closure 前後各留一個空格：`{ $0.id }`。
- **避免**：明確標註 closure 的參數型別與回傳型別，只在編譯器推斷失敗時加。
- **避免**：closure 內用 `return` 回傳單一表達式，單一表達式省略 `return`。
- **避免**：`unowned`，一律 `weak` 加 `guard let self`。

```swift
// 單一 trailing closure
let activeIDs = users
    .filter { $0.isActive }
    .map { $0.id }

// 多重 trailing closure
Button {
    viewModel.save()
} label: {
    Label("Save", systemImage: "square.and.arrow.down")
}

// 兩個以上參數必須具名
let merged = zip(names, scores).map { name, score in
    "\(name): \(score)"
}

// [weak self] 搭配 guard let self
client.onMessage = { [weak self] message in
    guard let self else { return }
    handle(message)
    updateBadge()
}
```

## SwiftUI View Body 排版

- **要**：modifier 一行一個，前置 `.` 縮排一層；即使只有一個 modifier 也換行，不與 View 同行。
- **要**：modifier 依下表四組順序排列，未列出的 modifier 依其效果歸入對應組；同組內依需求排列，因為 `padding` 與 `background` 的先後會改變結果，不強制字母排序。
- **要**：子 View 抽取依 `file-templates.md` 的「`body` 只放大框架」規則，不設行數門檻。
- **要**：Private Views 以內容命名，不加 `View` 後綴：`header`、`statsSection`、`emptyState`；接受參數的用 `func`，名稱同樣不加後綴：`row(for item: Item)`。
- **要**：容器的 `{` 與宣告同行（`VStack(spacing: 16) {`），同一容器內的子 View 之間空一行；`if` / `else` 分支內只有一個子 View 時不空行。
- **要**：條件式 View 直接在 builder 內寫 `if` / `if let` / `switch`。
- **要**：`#Preview` 放檔案最末的 Preview 區，多個 Preview 各自以字串具名。
- **避免**：用三元運算子或 `.map` 產生 View（`condition ? viewA : viewB`、`item.map { Text($0) }`），可讀性差且型別推斷慢。
- **避免**：`AnyView`，用 `@ViewBuilder` 或 `Group` 處理型別不一致。
- **避免**：在 `body` 內宣告區域變數或呼叫有副作用的方法，計算移到 Private Method 或 ViewModel。

| 組別 | 順序 | 例子 |
|---|---|---|
| 1. 版面 | 最先 | `padding`、`frame`、`offset`、`fixedSize`、`layoutPriority`、`safeAreaInset` |
| 2. 外觀 | 第二 | `background`、`foregroundStyle`、`font`、`clipShape`、`overlay`、`shadow`、`opacity`、`tint` |
| 3. 行為 | 第三 | `onTapGesture`、`onChange`、`onAppear`、`task`、`refreshable`、`disabled`、`accessibilityLabel` |
| 4. 導航與呈現 | 最後 | `navigationTitle`、`navigationDestination`、`toolbar`、`sheet`、`fullScreenCover`、`alert`、`confirmationDialog` |

```swift
/// 個人資料畫面的骨架：標題區、統計區，再依有無近期活動顯示列表或空狀態。
var body: some View {
    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                header

                statsSection

                if viewModel.hasRecentActivity {
                    recentActivityList
                } else {
                    emptyState
                }
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await viewModel.reload()
        }
        .navigationTitle("Profile")
        .toolbar {
            settingsButton
        }
        .sheet(item: $viewModel.presentedSheet) { sheet in
            sheetContent(for: sheet)
        }
    }
    .task {
        await viewModel.load()
    }
}
```

## 常見錯誤檢查清單

- [ ] 行寬超過 100，或用縮短命名、刪標籤的方式壓行
- [ ] 尾隨空白、只含縮排的空行、檔尾缺換行或多於一個換行
- [ ] 運算子放行尾而非續行行首
- [ ] `switch` 的 `case` 本體與 `case` 寫在同一行
- [ ] `if` / `guard` 多條件的續行沒有對齊第一個條件
- [ ] 參數部分換行，或換行後右括號沒有單獨一行
- [ ] 型別或 extension 開括號後沒空行、閉括號前有空行、`case` 之間沒空行
- [ ] MARK 順序錯置，或同一區塊拆成兩個 extension
- [ ] 手寫實作的 protocol 遵循寫在型別行而非 extension；自動合成的反而拆了 extension
- [ ] protocol 遵循的 extension 排在 Internal Method 之前或 Private Method 之後
- [ ] import 未依字母排序、重複 import `SwiftUI` 已涵蓋的模組、非 UI 層 import `SwiftUI`
- [ ] `@testable import` 前沒有空行
- [ ] 多個 closure 參數沒用多重 trailing closure；多行或多參數 closure 用 `$0`
- [ ] `[weak self]` 後沒有 `guard let self`，或出現 `self?.`、`unowned`
- [ ] modifier 與 View 同行、順序違反四組排列
- [ ] `body` 內出現三元運算子產生 View、`AnyView`、區域變數或副作用呼叫
- [ ] Private Views 名稱帶 `View` 後綴
