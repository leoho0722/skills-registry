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
- **要**：`guard` 的 `else` 本體一律另起一行，即使只有 `return` 或 `throw`。唯一例外是 `[weak self]` 之後的 `guard let self else { return }`，維持一行（見「Closure 與 Trailing Closure」）。
- **要**：超長字串不斷行，允許超過 100；需要多行時用 `"""` 多行字串字面值。
- **避免**：用 `+` 串接字串來壓行，會讓搜尋字串失效。
- **避免**：`if` / `guard` 的條件續行用固定 4 格，會與本體同層而失去視覺分界。
- **避免**：在以下三處斷行，超過 100 也維持一行：`import`、`case` 宣告、closure 簽章（依「Closure 與 Trailing Closure」的處理順序做完仍超過時）。函式簽章不在此列，只有一個參數也依「參數與引數對齊」斷行。
- **要**：`switch` 的每個 `case` 本體一律另起一行縮排 4 格，即使只有一個表達式；不寫成 `case .x: value` 單行，`default` 同樣適用。`case` 之間的空行見「空行規則」。

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

適用於函式與方法的宣告、`init` 宣告，以及所有呼叫端（含 `#expect` 這類 macro），四者同一套規則。斷不斷行完全由下列條件決定，非此即彼，不是可以自由選擇的風格。

- **要**：符合以下任一條件就斷行，每個參數或引數獨立一行，續行縮排 4 格：整行超過 100 字元（即使參數不超過三個）；參數或引數超過三個（即使整行不超過 100）。
- **要**：兩個條件都不符合時，所有參數或引數必須寫在同一行，不可斷行。
- **要**：整行長度的算法：從宣告或呼叫所在那一行的行首開始（含縮排與 `let descriptor =` 這類前綴），接到右括號成為一行，連同右括號後同一行的內容（回傳型別、`async`、`throws`、`{`，有 trailing closure 時連同它的簽章，例如 `{ oldValue, newValue in`），以字元計；trailing closure 的本體不算在內。
- **要**：斷行時右括號單獨一行，對齊宣告或呼叫的起始欄位；回傳型別、`async throws`、`{` 接在右括號後同一行。有 trailing closure 時，closure 的 `{` 與簽章同樣接在右括號後：`) { item in`。
- **要**：只有一個參數或引數時同樣適用：整行超過 100 就依本節規則斷行，未超過就寫在同一行，宣告端與呼叫端都一樣；參數型別含 closure、typed throws 或泛型時特別容易超過。斷行後右括號那一行（回傳型別、`throws`、`{`）仍超過 100 時，維持同一行，允許超過。
- **要**：巢狀呼叫由外而內判斷。外層符合條件而斷行後，內層呼叫以自己所在的那一行（含縮排）重新套用本節；外層不符合條件時，內層也維持在同一行。但內層的參數或引數超過三個時，外層視同符合條件而斷行，因為內層斷行後右括號必須單獨一行對齊起始欄位，外層不斷行就做不到。
- **要**：括號內的引數是多行本體的 closure，或是帶多行 trailing closure 的呼叫（例如 TCA 的 `store: Store(initialState: ...) { ... }`）時，不依上面的條件判斷，一律每個引數獨立一行；closure 本身的排版依「Closure 與 Trailing Closure」處理。
- **避免**：未達斷行條件卻把參數或引數拆成多行，包含單一引數的 `#expect(`、`FetchDescriptor(` 這類呼叫。
- **避免**：部分換行（前兩個參數同行、第三個換行），diff 中會讓無關的參數跟著移動。
- **避免**：右括號緊接最後一個參數，回傳型別會藏在參數尾巴，且參數區塊與本體失去分界。
- **避免**：為了塞進一行而縮短參數標籤或省略預設值。

