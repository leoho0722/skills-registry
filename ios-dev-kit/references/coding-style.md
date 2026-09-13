# Coding Style（命名與語意慣例）

Leo Ho 個人 Swift 開發規範。參考 [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) 並加上個人偏好；與官方相左之處以本檔為準。

## 目錄

- [Coding Style（命名與語意慣例）](#coding-style命名與語意慣例)
  - [目錄](#目錄)
  - [命名](#命名)
    - [型別與 protocol](#型別與-protocol)
    - [變數、屬性與常數](#變數屬性與常數)
    - [函式與方法](#函式與方法)
    - [enum case](#enum-case)
  - [存取控制](#存取控制)
  - [型別選擇](#型別選擇)
  - [Optional 處理](#optional-處理)
    - [強制解包 `!` 的唯一例外](#強制解包--的唯一例外)
  - [Error Handling](#error-handling)
    - [定義錯誤](#定義錯誤)
    - [丟出與傳遞](#丟出與傳遞)
    - [接住與處理](#接住與處理)
  - [Concurrency](#concurrency)
    - [模型](#模型)
    - [Actor 與隔離](#actor-與隔離)
    - [Task 的建立與取消](#task-的建立與取消)
  - [註解與 Doc Comment](#註解與-doc-comment)
  - [常見錯誤檢查清單](#常見錯誤檢查清單)

## 命名

依 Swift API Design Guidelines，以下為補充與個人選擇。

### 型別與 protocol

- **要**：型別 UpperCamelCase；後綴只用已定義的角色名：`View`、`ViewModel`、`Coordinator`、`Service`、`Client`、`Store`、`Database`、`UseCase`、`FormatStyle`、`Tests`、`UITests`。
- **要**：描述能力的 protocol 用 `-able` / `-ible` / `-ing`（`Sendable`、`ProfileFetching`）；描述角色的 protocol 用名詞加 `Protocol` 後綴（`ProfileServiceProtocol`）。
- **要**：泛型參數一律具名，表達它的角色：`Element`、`Output`、`Value`、`Key`；單字母 `T` 只允許在完全沒有語意的工具函式（例如 `identity<T>(_:)`）。
- **要**：`Manager`、`Handler`、`Provider` 只在型別的職責**確實符合該字的本意**時使用，判斷標準如下表；符合就用，不符合就改用能說明職責的字。`Helper` 與 `Util` 沒有對應的職責，不使用。
- **避免**：型別名前綴（`LHProfile`），Swift 有 module 命名空間。

| 後綴 | 本意 | 符合時的特徵 | 不符合時該叫什麼 |
|---|---|---|---|
| `Manager` | 管理一組資源的生命週期 | 建立、追蹤、回收多個存活期長於單次呼叫的同類物件，例如連線池、下載任務集合 | 只做一組操作 → `Service`；包裝系統物件 → `Client` |
| `Handler` | 被動回應一個事件 | closure 參數名（`completionHandler`），或責任鏈、middleware 中的一環，接在其他 Handler 前後處理同一個輸入 | 主動提供功能 → `Service`；只是一個方法 → 動詞命名的函式 |
| `Provider` | 按需提供一個值，本身無業務邏輯 | 介面只有一兩個回傳值的方法、無狀態、為了可替換與可測試而存在，例如 `DateProvider.now()`、`LocaleProvider` | 有業務邏輯 → `Service`；有狀態 → `Store` |
| `Helper` / `Util` | 無 | 無 | 依內容命名：測試用的叫 `Fixtures`、`Builders`；共用函式收進以主題命名的無 case `enum` 或對應型別的 extension |

### 變數、屬性與常數

- **要**：lowerCamelCase；依角色而非型別命名，集合用複數：`users` 而非 `userArray`、`name` 而非 `nameString`。
- **要**：`Bool` 用 `is` / `has` / `can` / `should` 開頭的肯定斷言：`isLoading`、`hasUnreadMessages`、`canSubmit`、`shouldRetry`。
- **要**：常數與變數同為 lowerCamelCase；同一主題的全域常數收進無 case 的 `enum` 作為命名空間：`enum Layout { static let spacing: CGFloat = 16 }`。
- **要**：縮寫依位置轉換大小寫：在開頭全小寫（`urlString`、`htmlBody`、`id`），在中間或結尾全大寫（`baseURL`、`userID`、`parseJSON`）。`ID` 固定大寫，`Identifiable.id` 單獨出現時是小寫 `id`。
- **避免**：否定式 `Bool`（`isNotReady`、`isDisabled` 改用 `isEnabled`）；`k` 前綴或全大寫常數（`kMaxRetry`、`MAX_RETRY`）；單字母變數（`i`、`x`），只有數學公式與極短的 closure 例外。

### 函式與方法

- **要**：動詞開頭，呼叫端讀起來像英文句子：`fetchProfile(id:)`、`insert(_:at:)`。
- **要**：有副作用的用祈使動詞（`sort()`、`append(_:)`、`load()`）；無副作用回傳新值的用過去分詞或名詞（`sorted()`、`appending(_:)`、`formatted()`）。
- **要**：第一個參數的語意已由函式名說明時省略標籤（`remove(at:)`、`fetchProfile(id:)`），否則保留標籤；不為了縮短而用 `_` 省略有意義的標籤。
- **要**：回傳 `Bool` 的方法命名同 `Bool` 屬性規則（`isValid(_:)`、`contains(_:)`）。
- **避免**：`get` 前綴（`getProfile()` 改 `profile` 或 `fetchProfile()`）；`do`、`handle`、`process` 這類不說明做了什麼的動詞。

### enum case

- **要**：lowerCamelCase；不重複型別名（`Direction.north` 而非 `Direction.directionNorth`）。
- **要**：associated value 超過一個時加 label（見 `file-templates.md`）。
- **避免**：`case none` / `case unknown` 以外的「無意義」case，需要表達缺席用 `Optional`。

```swift
/// 一筆訂單，含買了什麼與付款、出貨進度。
struct Order: Identifiable, Sendable {

    /// 訂單識別碼。
    let id: UUID

    /// 下單的顧客識別碼。
    let customerID: UUID

    /// 訂單內的每一項商品。
    let items: [OrderItem]

    /// 是否已付款。
    var isPaid: Bool

    /// 是否已出貨。
    var hasShipped: Bool
}

/// 全 App 共用的版面尺寸。
enum Layout {

    /// 元件之間的標準間距（pt）。
    static let spacing: CGFloat = 16

    /// 卡片與按鈕的圓角半徑（pt）。
    static let cornerRadius: CGFloat = 12
}

/// 能取得訂單清單的來源。
protocol OrderFetching: Sendable {

    /// 取得某位顧客的所有訂單。
    ///
    /// - Parameter customerID: 顧客識別碼。
    /// - Returns: 該顧客的訂單，沒有訂單時為空陣列。
    /// - Throws: 網路失敗或顧客不存在時丟出。
    func fetchOrders(customerID: UUID) async throws -> [Order]
}

/// 找出第一個符合條件的元素。
///
/// - Parameters:
///   - elements: 要搜尋的陣列。
///   - predicate: 判斷元素是否符合的條件。
/// - Returns: 第一個符合的元素；都不符合時為 nil。
func firstMatch<Element>(in elements: [Element], where predicate: (Element) -> Bool) -> Element?
```

## 存取控制

- **要**：成員預設 `private`，只在有外部使用者時放寬，且放寬到剛好夠用的層級；Swift 預設是 `internal`，本規範反過來要求先寫 `private`。
- **要**：外部要讀、只有型別自己改的狀態用 `private(set) var`；ViewModel 暴露給 View 的狀態幾乎都屬於此類。
- **要**：Nested Types 預設 internal（不寫修飾），只有型別自己內部使用的才加 `private`；與 `file-templates.md` 的 ViewModel 規則一致。
- **要**：App target 內的頂層型別不加修飾（隱含 `internal`）；只給同檔用的輔助型別應改為 nested type，而非頂層 `private` 型別。
- **要**：屬性包裝在前、存取控制在後：`@State private var`、`@Environment(\.dismiss) private var dismiss`。
- **要**：`public` / `open` 只出現在 SPM module 或 framework 的對外 API；`open` 只給刻意設計要被繼承的 class。同一 package 內跨 module 共享用 `package`。
- **避免**：明寫 `internal`，它是預設，只增加噪音。
- **避免**：`fileprivate`。同檔 extension 已能存取 `private` 成員，出現 `fileprivate` 通常表示兩個型別該合併或該拆檔。
- **避免**：為了測試放寬存取層級；測試用 `@testable import` 存取 `internal`，`private` 的東西不直接測，透過公開行為驗證。

```swift
/// 個人資料畫面要顯示什麼、按鈕按下後做什麼，都由它決定。
@MainActor
@Observable
final class ProfileViewModel {

    // MARK: - Properties

    /// 畫面目前處於未開始、載入中、完成或失敗哪一種；外部只能讀。
    private(set) var state: State = .idle

    /// 實際去拿個人資料的物件，測試時換成假的。
    private let profileService: any ProfileServiceProtocol

    // MARK: - Init

    /// 建立個人資料畫面的 ViewModel，初始狀態為未開始。
    ///
    /// - Parameter profileService: 實際去拿個人資料的物件。
    init(profileService: any ProfileServiceProtocol) {
        self.profileService = profileService
    }
}

// MARK: - Nested Types

extension ProfileViewModel {

    /// 畫面目前的載入狀態；View 要讀，所以不加 private。
    enum State: Equatable {

        /// 尚未開始載入。
        case idle

        /// 正在向伺服器取得資料。
        case loading

        /// 載入完成。
        ///
        /// - Parameter profile: 取得的個人資料。
        case loaded(Profile)

        /// 載入失敗。
        ///
        /// - Parameter message: 要顯示給使用者的訊息。
        case failed(String)
    }
}
```

## 型別選擇

- **要**：預設 `struct`。需要以下任一才用 `class`：身分語意（同一實例被多處共享並觀察其變化，例如 ViewModel、Coordinator）、框架要求 reference 型別（delegate、`deinit`）、必須繼承系統 class（`XCTestCase`、`UIViewController`）。
- **要**：`class` 一律 `final`，除非刻意設計要被繼承；可被繼承的 class 要有 doc comment 說明可覆寫的點。
- **要**：有可變狀態且會跨執行緒存取的用 `actor`，不用 `class` 加 lock；選型細節見 `file-templates.md` 的 Service 一節。
- **要**：有限集合與狀態機用 `enum`：狀態、分類、選項用無 associated value 的 enum，帶資料的狀態用 associated value；payload 超過三個欄位改 struct。
- **要**：無 case 的 `enum` 作命名空間，放常數群與純 static 工具（`Layout`、`RuntimeEnvironment`）；不用 `struct` 加 `private init()` 模擬。
- **要**：protocol 只在有第二個實作或需要 mock 時才定義。Service / Client / Store / Database / UseCase 因為要 mock 一律有 protocol，其他型別不預先抽象。
- **要**：`some` 優先於 `any`；`any` 只在需要異質集合或存進屬性時用（Service 注入用 `any`）。
- **要**：需要語意上不同的識別碼或單位時用 struct wrapper 取得型別安全，遵循 `Hashable`、`Sendable`，以 `rawValue` 持有底層值。
- **避免**：`typealias` 給基本型別取別名（`typealias UserID = String`），它與 `String` 可互換，不提供型別安全；`typealias` 只用於組合 protocol 與縮短長泛型簽章。
- **避免**：tuple 跨越函式邊界或超過兩個元素；只允許在函式內部或回傳兩個以下的值，其他改 struct。
- **避免**：只有一個具體型別卻寫成 generic；generic 只用於演算法與容器。
- **避免**：`class` 只為了讓屬性可變而用，`struct` 的 `var` 加 `mutating` 或複製修改即可。

```swift
// 型別安全的識別碼：struct wrapper，不用 typealias
/// 使用者識別碼，與其他識別碼型別不可互換。
struct UserID: Hashable, Sendable {

    /// 伺服器給的原始字串。
    let rawValue: String
}

/// 訂單識別碼，與其他識別碼型別不可互換。
struct OrderID: Hashable, Sendable {

    /// 伺服器給的原始字串。
    let rawValue: String
}

// 編譯器會擋下把 OrderID 傳給需要 UserID 的地方
/// 依識別碼取得個人資料。
///
/// - Parameter id: 使用者識別碼。
/// - Returns: 該使用者的個人資料。
/// - Throws: 找不到使用者或網路失敗時丟出。
func fetchProfile(id: UserID) async throws -> Profile

// 組合 protocol 是 typealias 的正確用途
/// 完整的個人資料服務：同時能讀取與更新。
typealias ProfileServiceProtocol = ProfileFetching & ProfileUpdating

// 無 case enum 作命名空間
/// 全 App 共用的版面尺寸。
enum Layout {

    /// 元件之間的標準間距（pt）。
    static let spacing: CGFloat = 16
}
```

## Optional 處理

- **要**：`guard let` 優先於 `if let`：需要提早離開的用 `guard let`，只有在 nil 時仍要繼續執行後續邏輯才用 `if let`。`guard` 的 `else` 只放 `return`、`throw`、`continue`、`break`，不放其他邏輯。
- **要**：同名解包用簡寫 `guard let profile else { return }`，不寫 `guard let profile = profile`。
- **要**：多個 Optional 用逗號串在同一個 `guard let` / `if let`，巢狀不超過一層。
- **要**：optional chaining 最多兩層（`user?.profile?.avatar`），更深就先 `guard let` 拆開，否則 nil 的來源無法辨識。
- **要**：`??` 只給真正有合理預設的情況（空字串、空陣列、0），不用它掩蓋應該視為錯誤的 nil。
- **要**：函式失敗有原因時 `throws`；只有「不存在」是正常結果時才回傳 Optional（`first(where:)`、`dictionary[key]`）。
- **要**：三態用 enum 表達，不用 `Bool?`。
- **避免**：`.none`，一律寫 `nil`。
- **避免**：隱式解包 Optional（`String!`），`IBOutlet` 例外。
- **避免**：`try!` 與 `as!`，無例外；`as!` 的轉型需求改用泛型 helper 或 `as?` 加 `guard let`。

### 強制解包 `!` 的唯一例外

**只允許在 `!` 左側的表達式完全由字面值組成、沒有任何變數參與時使用**，因為結果在寫程式時就已確定，執行期不可能是 nil。判斷標準是機械的：表達式裡有變數就禁止。允許時在同一行或上一行加註解說明是字面值常數。

- **要**：有非 Optional 的替代 API 就用替代，沒有才用字面值加 `!`：正規表達式用 `/\d+/` 字面值而非 `NSRegularExpression(pattern:)!`；SwiftUI 用 `Image("name")`、`Color("name")` 而非 `UIImage(named:)!`；`TimeZone.gmt`、`Locale.current` 這類靜態屬性優先。
- **要**：允許的例外只在 `static let` 常數或測試 fixture 出現，不在一般方法內。
- **避免**：對 `IBOutlet` 以外的隱式解包、對含變數的表達式、對 `try` 與 `as` 使用 `!`。

```swift
// 允許：全是字面值，結果在編譯期確定
/// 與伺服器溝通用的固定設定。
enum API {

    /// 伺服器網址，所有請求都接在它後面。
    static let baseURL = URL(string: "https://api.example.com")!  // 字面值常數

    /// 稅率，5%。
    static let taxRate = Decimal(string: "0.05")!                 // 字面值常數

    /// 顯示時間時使用的時區，固定台北。
    static let taipei = TimeZone(identifier: "Asia/Taipei")!      // 字面值常數
}

// 禁止：有變數參與，結果要到執行期才知道
let zone = TimeZone(identifier: user.timeZoneID)!
let amount = Decimal(string: textField.text ?? "")!

// 正確寫法
guard let zone = TimeZone(identifier: user.timeZoneID) else {
    throw SettingsError.invalidTimeZone(user.timeZoneID)
}
```

```swift
// guard let 優先，同名簡寫，多個 Optional 串在一起
guard let profile, let avatarURL = profile.avatarURL else {
    return
}

// 只有 nil 時仍要繼續才用 if let
if let cached = cache[id] {
    return cached
}
let fresh = try await fetch(id)
cache[id] = fresh
return fresh
```

## Error Handling

### 定義錯誤

- **要**：自訂 Error 一律 `enum`，遵循 `Error`；一個領域一個型別，命名 `<領域>Error`（`ProfileError`、`PaymentError`），以 `domain/Error.swift` 樣板建立。不用單一的全域 `AppError`。
- **要**：case 帶除錯需要的上下文作為 associated value：`case notFound(id: UserID)`、`case invalidInput(field: String, reason: String)`；不用字串描述取代結構化資料。
- **要**：包裝底層錯誤時用 `underlying` label 保留原始錯誤：`case network(underlying: any Error)`。
- **要**：錯誤要直接顯示給使用者時才遵循 `LocalizedError` 並實作 `errorDescription`，放 `// MARK: - LocalizedError` extension；純內部錯誤不做本地化。
- **避免**：`Equatable` 遵循，因為 `underlying: any Error` 無法自動合成；測試用 `if case` 或 `switch` 比對 case，不比對整個值。
- **避免**：`String` 或 `Int` 當 raw value 的 Error enum，錯誤碼需要對外時另外提供 computed property。

### 丟出與傳遞

- **要**：Service / Client / Store / Database 的 protocol 方法一律用 typed throws：`func fetchProfile(id: UserID) async throws(ProfileError) -> Profile`，讓呼叫端知道會拿到哪種錯誤。
- **要**：Service 抓到 `URLError`、`DecodingError` 等底層錯誤時，轉成自己領域的 Error 再往上丟；ViewModel 不應該看到 `URLError`。
- **要**：UseCase 與 ViewModel 這類跨領域的組合層用一般 `throws`，不強行合併多個領域的 Error 型別。
- **要**：`throws` 優先於 `Result`；`Result` 只用於把成功或失敗存起來（Mock 的 `<method>Result`）或傳給不能 `throw` 的 callback。
- **避免**：用 Optional 或 `Bool` 回傳值表達失敗，失敗有原因就 `throws`。

### 接住與處理

- **要**：typed throws 的 `catch` 寫法固定為一個通用 `catch`，在裡面 `switch error` 窮舉所有 case；`catch` 子句本身沒有窮舉檢查，寫 `catch .notFound` 這種子句最後仍要補通用 `catch`，反而分散邏輯。
- **要**：ViewModel 的 `catch` 最後一定有一個分支把未預期的錯誤轉成 `State.failed`，畫面不能因為漏接而停在 loading。
- **要**：`Task` 被取消時（`CancellationError` 或 `Task.isCancelled`）直接 `return`，不顯示錯誤給使用者。
- **要**：`try?` 只用於「操作失敗後，使用者原本要做的事仍做得成」的情況：快取讀寫、清理暫存、分析追蹤、記住偏好、預先載入、解析可選欄位；同一行加註解寫明「失敗可忽略，因為 …」。
- **避免**：`try?` 用在主要資料的讀寫、必要欄位解析、任何影響使用者可見結果的操作；這些一律 `do catch`。
- **避免**：空的 `catch {}`，以及只 `print` 不處理的 `catch`。
- **避免**：`fatalError` / `precondition` 用於執行期可能發生的狀況；它們只用於違反程式不變量的邏輯錯誤。

```swift
// Service：typed throws，包裝底層錯誤
/// 從伺服器取得個人資料的正式實作。
struct ProfileService {

    /// 實際發出網路請求的物件。
    private let client: any APIClientProtocol
}

// MARK: - ProfileServiceProtocol

extension ProfileService: ProfileServiceProtocol {

    /// 每次都向伺服器抓取，不做快取；伺服器與解析錯誤都轉成 `ProfileError`。
    ///
    /// - Parameter id: 使用者識別碼。
    /// - Returns: 伺服器回傳的最新個人資料。
    /// - Throws: 資料格式不符丟 `.decoding`，其餘連線問題丟 `.network`。
    func fetchProfile(id: UserID) async throws(ProfileError) -> Profile {
        do {
            let data = try await client.request(.profile(id))
            return try JSONDecoder().decode(Profile.self, from: data)
        } catch let error as DecodingError {
            throw .decoding(underlying: error)
        } catch {
            throw .network(underlying: error)
        }
    }
}

// ViewModel：通用 catch 內 switch 窮舉，取消不當錯誤
/// 載入個人資料並更新畫面狀態；被取消時不改變狀態。
func load() async {
    state = .loading
    do {
        let profile = try await profileService.fetchProfile(id: userID)
        state = .loaded(profile)
    } catch {
        guard !Task.isCancelled else { return }
        switch error {
        case .notFound:
            state = .failed(String(localized: "profile.notFound"))
        case .network, .decoding, .invalidInput:
            state = .failed(String(localized: "profile.unavailable"))
        }
    }
}

// try? 的合法用途：失敗可忽略，因為快取寫不進去下次會重抓
try? cache.store(profile)
```

## Concurrency

以 Swift 6 語言模式與 strict concurrency 為前提。

### 模型

- **要**：async/await 是唯一的非同步模型。既有的 completion handler API 在該 Client 內以 `withCheckedThrowingContinuation` 包成 async 後再使用，包裝不外洩。
- **要**：系統提供的 Combine publisher（`NotificationCenter`、`Timer`、KVO）用 `.values` 或對應的 `AsyncSequence` API（`NotificationCenter.notifications(named:)`）轉成 `AsyncSequence`，以 `for await` 消費。
- **要**：多個獨立請求用 `async let` 並行；數量不定時用 `withThrowingTaskGroup`。
- **避免**：自建 Combine pipeline（`sink`、`AnyCancellable`、`@Published`、自訂 `Publisher`）；GCD（`DispatchQueue`、`DispatchGroup`、semaphore）；`Thread.sleep`，改用 `Task.sleep(for:)`。
- **避免**：可並行的請求循序 `await` 排隊。

### Actor 與隔離

- **要**：`@MainActor` 標在型別上：ViewModel、Coordinator 整個型別標，不逐方法標。Service / Client / Store / UseCase / Model 不標，在呼叫端的隔離域執行；Database 是 `@ModelActor`，自帶隔離。
- **要**：跨隔離域傳遞的型別一律 `Sendable`；Model 預設已遵循。
- **要**：`nonisolated` 只用於 `@MainActor` 型別內確實不碰狀態的純函式，且加註解說明。
- **要**：actor 方法內的 `await` 會讓出隔離（reentrancy），跨 `await` 之後要重新檢查依賴的狀態，不假設它沒變。
- **避免**：`@unchecked Sendable` 壓警告，唯二例外是 Mock 與 Service 選型表第四列。
- **避免**：`DispatchQueue.main.async`，`@MainActor` 內本來就在主執行緒。
- **避免**：`nonisolated(unsafe)`，無例外。

### Task 的建立與取消

- **要**：`Task { }` 只在兩個地方建立：SwiftUI 的 `.task` modifier（優先，隨 View 消失自動取消），以及使用者動作觸發的 ViewModel 方法內。
- **要**：ViewModel 持有可能被重複觸發的長時間 Task 時，存成 `@ObservationIgnored private var loadTask: Task<Void, Never>?`，重新觸發前先 `cancel()`。
- **要**：長迴圈或多步驟流程內定期 `try Task.checkCancellation()`；`catch` 內先檢查 `Task.isCancelled` 再處理錯誤。
- **避免**：`Task.detached`，需要脫離 `@MainActor` 的工作交給 actor 或 nonisolated 函式；真的用到要註解理由。
- **避免**：在 `init` 內建立 Task；初始化不做非同步工作，由 View 的 `.task` 觸發。
- **避免**：忘記持有而無法取消的 Task（fire-and-forget），除了明確只跑一次且無副作用的情況。

```swift
/// 首頁儀表板要顯示的資料與載入動作。
@MainActor
@Observable
final class DashboardViewModel {

    // MARK: - Properties

    /// 目前使用者的個人資料，尚未載入時為 nil。
    private(set) var profile: Profile?

    /// 目前使用者的訂單，尚未載入時為空。
    private(set) var orders: [Order] = []

    /// 取得個人資料的物件。
    private let profileService: any ProfileServiceProtocol

    /// 取得訂單的物件。
    private let orderService: any OrderServiceProtocol

    /// 正在進行的載入工作，重新載入前先取消它。
    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    // ...
}

// MARK: - Internal Method

extension DashboardViewModel {

    // async let 並行兩個獨立請求
    /// 同時載入個人資料與訂單，兩者都完成後才更新畫面；被取消時不更新。
    func load() async {
        do {
            async let profile = profileService.fetchProfile(id: userID)
            async let orders = orderService.fetchOrders(customerID: userID)
            self.profile = try await profile
            self.orders = try await orders
        } catch {
            guard !Task.isCancelled else { return }
            // 轉成 State.failed
        }
    }

    // 重複觸發前取消上一次
    /// 重新載入；上一次還沒完成的話先取消，避免舊結果蓋掉新結果。
    func reload() {
        loadTask?.cancel()
        loadTask = Task { await load() }
    }

    // 系統通知用 AsyncSequence 消費，不用 Combine
    /// 每次 App 從背景回到前景就重新載入一次，直到所在的 Task 被取消。
    func observeForeground() async {
        for await _ in NotificationCenter.default.notifications(named: UIApplication.willEnterForegroundNotification) {
            await load()
        }
    }
}

// View：兩個獨立的 .task，隨 View 消失自動取消
/// 儀表板畫面骨架：顯示時載入資料並開始監聽回前景事件。
var body: some View {
    content
        .task { await viewModel.load() }
        .task { await viewModel.observeForeground() }
        .refreshable { viewModel.reload() }
}
```

## 註解與 Doc Comment

### Doc Comment（`///`）

- **要**：**所有宣告一律有 `///`，沒有例外**，不分存取層級：型別、protocol 與其每個要求、extension 內的每個方法與 computed property、stored property、enum 的每個 case、nested type、`private` 成員、測試方法、protocol 遵循 extension 內的實作。
- **要**：protocol 要求與其實作**兩邊都寫**，但內容不同：protocol 上寫「做什麼、呼叫端能期待什麼」；實作上寫「這個實作怎麼做」，例如資料來源、有無快取、平台限制、與其他實作的差異。實作端不複製 protocol 的句子。
- **要**：第一行一句話摘要，說明「這是什麼」或「做什麼」，動詞開頭，句末加句號；型別的摘要說明職責與使用時機。
- **要**：摘要後空一行，依序寫 `- Parameter x:`（單一參數）或 `- Parameters:`（多個參數，每個一行縮排）、`- Returns:`、`- Throws:`。**有參數就一定寫參數、有回傳值就一定寫回傳、會 throw 就一定寫 Throws**，不因名稱已清楚而省略；`Throws` 寫出哪些情況丟哪個 case。
- **要**：`init` 一律有摘要，說明建立出來的東西是什麼、需要什麼；參數依上一條寫。
- **要**：enum case 帶 associated value 時，每個 value 都以 `- Parameter` / `- Parameters:` 說明，寫法與函式參數相同；沒有 label 的 value 以型別名稱小寫作為名稱（`- Parameter profile:`）。
- **要**：摘要與參數之外還需要補充時用 `- Note:`，放在 `- Throws:` 之後；一個 `- Note:` 講一件事，例如使用前提、效能特性、與其他方法的關係、平台限制。不用自由段落補充，也不用 `- Important:`、`- Warning:`、`- Remark:` 等其他標記。
- **要**：正體中文，技術名詞、型別名、識別字保留英文並以反引號標示。
- **要**：用白話文寫，目標是**完全不懂程式的人也能看懂這段程式碼在做什麼**：說使用者看得到的結果與情境，不說實作機制；能用日常詞就不用術語，非用術語不可時在同一句用括號解釋。例如「取得使用者的個人資料；最近抓過就用上次的，不再連網路」，而不是「透過 cache-aside 策略 fetch profile entity」。
- **要**：白話但精簡。摘要一句話說完，補充段落每句只講一件事；先寫完再刪，刪到再刪一個字就少一個資訊為止。判斷標準：每個詞拿掉後意思有沒有變，沒變就刪。
- **避免**：冗言贅字：「這個函式的用途是用來 …」直接寫「…」；「基本上」「其實」「進行 … 的動作」「相關的」「一些」；同一件事換句話再說一次；把摘要已經說過的內容在補充段落重複。
- **避免**：複述名稱的廢話（`/// 使用者 ID` 放在 `userID` 上）；摘要要說出名稱沒說的資訊，例如來源、單位、生命週期、限制。
- **避免**：只有工程師才懂的寫法：縮寫（`VM`、`repo`、`DI`）、設計模式名稱當作說明（「這是 facade」）、以型別簽章代替描述（「回傳 `Result<Profile, ProfileError>`」）。
- **避免**：`/** */` 區塊式 doc comment，一律 `///`。

### 一般註解（`//`）

- **要**：只寫「為什麼」：非直覺的決定、workaround 的原因與對應的系統版本、與本規範衝突時的理由、`try?` 為何可忽略、`!` 為何是字面值常數。
- **要**：`// TODO:` 與 `// FIXME:` 固定格式 `// TODO: [#123] 描述`，必附 issue 編號；沒有 issue 就直接做完或先開 issue，不留無主的 TODO。`FIXME` 用於已知會出錯的地方，`TODO` 用於尚未實作。
- **避免**：複述程式碼的註解（`// 設定 title`）。
- **避免**：被註解掉的程式碼，一律刪除，需要時從 git 歷史找。
- **避免**：在 `@available`、`@discardableResult` 這類屬性上方另加註解說明用途。
- **避免**：`// MARK:` 使用規範以外的分區名稱。

```swift
/// 向伺服器讀取與更新使用者個人資料的唯一入口。
protocol ProfileServiceProtocol: Sendable {

    /// 依識別碼取得個人資料；最近抓過就用上次的，不再連網路。
    ///
    /// - Parameter id: 要查詢的使用者識別碼。
    /// - Returns: 該使用者的個人資料。
    /// - Throws: 找不到使用者丟 `ProfileError.notFound`；網路連不上丟 `ProfileError.network`。
    /// - Note: 快取保留五分鐘，要強制重抓請先呼叫 `invalidateCache()`。
    func fetchProfile(id: UserID) async throws(ProfileError) -> Profile
}

/// 個人資料畫面要顯示什麼、按鈕按下後做什麼，都由它決定。
@MainActor
@Observable
final class ProfileViewModel {

    // MARK: - Properties

    /// 畫面目前處於未開始、載入中、完成或失敗哪一種，決定顯示內容。
    private(set) var state: State = .idle

    /// 實際去拿個人資料的物件，測試時換成假的以免連網路。
    private let profileService: any ProfileServiceProtocol

    // MARK: - Init

    /// 建立個人資料畫面的 ViewModel，初始狀態為未開始。
    ///
    /// - Parameter profileService: 實際去拿個人資料的物件。
    init(profileService: any ProfileServiceProtocol) {
        self.profileService = profileService
    }
}

// MARK: - Private Method

private extension ProfileViewModel {

    /// 把內部錯誤翻譯成使用者看得懂的一句話，所有錯誤都顯示同一句通用訊息。
    ///
    /// - Parameter error: 載入個人資料時發生的錯誤。
    /// - Returns: 可直接顯示在畫面上的文案。
    func message(for error: ProfileError) -> String {
        // iOS 17 的 String(localized:) 在 Preview 內不會套用 bundle，故明確指定
        String(localized: "profile.unavailable", bundle: .main)
    }
}
```

## 常見錯誤檢查清單

- [ ] 命名：`Manager` / `Handler` / `Provider` 用在不符本意的型別、`Helper` / `Util` 後綴、`get` 前綴、否定式 `Bool`、以型別當後綴（`userArray`）、`Id` 而非 `ID`、泛型用單字母
- [ ] 存取控制：成員未從 `private` 起手、明寫 `internal`、出現 `fileprivate`、為測試放寬存取層級、屬性包裝與存取控制順序顛倒
- [ ] 型別：`class` 未加 `final`、可變共享狀態用 `class` 加 lock 而非 `actor`、`typealias` 給基本型別取別名、tuple 跨函式邊界、只有一個實作卻定義 protocol
- [ ] Optional：`if let` 用在該提早離開的地方、`guard` 的 `else` 內有邏輯、optional chaining 超過兩層、`??` 掩蓋錯誤、`Bool?`、`.none`
- [ ] 強制解包：`!` 左側含變數、`try!`、`as!`、`IBOutlet` 以外的隱式解包、字面值 `!` 出現在一般方法內而非 `static let`
- [ ] Error：全域 `AppError`、Error 帶 raw value、Service 方法未用 typed throws、Service 外洩 `URLError` / `DecodingError`、`catch` 子句分散而非通用 `catch` 內 `switch`
- [ ] Error：`try?` 用在主要資料讀寫或必要欄位、`try?` 未附「失敗可忽略」註解、空的 `catch`、只 `print` 的 `catch`、`CancellationError` 顯示給使用者、`fatalError` 用於執行期狀況
- [ ] Concurrency：completion handler、自建 Combine pipeline、`DispatchQueue`、`Thread.sleep`、可並行的請求循序 `await`
- [ ] Concurrency：`@MainActor` 標在方法而非型別、Service / Model 標 `@MainActor`、`@unchecked Sendable` 壓警告、`nonisolated(unsafe)`、`DispatchQueue.main.async`
- [ ] Task：`Task.detached`、`init` 內建 Task、可重複觸發的 Task 未持有與取消、`catch` 內未先檢查 `Task.isCancelled`
- [ ] 註解：任何宣告缺 `///`（含 `private`、`case`、`init`、protocol 實作）、有參數缺 `- Parameter`、有回傳缺 `- Returns`、會 throw 缺 `- Throws`、associated value 缺 `- Parameter`
- [ ] 註解：術語與縮寫、複述名稱、冗言贅字、實作端複製 protocol 的句子、`// TODO` 沒有 issue 編號、被註解掉的程式碼、複述程式碼的 `//`