```swift
// 宣告：超過三個參數，每個一行，右括號單獨一行
/// 取得使用者的個人資料
///
/// - Parameters:
///   - id: 使用者識別碼
///   - includeDetails: 是否連同詳細欄位一起取得
///   - cachePolicy: 要不要用先前抓過的資料
///   - timeout: 最多等多久
/// - Returns: 該使用者的個人資料
/// - Throws: 找不到使用者、逾時或網路失敗時丟出
func fetchProfile(
    id: String,
    includeDetails: Bool = false,
    cachePolicy: CachePolicy = .default,
    timeout: Duration = .seconds(30)
) async throws -> Profile {
    ...
}

// 宣告：兩個參數且未超過 100，寫在同一行，不可斷行
/// 取得使用者的個人資料
///
/// - Parameters:
///   - id: 使用者識別碼
///   - includeDetails: 是否連同詳細欄位一起取得
/// - Returns: 該使用者的個人資料
/// - Throws: 找不到使用者或網路失敗時丟出
func fetchProfile(id: String, includeDetails: Bool = false) async throws -> Profile

// 宣告：只有一個參數但超過 100，同樣斷行
/// 執行一段存取本機資料的操作，並把錯誤包成這個領域的錯誤
///
/// - Parameter operation: 要執行的存取操作
/// - Returns: 操作的結果
/// - Throws: `operation` 失敗時丟出，已包成 `.storage(_:)`
static func wrapStorage<Value>(
    _ operation: () throws(PersistenceError) -> Value
) throws(ProfileStorageError) -> Value {
    ...
}

// 呼叫：與宣告同一套規則
let profile = try await service.fetchProfile(
    id: user.id,
    includeDetails: true,
    cachePolicy: .reloadIgnoringCache,
    timeout: .seconds(10)
)

// 呼叫：單一引數且未超過 100，寫在同一行，不可斷行
let descriptor = FetchDescriptor<ProfileRecord>(predicate: #Predicate { $0.id == id })
#expect(profile.nickname == "Leo")

// 巢狀：外層超過 100 而斷行，內層在自己那一行重新判斷，未超過 100 就維持一行
let request = URLRequest(
    url: endpoint.url(relativeTo: configuration.baseURL),
    cachePolicy: .reloadIgnoringLocalCacheData
)

// init：同上
/// 建立結帳畫面的 ViewModel，四個來源缺一不可
///
/// - Parameters:
///   - profileService: 取得個人資料的物件
///   - orderService: 取得與建立訂單的物件
///   - paymentService: 執行付款的物件
///   - analytics: 回報使用行為的物件
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
| enum 的 `case` 宣告之間 | 1，不論數量多寡與有無 associated value |
| `switch` 的 `case` 之間（含 `default`） | 1，不論數量多寡與 case 本體幾行，View builder 內的 `switch` 同樣適用 |
| `switch {` 之後、第一個 `case` 之前；最後一個 case 本體與 `}` 之間 | 0 |
| 方法之間 | 1 |
| 頂層宣告之間（型別與 extension、extension 與 extension） | 1 |
| 函式內邏輯區塊之間 | 最多 1，不連續兩個空行 |
| 函式本體的第一行之前與最後一行之後 | 0，本體不以空行開頭或結尾 |
| 測試本體的 `// When`、`// Then` 之前 | 1；`// Given` 寫在本體第一行，前面不空行 |
| 檔尾 | 1 個換行 |

- **要**：空行只用來分隔「不同的東西」（不同成員、不同邏輯段落），同一段邏輯內的連續敘述不空行。
- **避免**：連續兩個以上空行；用空行對齊或美化。
- **避免**：enum 的 `case` 宣告或 `switch` 的 `case` 很多、或每個 case 本體都很短時，為了縮短而連續排列；規則一致比省行數重要。

enum 的 `case` 宣告與 `switch` 的 `case` 都空一行，`switch {` 之後與 `}` 之前不空行：

```swift
/// 伺服器提供的各個資料端點
enum Endpoint: String, CaseIterable, Codable, Sendable {

    /// 使用者個人資料
    case profile

    /// 使用者的訂單清單
    case orders

    /// App 設定
    case settings
}

// MARK: - Computed Properties

extension Endpoint {

    /// 端點在伺服器上的路徑，接在網域之後
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

    /// 呼叫這個端點是否需要先登入
    var requiresAuth: Bool {
        self != .settings
    }
}
```

case 本體有多行、含 `default` 時同樣空一行：

```swift
/// 依 HTTP 狀態碼決定這次請求的結果
///
/// - Parameter statusCode: 伺服器回傳的狀態碼
/// - Returns: 請求的結果
func result(for statusCode: Int) -> RequestResult {
    switch statusCode {
    case 200..<300:
        return .success

    case 401:
        session.invalidate()
        return .unauthorized

    default:
        return .failure(statusCode)
    }
}
```

## MARK 分區與順序

本節的分區適用於頂層型別（檔案內直接宣告的型別）；巢狀型別不分區，見下方「巢狀型別」。型別本體只放 stored properties 與 Init，其餘一律以同檔 extension 分區，每區以 `// MARK: - <區名>` 開頭，順序固定：

1. Properties（型別本體內，放全部 stored properties，含 `static let`；SwiftUI View 的 `body` 另立 `Body` 區，緊接在 Init 之後）
2. Init（型別本體內）
3. Nested Types（extension；只放此型別專屬的 enum / struct / class，判斷標準見 `file-templates.md`）
4. Computed Properties（extension；非 private 的 computed properties，不放型別本體）
5. Internal Method（extension）
6. Private Method（`private extension`；private 的 computed properties 與 private 方法都放這裡，區名不改）

computed properties 與方法依存取層級分區：非 private 的放 Computed Properties 與 Internal Method，private 的不論是 property 還是方法都放 Private Method。extension 的存取層級因此等於成員的存取層級，不在 extension 內逐一加 `private`；計算從 `var` 改成帶參數的 `func` 時也不用換區。

用不到的區塊直接省略，不留空的 MARK；順序不可調換。Protocol 遵循各自獨立一個 extension，以 protocol 名稱作為 MARK 名稱（例如 `// MARK: - __NAME__ServiceProtocol`、`// MARK: - Codable`），**排在 Internal Method 之後、Private Method 之前**；多個 protocol 遵循依 protocol 名稱字母排序。閱讀順序因此固定為：型別是什麼 → 自己提供什麼 → 履行什麼契約 → 內部怎麼做。

型別專屬的額外分區（View 的 `Body`、`Private Views`、`Preview`，Coordinator 與流程型 Coordinator 的 `Destinations`，FormatStyle 的 `Convenience`，TCA Feature 型別的 `State`、`Action`、`Dependencies`、`Body`）以各樣板為準，位置見 `file-templates.md` 與 `tca-architecture.md` 對應一節；不自創其他分區名稱。

### 區內排序

- **要**：每一區內 static 成員在前、instance 成員在後；`class var` / `class func` 視同 static。Properties 區的 `static let` 因此排在所有 instance stored property 之前，View 的 Properties 順序見 `file-templates.md`。
- **要**：Private Method 區內先分 property 與方法，再分 static 與 instance：static property → instance property → static method → instance method。
- **要**：computed property 之間依依賴順序排列，被依賴的在前、由它推導出來的在後；彼此沒有依賴時依相關性排，不強制字母排序。
- **要**：Private Method 區的方法採呼叫者在前、深度優先：每個 helper 依第一次被呼叫的順序排，緊接在呼叫它的方法之後，它自己呼叫的下一層 helper 再緊接其後；被多個方法呼叫時，歸在最先呼叫它的方法之下。這個順序只在 static、instance 各自一組內適用，不推翻 static 在前。
- **要**：Internal Method 區依呼叫端使用的先後排：載入 → 使用者操作（依畫面上由上到下）→ 離開或清理；Internal Method 之間互相呼叫時，同樣呼叫者在前。
- **要**：protocol 遵循 extension 內的實作順序與 protocol 的宣告順序一致，protocol 本身依 Internal Method 的使用先後宣告；同一個 protocol 的正式實作、Preview stub、Mock 都照這個順序。系統 protocol 依 Apple 的宣告順序，例如 `Codable` 為 `init(from:)` → `encode(to:)`。
- **要**：stored property 不依存取層級排序，`private let` 與 `let` 可以混排；View 以外的型別除了 static 在前，不另外規定順序。
- **例外**：TCA Feature 型別的 `core(state:action:)` 永遠是 Private Method 區的第一個方法，排在 static method 之前，見 `tca-architecture.md`。
- **避免**：把 static stored property 放進 extension。Swift 允許在 extension 宣告 static stored property，本規範仍一律放本體的 Properties 區，讓型別持有的狀態集中在一處。

```swift
// MARK: - Private Method

private extension ProfileCache {

    /// 所有使用者的快取檔案所在的資料夾
    static var directory: URL {
        URL.cachesDirectory.appending(path: "Profile")
    }

    /// 這位使用者的快取檔案位置，建在 `directory` 之下
    var fileURL: URL {
        Self.directory.appending(path: "\(userID).json")
    }

    /// 組出取得個人資料的請求
    ///
    /// - Parameter id: 使用者識別碼
    /// - Returns: 可直接送出的請求
    static func makeRequest(for id: String) -> URLRequest {
        ...
    }

    /// 把快取檔案的內容轉成個人資料
    ///
    /// - Parameter data: 快取檔案的原始內容
    /// - Returns: 解析後的個人資料
    /// - Throws: 內容格式不符時丟出
    func decode(_ data: Data) throws(ProfileError) -> Profile {
        ...
    }
}
```

computed property 由下往上排（被依賴的在前），方法由上往下排（呼叫者在前），方向相反是刻意的：property 是一層層推導出來的值，先看到來源再看到結果比較好懂；方法是一段段流程，先看到高層的步驟、往下才看到細節，遇到不認識的 helper 往下找一定找得到。

`fetchAndApply()` 最先被 `load()` 呼叫，排第一，它呼叫的 `apply(_:)` 緊接在後；`resetPagination()` 到 `refresh()` 才第一次被呼叫，排最後：

```swift
// MARK: - Internal Method

extension ProfileViewModel {

    /// 畫面出現時載入個人資料
    func load() async {
        await fetchAndApply()
    }

    /// 下拉重新整理：分頁位置回到第一頁後重新載入
    func refresh() async {
        resetPagination()
        await fetchAndApply()
    }
}

// MARK: - Private Method

private extension ProfileViewModel {

    /// 向 Service 取得個人資料並更新畫面狀態
    func fetchAndApply() async {
        do {
            let profile = try await profileService.fetchProfile(id: userID)
            apply(profile)
        } catch {
            ...
        }
    }

    /// 把取得的個人資料套用到畫面狀態
    ///
    /// - Parameter profile: 取得的個人資料
    func apply(_ profile: Profile) {
        ...
    }

    /// 把分頁位置重設回第一頁
    func resetPagination() {
        ...
    }
}
```

### 遵循宣告在型別行還是 extension

- **自動合成的 protocol**（`Codable`、`Equatable`、`Hashable`、`Sendable`、`Identifiable`、`CaseIterable`）寫在型別宣告行，沒有實作可放。
- **需要手寫實作的 protocol** 在 extension 宣告遵循並放**全部**實作，包含 protocol 要求的 `init`（例如 `init(from:)`），不放本體的 Init 區。`Codable` 有手寫 `init(from:)` / `encode(to:)` 時視為手寫 protocol，整組放 `// MARK: - Codable` extension。
- **例外一**：SwiftUI `View` 的 `body` 留在本體的 Body 區，遵循宣告在型別行。
- **例外二**：class 的 `required init` 語言規定必須在本體，此時遵循宣告在型別行，該 init 留本體 Init 區，其餘實作仍放 extension。
- **例外三**：巢狀型別（`Route`、`Sheet`、`CodingKeys`、TCA 的 `State`）遵循宣告在型別行並就地實作，不再拆 extension，見下方「巢狀型別」。
- **例外四**：`@unchecked Sendable` 必須與型別宣告同行，不可放 extension。

### Extension 的使用時機

- **要**：extension 只用於三件事：依上述順序分區、遵循 protocol、為非自己的型別加功能。
- **要**：為非自己的型別（`Date`、`String`、`View`、系統或第三方型別）加功能時，放 `Core/Extensions/`，預設一個型別一檔 `<Type>+Extensions.swift`，檔內依功能以 `// MARK: - <功能>` 分區。該檔超過 300 行，或其中某個功能明顯自成一組（例如 `Date` 的相對時間計算）時，拆成 `<Type>+<Feature>.swift`，一個關注點一檔；拆分後不再保留 `<Type>+Extensions.swift`，全部改為功能命名，同一型別不混用兩種檔名。唯一例外是 `EnvironmentValues+Services.swift`，它是 `@Entry` 清單而非一般擴充。
- **避免**：同一區塊拆成兩個 extension，例如兩個 `// MARK: - Internal Method`。
- **避免**：跨檔 extension 自己的型別，除非依 `file-templates.md` 的分檔規則（單檔超過 300 行時以 `<Name>+<Domain>.swift` 分檔）。
- **避免**：用 extension 對非自己的型別加 protocol 遵循（retroactive conformance），會與其他模組的遵循衝突；需要時改用 wrapper 型別。

### 巢狀型別

六區分區只適用於頂層型別。巢狀型別（Nested Types 內宣告的型別、TCA Feature 型別本體內的 `State` / `Action`）的所有成員一律就地寫在自己的本體，包含 computed property、方法與 protocol 實作，不另開 extension、不加 MARK。

- **要**：本體內的順序比照頂層分區：case / stored property → init → nested type → 非 private computed property → 非 private 方法 → private computed property → private 方法；每一組內 static 在前，computed property 依依賴順序，方法依呼叫者在前。
- **要**：protocol 要求的成員（`var id`、`encode(to:)`）視為一般成員，依種類與存取層級排入上述順序，不另成一組。
- **要**：巢狀型別大到需要分區才讀得懂時，代表它該成為獨立檔案，依 `file-templates.md` 的 Nested Types 判斷標準移到 `domain/`；TCA 的 `State` 受巨集限制不能移出，以單檔 300 行上限控制。
- **避免**：`extension Outer.Nested` 為巢狀型別另開分區。

```swift
// MARK: - Nested Types

extension ProfileViewModel {

    /// 畫面目前的載入狀態
    enum State: Equatable {

        /// 尚未開始載入
        case idle

        /// 正在向伺服器取得資料
        case loading

        /// 載入完成
        ///
        /// - Parameter profile: 取得的個人資料
        case loaded(Profile)

        /// 是否正在載入，畫面用來決定要不要顯示進度指示
        var isLoading: Bool {
            self == .loading
        }
    }
}
```

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
- **要**：`$0` 只用於單一表達式且只有一個參數的 closure；closure 超過一行，或有兩個以上參數，一律具名。唯一例外是 TCA 測試的 `send`、`receive`、`withDependencies`，見 `tca-architecture.md` 的「測試」。
- **要**：只有在 closure 會被物件長期持有（儲存在屬性、傳給第三方 SDK 的 callback、`NotificationCenter` observer）時才加 `[weak self]`；`Task { }`、SwiftUI modifier、`map` / `filter` 這類即時執行的 closure 不加。
- **要**：寫了 `[weak self]` 就在 closure 第一行 `guard let self else { return }`，之後直接用 `self`；不用 `self?.` 逐行解包。
- **要**：多行 closure 的 `{` 與呼叫同行，`}` 單獨一行對齊呼叫起始，本體縮排 4 格；單行 closure 前後各留一個空格：`{ $0.id }`。
- **要**：capture list、參數與 `in` 一律和 `{` 寫在同一行。整行超過 100 時依序處理：
  1. 鏈式呼叫在 `.` 之前斷行，讓帶 closure 的那一段自成一行。
  2. 呼叫的引數每個一行、右括號單獨一行，`) { item in` 接在右括號後；呼叫端只有一個引數也照做。
  3. 前兩步做完仍超過（例如賦值左側很長），維持同一行，允許超過 100。
- **要**：closure 要指定給 typed throws 的函式型別、且本體會 throw 時，簽章只補 `throws(E)`：`{ name throws(ValidationError) in`，沒有參數時寫 `{ () throws(ValidationError) in`（省略 `()` 無法編譯）；參數型別、`async`、回傳型別仍省略。Swift 6 的 closure 不會從指定目標推斷錯誤型別，一律推斷為 `throws(any Error)`，賦值給屬性、當作 init 引數、本體只呼叫 typed throws 方法都一樣，所以 `throws(E)` 不可省略；本體不會 throw 時什麼都不用標。
- **避免**：明確標註 closure 的參數型別與回傳型別，只在編譯器推斷失敗時加。
- **避免**：把 closure 簽章移到 `{` 的下一行，或在 `=` 之後斷行把 `{` 移到續行。
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

// 超過 100，步驟 1：鏈式呼叫在 . 之前斷行
let rows = viewModel.recentOrders
    .filter { $0.isVisible }
    .prefix(maxVisibleCount)
    .map { order in
        OrderRow(order: order)
    }

// 超過 100，步驟 2：單一引數也斷行，簽章接在右括號後（整行長度含簽章）
.onChange(
    of: viewModel.selectedAccount?.preferences.notificationSettings
) { oldSettings, newSettings in
    viewModel.syncNotificationSettings(from: oldSettings, to: newSettings)
}

// typed throws：只補 throws(E)，參數型別與回傳型別由指定目標推斷
validator.rule = { input throws(ValidationError) in
    guard !input.isEmpty else {
        throw .empty
    }
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
/// 個人資料畫面的骨架：標題區、統計區，再依有無近期活動顯示列表或空狀態
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
- [ ] `guard` 的 `else` 本體與 `else {` 寫在同一行（`guard let self else { return }` 除外）
- [ ] 參數部分換行，或換行後右括號沒有單獨一行；只有一個參數的宣告或呼叫超過 100 卻沒有斷行
- [ ] 未達斷行條件（整行不超過 100 且不超過三個）卻把參數或引數拆成多行，包含單一引數的 `#expect(`、`FetchDescriptor(`
- [ ] 型別或 extension 開括號後沒空行、閉括號前有空行
- [ ] enum 的 `case` 宣告之間、`switch` 的 `case` 之間沒空行；`switch {` 之後或 `}` 之前多了空行
- [ ] 測試的 `// When`、`// Then` 前面沒空行，或 `// Given` 前面多了空行
- [ ] MARK 順序錯置，或同一區塊拆成兩個 extension
- [ ] private 的 computed property 放在 Computed Properties，或非 private 的放在 Private Method
- [ ] 區內 static 沒排在 instance 之前；Private Method 區內 method 排在 property 之前；static stored property 放在 extension
- [ ] Private Method 的 helper 沒有依呼叫者在前、深度優先；Internal Method 沒有依使用先後；protocol 實作與 Preview stub、Mock 的順序和 protocol 宣告不一致
- [ ] 巢狀型別另開 extension 或加 MARK 分區
- [ ] 手寫實作的 protocol 遵循寫在型別行而非 extension；自動合成的反而拆了 extension
- [ ] protocol 遵循的 extension 排在 Internal Method 之前或 Private Method 之後
- [ ] import 未依字母排序、重複 import `SwiftUI` 已涵蓋的模組、非 UI 層 import `SwiftUI`
- [ ] `@testable import` 前沒有空行
- [ ] 多個 closure 參數沒用多重 trailing closure；多行或多參數 closure 用 `$0`（TCA 測試的 `send`、`receive`、`withDependencies` 除外）
- [ ] closure 簽章移到 `{` 下一行、在 `=` 後斷行；closure 多標了推斷得出的參數型別、`async` 或回傳型別
- [ ] `[weak self]` 後沒有 `guard let self`，或出現 `self?.`、`unowned`
- [ ] modifier 與 View 同行、順序違反四組排列
- [ ] `body` 內出現三元運算子產生 View、`AnyView`、區域變數或副作用呼叫
- [ ] Private Views 名稱帶 `View` 後綴
