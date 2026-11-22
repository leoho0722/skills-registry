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
    - [`static` 的使用時機](#static-的使用時機)
  - [函式拆分](#函式拆分)
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

- **要**：型別 UpperCamelCase；後綴只用已定義的角色名：`View`、`ViewModel`、`Coordinator`、`Service`、`Client`、`Store`、`Database`、`Records`、`UseCase`、`FormatStyle`、`Tests`、`UITests`、`TestSupport`。
- **要**：描述能力的 protocol 用 `-able` / `-ible` / `-ing`（`Sendable`、`ProfileFetching`）；描述角色的 protocol 用名詞加 `Protocol` 後綴（`ProfileServiceProtocol`）。
- **要**：泛型參數一律具名，表達它的角色：`Element`、`Output`、`Value`、`Key`；單字母 `T` 只允許在完全沒有語意的工具函式（例如 `identity<T>(_:)`）。
- **要**：`Manager`、`Handler`、`Provider` 只在型別的職責**確實符合該字的本意**時使用，判斷標準如下表；符合就用，不符合就改用能說明職責的字。`Helper` 與 `Util` 沒有對應的職責，不使用。
- **避免**：型別名前綴（`LHProfile`），Swift 有 module 命名空間。

| 後綴 | 本意 | 符合時的特徵 | 不符合時該叫什麼 |
|---|---|---|---|
| `Manager` | 管理一組資源的生命週期 | 建立、追蹤、回收多個存活期長於單次呼叫的同類物件，例如連線池、下載任務集合 | 只做一組操作 → `Service`；包裝系統物件 → `Client` |
| `Handler` | 被動回應一個事件 | closure 參數名（`completionHandler`），或責任鏈、middleware 中的一環，接在其他 Handler 前後處理同一個輸入 | 主動提供功能 → `Service`；只是一個方法 → 動詞命名的函式 |
| `Provider` | 按需提供一個值，本身無業務邏輯 | 介面只有一兩個回傳值的方法、無狀態、為了可替換與可測試而存在，例如 `DateProvider.now()`、`LocaleProvider` | 有業務邏輯 → `Service`；有狀態 → `Store` |
| `Helper` / `Util` | 無 | 無 | 依內容命名：測試用的固定資料放 `Fixtures`，多個測試型別共用的 helper 收進 `<TypeUnderTest>TestSupport`，沒有對應受測型別的放 `Support/` 裡以主題命名的命名空間（`file-templates.md` 的 tests/Tests.swift 一節）；共用函式收進以主題命名的無 case `enum` 或對應型別的 extension |

### 變數、屬性與常數

- **要**：lowerCamelCase；依角色而非型別命名，集合用複數：`users` 而非 `userArray`、`name` 而非 `nameString`。
- **要**：`Bool` 用 `is` / `has` / `can` / `should` 開頭的肯定斷言：`isLoading`、`hasUnreadMessages`、`canSubmit`、`shouldRetry`。
- **要**：常數與變數同為 lowerCamelCase；同一主題的全域常數收進無 case 的 `enum` 作為命名空間：`enum Layout { static let spacing: CGFloat = 16 }`。
- **要**：縮寫依位置轉換大小寫：在開頭全小寫（`urlString`、`htmlBody`、`id`），在中間或結尾全大寫（`baseURL`、`userID`、`parseJSON`）。`ID` 固定大寫，`Identifiable.id` 單獨出現時是小寫 `id`。
- **避免**：否定式 `Bool`（`isNotReady`、`isDisabled` 改用 `isEnabled`）；`k` 前綴或全大寫常數（`kMaxRetry`、`MAX_RETRY`）；單字母變數（`i`、`x`），只有數學公式與極短的 closure 例外。

### 函式與方法

- **要**：動詞開頭，呼叫端讀起來像英文句子：`fetchProfile(id:)`、`insert(_:at:)`。
- **要**：有副作用的用祈使動詞（`sort()`、`append(_:)`、`load()`）；無副作用回傳新值的用過去分詞或名詞（`sorted()`、`appending(_:)`、`formatted()`）。
- **例外**：刻意對齊系統 API 的方法沿用系統的名稱與參數標籤，不套用上一條。例如包 `URLSession` 的 Client 提供 `data(for:)`、`bytes(for:)`，雖然會發出網路請求，名稱仍與 `URLSession.data(for:)`、`bytes(for:)` 一致，讀者一看就知道對應哪個系統 API。只限鏡像既有系統 API 的方法，自己設計的操作照上一條命名。
- **要**：第一個參數的語意已由函式名說明時省略標籤（`remove(at:)`、`fetchProfile(id:)`），否則保留標籤；不為了縮短而用 `_` 省略有意義的標籤。
- **要**：回傳 `Bool` 的方法命名同 `Bool` 屬性規則（`isValid(_:)`、`contains(_:)`）。
- **避免**：`get` 前綴（`getProfile()` 改 `profile` 或 `fetchProfile()`）；`do`、`handle`、`process` 這類不說明做了什麼的動詞。

### enum case

- **要**：lowerCamelCase；不重複型別名（`Direction.north` 而非 `Direction.directionNorth`）。
- **要**：associated value 超過一個時加 label（見 `file-templates.md`）。
- **避免**：`case none` / `case unknown` 以外的「無意義」case，需要表達缺席用 `Optional`。

```swift
/// 一筆訂單，含買了什麼與付款、出貨進度
struct Order: Identifiable, Sendable {

    /// 訂單識別碼
    let id: UUID

    /// 下單的顧客識別碼
    let customerID: UUID

    /// 訂單內的每一項商品
    let items: [OrderItem]

    /// 是否已付款
    var isPaid: Bool

    /// 是否已出貨
    var hasShipped: Bool
}

/// 全 App 共用的版面尺寸
enum Layout {

    /// 元件之間的標準間距（pt）
    static let spacing: CGFloat = 16

    /// 卡片與按鈕的圓角半徑（pt）
    static let cornerRadius: CGFloat = 12
}

/// 能取得訂單清單的來源
protocol OrderFetching: Sendable {

    /// 取得某位顧客的所有訂單
    ///
    /// - Parameter customerID: 顧客識別碼
    /// - Returns: 該顧客的訂單，沒有訂單時為空陣列
    /// - Throws: 網路失敗或顧客不存在時丟出
    func fetchOrders(customerID: UUID) async throws -> [Order]
}

/// 找出第一個符合條件的元素
///
/// - Parameters:
///   - elements: 要搜尋的陣列
///   - predicate: 判斷元素是否符合的條件
/// - Returns: 第一個符合的元素；都不符合時為 nil
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
/// 個人資料畫面要顯示什麼、按鈕按下後做什麼，都由它決定
@MainActor
@Observable
final class ProfileViewModel {

    // MARK: - Properties

    /// 畫面目前處於未開始、載入中、完成或失敗哪一種；外部只能讀
    private(set) var state: State = .idle

    /// 實際去拿個人資料的物件，測試時換成假的
    private let profileService: any ProfileServiceProtocol

    // MARK: - Init

    /// 建立個人資料畫面的 ViewModel，初始狀態為未開始
    ///
    /// - Parameter profileService: 實際去拿個人資料的物件
    init(profileService: any ProfileServiceProtocol) {
        self.profileService = profileService
    }
}

// MARK: - Nested Types

extension ProfileViewModel {

    /// 畫面目前的載入狀態；View 要讀，所以不加 private
    enum State: Equatable {

        /// 尚未開始載入
        case idle

        /// 正在向伺服器取得資料
        case loading

        /// 載入完成
        ///
        /// - Parameter profile: 取得的個人資料
        case loaded(Profile)

        /// 載入失敗
        ///
        /// - Parameter message: 要顯示給使用者的訊息
        case failed(String)
    }
}
```

## 型別選擇

- **要**：預設 `struct`。需要以下任一才用 `class`：身分語意（同一實例被多處共享並觀察其變化，例如 ViewModel、Coordinator）、框架要求 reference 型別（delegate、`deinit`）、必須繼承系統 class（`XCTestCase`、`UIViewController`）。
- **要**：`class` 一律 `final`，除非刻意設計要被繼承；可被繼承的 class 要有 doc comment 說明可覆寫的點。
- **要**：型別成員（type property、type method）照 Apple 文件與社群慣例：自己宣告、不打算被覆寫的寫 `static`；覆寫父類別的 class 成員時沿用父類別的寫法（`override class var layerClass: AnyClass`）；只有刻意設計要被繼承的 class，宣告可被覆寫的型別成員時才寫 `class`。排序時 `class` 成員視同 static，見 `formatting.md` 的區內排序。
- **要**：有可變狀態且會跨執行緒存取的用 `actor`，不用 `class` 加 lock；選型細節見 `file-templates.md` 的 Service 一節。
- **要**：有限集合與狀態機用 `enum`：狀態、分類、選項用無 associated value 的 enum，帶資料的狀態用 associated value；payload 超過三個欄位改 struct。
- **要**：無 case 的 `enum` 作命名空間，放多個型別共用的常數群、純 static 工具（`Layout`、`RuntimeEnvironment`）與資料存取 helper（`<Name>Records`）；不用 `struct` 加 `private init()` 模擬。
- **要**：protocol 只在有第二個實作或需要 mock 時才定義。Service / Client / Store / Database / UseCase 因為要 mock 一律有 protocol，其他型別不預先抽象。
- **要**：`some` 優先於 `any`；`any` 只在需要異質集合或存進屬性時用（Service 注入用 `any`）。
- **要**：需要語意上不同的識別碼或單位時用 struct wrapper 取得型別安全，遵循 `Hashable`、`Sendable`，以 `rawValue` 持有底層值。
- **避免**：`typealias` 給基本型別取別名（`typealias UserID = String`），它與 `String` 可互換，不提供型別安全；`typealias` 只用於組合 protocol、縮短長泛型簽章，以及 TCA 專案 Service 的 closure 型別（見 `tca-architecture.md`）。
- **避免**：tuple 跨越函式邊界或超過兩個元素；只允許在函式內部或回傳兩個以下的值，其他改 struct。
- **避免**：只有一個具體型別卻寫成 generic；generic 只用於演算法與容器。
- **避免**：`class` 只為了讓屬性可變而用，`struct` 的 `var` 加 `mutating` 或複製修改即可。

```swift
// 型別安全的識別碼：struct wrapper，不用 typealias
/// 使用者識別碼，與其他識別碼型別不可互換
struct UserID: Hashable, Sendable {

    /// 伺服器給的原始字串
    let rawValue: String
}

/// 訂單識別碼，與其他識別碼型別不可互換
struct OrderID: Hashable, Sendable {

    /// 伺服器給的原始字串
    let rawValue: String
}

// 編譯器會擋下把 OrderID 傳給需要 UserID 的地方
/// 依識別碼取得個人資料
///
/// - Parameter id: 使用者識別碼
/// - Returns: 該使用者的個人資料
/// - Throws: 找不到使用者或網路失敗時丟出
func fetchProfile(id: UserID) async throws -> Profile

// 組合 protocol 是 typealias 的正確用途
/// 完整的個人資料服務：同時能讀取與更新
typealias ProfileServiceProtocol = ProfileFetching & ProfileUpdating

// 無 case enum 作命名空間
/// 全 App 共用的版面尺寸
enum Layout {

    /// 元件之間的標準間距（pt）
    static let spacing: CGFloat = 16
}
```

### `static` 的使用時機

`static` 成員不屬於任何實例，所以沒有實例的持有者與生命週期，也不受 actor 實例的隔離；所在型別標了 global actor（例如 `@MainActor`）時，它仍受該 actor 隔離。改成 `static` 常能消除 `self`、初始化順序與隔離錯誤，但編譯通過不代表設計正確，可變的共享狀態同樣能通過編譯。因此先判斷是否需要，再判斷用途是否允許，不依能否編譯判斷。

語言、框架或本規範明定為型別成員的宣告，不走下方的判斷順序，直接對照用途表，例如 protocol 的型別成員要求、`FormatStyle` 便利存取子、`<TypeUnderTest>TestSupport` 的成員、非泛型型別中由多個成員共用的 `os.Logger`、正式程式碼中含字面值 `!` 的常數（測試 fixture 內可寫區域 `let`）。其餘成員依序判斷，前一步做得到就停下；第 1、2 步的前提是移動後仍維持所需的求值時機、求值次數與生命週期：

1. 只在一處使用的值或一兩行邏輯，直接寫在使用處。
2. 只有一個函式或 computed property 使用的值，寫區域 `let`；達到「函式拆分」門檻的邏輯不寫 local function，抽成同型別的 private 方法，再依第 3、4 步決定是否 `static`。
3. 值或邏輯依賴實例，或只在實例建立完成後使用，寫 instance 成員：常數寫 instance `let`，函式寫 instance 方法，即使它們不依賴實例、只是被多個 instance 成員共用。常數的前提是型別能在本體保存它，而且保存後不改變自動合成的遵循、編碼輸出或持久化欄位；做不到時走第 4 步。
4. 以上都不適用，而且說得出下列任一理由，才用 `static`：
   - **沒有可用的實例**：`init` 內 stored property 尚未全部賦值、property initializer、預設參數、`@Test(arguments:)` 與 Swift Testing trait 等 attribute 的引數、建立實例的工廠，以及由框架要求的 `static` 成員或它建立的 closure 直接或間接呼叫、沿途沒有能承載這個方法的 `self` 的情況；已依本順序確定為 `static` 的成員要用到的常數與函式也算。呼叫端只是自己寫成 `static` 不算。
   - **由多個型別共用**：放進無 case 的 `enum` 命名空間或 `<TypeUnderTest>TestSupport`。收納共用函式的命名空間以成員為單位判斷，規則見下方「命名空間以成員為單位判斷」。
   - **型別無法或不宜保存 instance 常數**：有 case 的 `enum` 與 extension 不能宣告 instance stored property；型別要自動合成 `Equatable`、`Hashable`，而常數的型別不遵循時，加入後就無法合成；自動合成 `Codable` 且沒有以 `CodingKeys` 排除它時，它會被編碼進輸出，並出現無法解碼的警告；SwiftData `@Model` 的 stored property 預設會成為儲存欄位，寫 `let` 也無法展開巨集；`static` 成員不會進 schema，寫在本體不影響儲存欄位與版本指紋。這時寫 `static let`：頂層型別放本體的 Properties 區，巢狀型別依 `formatting.md` 的「巢狀型別」就地宣告，擴充非自己的型別時寫在該 extension。以下兩種情況無法宣告 static stored property，改寫回傳字面值的唯讀 computed property：泛型型別與 protocol extension；常數的型別是不遵循 `Sendable` 的系統或第三方型別，例如 `[PartialKeyPath<OrderRecord>]`：所在型別沒有 global actor 隔離時，Swift 6 會判定它不是並行安全而無法編譯；有隔離時雖然能宣告，存取會被限制在該 actor。本規範兩種都改寫 computed property，也不為了寫成 `static let` 而把型別改成 `& Sendable`。computed property 只有 instance 成員使用時寫 instance getter，已有成立的 `static` 呼叫端時寫 `static var`，依存取層級放 Computed Properties 或 Private Method 區。存取層級都依實際呼叫範圍決定。

**命名空間以成員為單位判斷**：收納共用函式的無 case `enum`（以主題名詞命名，例如 `OrderFilterRules`）不以整個命名空間判斷是否共用，而是逐一檢查成員。成員只被一個型別呼叫時，搬回該型別，依本順序重新判斷，通常是 private 方法。這條只管函式與 computed property；只放常數的命名空間，以及函式命名空間裡的常數，依 `project-structure.md` 放置表的「常數」一列：只有一個型別用的常數留在該型別，DesignSystem 的 Token 除外。下方「不適用」列出的命名空間，常數與函式都不適用。

- 呼叫型別的算法：
    - 正式程式碼的命名空間只算正式程式碼的呼叫型別；測試 target 的命名空間（例如 TestSupport）只算測試型別的呼叫。
    - 測試不算正式程式碼成員的呼叫端，不論是直接測它，還是拿它建立資料或算預期值。成員搬成 private 後，改由擁有它的型別的測試涵蓋，不為了測試放寬存取層級。
    - 呼叫端本身是另一個命名空間的成員時，往上追到不是命名空間的型別再計算；途中遇到下方「不適用」裡本規範明定保留的命名空間（例如 `<Name>Records`）就停在那裡，把它算成一個呼叫型別。彙總所有呼叫鏈後只剩它一個時，由它承載這個成員，例如收成它的 private helper；兩個以上的 Records 都呼叫時，留在命名空間。
    - 呼叫端是同一個型別、但分散在不同檔案（例如多個檔案各自的 `extension DependencyValues`）時，搬成 private 會跨不了檔，視為多個型別共用，留在命名空間。
- 唯一的呼叫端是 View 時，依性質決定去處：
    - 純 UI 計算（版面數值、`Color`、`Bool` 這類，條件見 `file-templates.md` 的 `presentation/View.swift`）搬進該 View 的 Private Method。
    - 業務邏輯搬到 ViewModel，TCA 專案搬到 Feature 的 `State`：寫 computed property，需要參數（例如 `locale`）時寫 `State` 的方法。View 本身不持有 store 或 ViewModel 時，由持有它的上層 View 取值後傳入。
    - 給畫面顯示的格式化一律改寫成 `FormatStyle`，見下方「不適用」。
- 成員沒有任何呼叫端時（正式程式碼的命名空間看正式呼叫端，測試 target 的命名空間看測試呼叫端），它是沒用到的程式碼，連同只測它的測試一起刪除。例外有兩種：
    - 已排定的後續變更要用，而且有變更文件明確點名這個成員與要用它的變更：保留到那個變更；那個變更完成或取消後仍沒有呼叫端，就刪除。
    - 只是轉呼叫正式邏輯的測試入口（例如讓測試呼叫 private 建構方法的 `makeXForTesting`）：不刪測試，改成讓測試走正式入口（例如讓正式入口接受參數），不為了測試另開入口。
- 以下不適用本規則：
    - 給畫面顯示的格式化 helper：不看呼叫端數量，依鐵則 8 一律改寫成 `FormatStyle`，放置位置見 `project-structure.md` 的「Formatters」。Data 層組資料用的字串（例如匯出 CSV、組請求參數）不是顯示格式化，照本規則判斷。
    - 無障礙識別碼目錄：成員存在與否由目錄本身決定，搬走後目錄就不完整；帶參數的識別碼產生方法（例如 `orderRow(id:)`）也算。
    - App 與測試 target 共用的資料與常數，例如 Preview 與 snapshot 測試共用的固定資料、UI 測試也要用的識別碼，以及 UI 測試必須和 App 端種子資料一致的值（`file-templates.md` 的「測試固定資料依使用範圍宣告」）。
    - 本規範明定成員或抽取條件的命名空間：`<Name>Records` 依 `file-templates.md` 的 `data/Records.swift`，`RuntimeEnvironment` 依同檔的 `core/RuntimeEnvironment.swift`。
    - 依 `file-templates.md` tests 一節拆出的參數化測試資料型別。

確定需要 `static` 後，還要符合下表的用途。不論寫成 stored 或 computed，會隨部署環境、帳號或遠端設定改變，或測試需要換值的值，都不能用 `static` 寫死，改由 init 參數傳入。

| 用途 | 條件 | 例子 |
|---|---|---|
| 字面值常數 | `static let`（泛型型別、protocol extension，以及常數型別不遵循 `Sendable` 時，寫回傳字面值的唯讀 `static var`），同時符合下方三項條件 | `Layout.spacing`、`Notification.Name("didSync")` |
| 行程內不變的衍生值 | computed property，只由字面值常數或行程啟動後不變的系統值（例如啟動參數，以及由啟動端設定、行程內不改寫的環境變數）算出 | `RuntimeEnvironment.isPreview` |
| 純函式與工廠 | 結果只由參數決定，沒有 I/O，不讀寫可變狀態，也不建立或回傳 Service、Client、Store、Database | `normalizedID(from:)`、`fixture(...)` |
| 錯誤轉換 helper | 只執行呼叫端傳入的操作，並把失敗轉成領域錯誤；本身不做其他 I/O，也不持有狀態 | `PersistenceError.mapFetch { ... }` |
| 資料存取 helper | 通過判斷順序後，以無 case `enum` 收納同步 `static func`，只在當次呼叫內使用呼叫端傳入的 `ModelContext` 或已開啟的交易；不另取依賴、不另開資料庫或交易、不保存 `context`、不讓 `context` 或受管理物件逸出隔離域，也不決定提交或回滾。透過 Database 存取時，`read` 只做查詢，新增、刪除或修改受管理物件一律走 `write`；版本化 migration callback 使用框架傳入的 `context`，由 stage 決定何時儲存。最外層入口限 Database 實作、Service 正式實作與版本化 migration callback；由這些入口發起並傳遞同一個 `context` 的 helper 互呼與內部 helper 也算 | `CategoryRecords.insert(name:in:)` |
| 框架或語言要求 | protocol 的型別成員要求（含 `GlobalActor.shared`）、運算子、`@TaskLocal`、`@main` 的 `main()`、`FormatStyle` 等點語法存取子 | `EnvironmentKey.defaultValue`、`DependencyKey.liveValue` |
| `os.Logger` | 非泛型型別的多個成員共用時寫 `private static let logger`；`subsystem` 用字面值或 `Bundle.main.bundleIdentifier ?? "固定字串"`，`category` 用字面值。泛型型別不能宣告 static stored property：有實例、型別能保存屬性，而且不會破壞 `Codable`、`Equatable` 等自動合成的遵循時，用 instance `private let logger`，否則寫區域 `let` | `Logger(subsystem: "com.example.app", category: "Sync")` |
| 測試支援 | 跨測試型別共用的 helper（`<TypeUnderTest>TestSupport`），以及 `@Test(arguments:)` 的資料與 Swift Testing trait 引用的設定函式（attribute 的引數沒有實例可用，可寫 `private static`）；不持有可變的 stored property，也不把持有可變狀態或外部資源的受測物件、測試替身存進 `static`，不可變的值可作為 `@Test(arguments:)` 的資料。只在單一測試型別的測試本體使用的 helper 寫 `private func`；沒有對應受測型別、跨測試型別共用的 helper 放 `Support/` 的主題命名空間，依 `file-templates.md` 的 `<TypeUnderTest>TestSupport` 一條。測試固定資料依 `file-templates.md` tests/Tests.swift 一節的「測試固定資料依使用範圍宣告」，該條優先於本表的「字面值常數」一列，例如不遵循 `Sendable` 的字面值在測試裡寫 `static func`，不寫 `static var`；讓多個測試共用同一次求值的唯讀結果（例如掃描原始碼目錄的結果）可寫 `private static let`，條件見同一條；受測物件的組裝規則見同一節 | `makeOrder(...)` |

字面值常數必須同時符合：

1. **值在寫程式時就確定**：只由字面值、系統提供的固定值、其他字面值常數，或以這些值呼叫初始化器的結果組成。初始化器可以是系統型別、第三方值型別或專案值型別的（包含自動合成的 memberwise init），但只能保存或純粹轉換引數；以 result builder 建構時，builder 與外層初始化器都只組合或純粹轉換固定資料才算。以立即執行的 closure 先建立值、再修改它的屬性（例如建立西曆後設定 `timeZone`）不算，需要 `static` 時依用途表改寫，測試支援寫 `static func`。初始化器內部會產生識別值的不算，例如 `AlertState`、`ConfirmationDialogState`、`ButtonState` 的 `init` 會呼叫 `UUID()`，每次建立的 id 都不同。`Date()`、`UUID()`、讀取 `ProcessInfo` 或檔案的結果都不算；呼叫專案自訂的 `static` 工廠也不算，即使引數全是字面值。正式程式碼裡供 Preview 與 snapshot 共用的範例資料（例如 `sampleOrders`）要求每次取得的結果相同，卻因初始化器的預設參數產生識別值（例如 `id: UUID = UUID()`）而不符合時，不保留 `static let` 讓同一次執行內的值不變，也不改成仍用預設參數的 getter 或工廠，改為傳入固定的識別值，讓結果只由參數決定：所在 target 依賴 swift-dependencies 時可用它公開的 `UUID(_:)`（例如 `UUID(1)`），只依賴 Foundation 的 target 用 `UUID(uuid:)` 傳入固定的 16 個位元組，兩者都不需要 `!`。之後仍不符合本條時（例如用了自訂 `static` 工廠），依用途表的「純函式與工廠」寫成 `static var` 唯讀 computed property。測試 target 的固定資料仍依 `file-templates.md` 的「測試固定資料依使用範圍宣告」與其四層規則檢查字面值三項條件；上述改寫成 `static var` 的做法只適用於正式程式碼裡供 Preview 與 snapshot 共用的範例資料，測試 fixture 同樣傳入固定識別值、不放隨機值（`project-structure.md` 的 Fixture）。
2. **值只是資料**：數值、字串、`URL`、`Color`、`CGSize` 這類值。Service、Client、Store、Database、closure 與其他會執行工作的物件都不算，即使它們是不可變的 `struct`。`os.Logger` 不走這三項條件，依上表的專屬條件判斷。
3. **寫死就是正確答案**：所有實例都用同一個值，不隨部署環境、帳號或遠端設定改變，測試也不需要換值。不符合時改由 init 參數傳入。

- **要**：語言、框架或本規範未明定時，宣告 `static` 前先走完判斷順序，再對照上表。不符合時先回答「誰持有它、活多久、在哪個隔離域、如何注入」，再依答案改成 instance 成員、`actor` 或 init 注入的 Service / Client / Store / Database。
- **要**：編譯錯誤不是改成 `static` 的理由。遇到 `self`、初始化順序、隔離或 `Sendable` 錯誤時同樣走判斷順序並對照上表，都符合才改，否則修正持有關係或隔離設計。
- **要**：`nonisolated static func` 同樣必須是純函式，並依「Actor 與隔離」加註解說明；資料存取 helper 依上表與 `file-templates.md` 的 `data/Records.swift`。
- **要**：`Logger` 只有一個函式使用時寫區域 `let`，protocol extension 也寫區域 `let`；需要驗證 log 內容時，把寫 log 的行為抽成可注入的依賴。
- **要**：`@TaskLocal static var` 的值以 `$name.withValue` 在作用域內綁定，不直接賦值；它不算下方禁止的可變 stored `static var`。預設值由所有未綁定的任務共用，需要每個作用域各自的可變物件時，預設值用 `nil`，進入作用域時再建立並綁定。
- **避免**：只因成員沒用到 `self`，或常數只是被多個 instance 成員共用，就改成 `static`；也不為了取得「沒有實例」的理由把成員搬進無 case 的 `enum`，包含型別內的 `Layout` 列舉。
- **避免**：`Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Sync")`，`bundleIdentifier` 不是字面值，不適用強制解包的例外。
- **避免**：可變的 stored `static var`，加上 `@MainActor` 也一樣。
- **避免**：`static let` 指向 actor、lock 或帶可變狀態的 `class` 實例，語言要求的 `GlobalActor.shared` 除外。改名為 `instance`、`current`、`default` 的單例，一樣視同 `.shared`。
- **避免**：`static func` 做網路、檔案、資料庫等 I/O、UI 測試的畫面操作，或讀寫共享狀態；這些工作放進 init 注入的型別，測試才能替換。錯誤轉換 helper 只執行呼叫端傳入的操作，資料存取 helper 只使用呼叫端傳入的 `context`，都不算違反；傳入整個資料庫物件再自行開啟交易仍然違反。
- **避免**：正式程式碼以 `static let`、`static var` 或 `static func` 建立、保存或回傳 Service、Client、Store、Database，包含 `ModelContainer`、`NSPersistentContainer` 等儲存容器，以及包著它們的值；依賴在 App 根部組裝，TCA 專案的儲存容器依 `tca-architecture.md` 的「Client、Store、Database」。框架要求的成員（例如 `liveValue`、`previewValue`、`testValue`）除外。

```swift
// 可以：`init` 賦值 `id` 時實例尚未建立完成，建立後的比對也要用同一段邏輯
/// 使用者的識別資訊
struct UserIdentity {

    // MARK: - Properties

    /// 統一格式後的識別碼
    let id: String

    // MARK: - Init

    /// 以伺服器給的識別碼建立
    ///
    /// - Parameter rawID: 伺服器給的原始識別碼
    init(rawID: String) {
        id = Self.normalizedID(from: rawID)
    }
}

// MARK: - Internal Method

extension UserIdentity {

    /// 判斷輸入的識別碼轉成小寫後是否與這位使用者相同
    ///
    /// - Parameter rawID: 要比對的識別碼
    /// - Returns: 屬於這位使用者時為 `true`
    func matches(_ rawID: String) -> Bool {
        id == Self.normalizedID(from: rawID)
    }
}

// MARK: - Private Method

private extension UserIdentity {

    /// 將識別碼轉成統一格式
    ///
    /// - Parameter rawID: 原始識別碼
    /// - Returns: 小寫的識別碼
    static func normalizedID(from rawID: String) -> String {
        rawID.lowercased()
    }
}

// 可以：常數只被 instance 方法共用，寫 instance `private let`
/// 標籤列的顯示規則
struct TagRowLayout {

    // MARK: - Properties

    /// 最多直接顯示的標籤數
    private let maximumVisibleCount = 3
}

// MARK: - Internal Method

extension TagRowLayout {

    /// 取出要直接顯示的標籤
    ///
    /// - Parameter tags: 全部標籤
    /// - Returns: 前幾個標籤
    func visibleTags(in tags: [String]) -> [String] {
        Array(tags.prefix(maximumVisibleCount))
    }

    /// 計算收進「更多」的標籤數
    ///
    /// - Parameter tags: 全部標籤
    /// - Returns: 未直接顯示的標籤數
    func hiddenCount(in tags: [String]) -> Int {
        max(tags.count - maximumVisibleCount, 0)
    }
}

// 可以：`Logger` 依專屬條件，同一型別的多個方法共用時寫 `private static let`
/// 回報同步進度
struct SyncReporter {

    // MARK: - Properties

    /// 同步流程的記錄器
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.example.app",
        category: "Sync"
    )
}

// MARK: - Internal Method

extension SyncReporter {

    /// 記錄同步開始
    func reportStart() {
        Self.logger.info("同步開始")
    }

    /// 記錄同步完成
    func reportFinish() {
        Self.logger.info("同步完成")
    }
}

// 可以：只使用呼叫端傳入的 `context`，是否提交由外層決定
/// 類別資料的讀寫操作
enum CategoryRecords {

}

// MARK: - Internal Method

extension CategoryRecords {

    /// 新增一筆類別
    ///
    /// - Parameters:
    ///   - name: 類別名稱
    ///   - context: 呼叫端已開啟的資料存取範圍
    static func insert(name: String, in context: ModelContext) {
        context.insert(CategoryRecord(name: name))
    }
}

// 避免：只有一個方法使用，寫成區域 `let` 即可
/// 搜尋關鍵字的檢查規則
struct SearchRule {

    // MARK: - Properties

    /// 關鍵字的最短長度
    private static let minimumLength = 2
}

// MARK: - Internal Method

extension SearchRule {

    /// 判斷關鍵字是否可以送出搜尋
    ///
    /// - Parameter keyword: 使用者輸入的關鍵字
    /// - Returns: 長度足夠時為 `true`
    func accepts(_ keyword: String) -> Bool {
        keyword.count >= Self.minimumLength
    }
}

// 避免：值不會再變，但它取決於第一次存取的時間，不是寫程式時就確定
/// App 的執行資訊
enum AppSession {

    // MARK: - Properties

    /// 第一次存取時的時間
    static let startDate = Date()
}

// 避免：無論寫成 `static let` 或工廠，都把正式依賴藏在型別裡，應在 App 根部組裝
/// 個人資料服務
struct ProfileService: Sendable {

    // MARK: - Properties

    /// 正式環境使用的實例
    static let live = ProfileService(client: URLSessionClient())

    /// 負責送出請求的依賴
    let client: any HTTPClientProtocol
}

// MARK: - Internal Method

extension ProfileService {

    /// 建立正式環境使用的實例
    ///
    /// - Returns: 連接正式網路的服務
    static func makeLive() -> ProfileService {
        ProfileService(client: URLSessionClient())
    }
}

// 避免：能編譯，但狀態沒有持有者，測試之間也會互相污染
/// 目前的登入狀態
@MainActor
enum Session {

    // MARK: - Properties

    /// 目前登入的權杖
    static var token: String?
}

// 避免：能編譯，但這是換了名字的單例，依賴被藏起來
/// 全 App 共用的權杖來源
enum TokenStorage {

    // MARK: - Properties

    /// 保存權杖的 `actor`
    static let store = TokenStore()
}

// 避免：能編譯，但 I/O 無法在測試替換，應放進 `init` 注入的依賴
/// 個人資料的下載入口
enum ProfileLoader {

}

// MARK: - Internal Method

extension ProfileLoader {

    /// 下載個人資料
    ///
    /// - Parameter url: 個人資料的位置
    /// - Returns: 伺服器回傳的原始內容
    /// - Throws: 網路失敗時丟出
    static func load(from url: URL) async throws -> Data {
        try await URLSession.shared.data(from: url).0
    }
}

// 避免：helper 自行提交，會連同 `context` 內其他待存變更一起寫入
/// 標籤資料的讀寫操作
enum TagRecords {

}

// MARK: - Internal Method

extension TagRecords {

    /// 新增一筆標籤並立刻寫入
    ///
    /// - Parameters:
    ///   - name: 標籤名稱
    ///   - context: 呼叫端已開啟的資料存取範圍
    /// - Throws: 寫入失敗時丟出
    static func insertAndSave(name: String, in context: ModelContext) throws {
        context.insert(TagRecord(name: name))
        try context.save()
    }
}

// 避免：只有一行的固定資料寫在各測試的區域 `let`，不合併成共用成員；自訂工廠也不算字面值常數
/// 費用規則的單元測試
struct FeeRuleTests {

    // MARK: - Properties

    /// 多個測試共用的費用項目
    private static let platformFee = FeeItem.fixture(name: "平台手續費")
}
```

## 函式拆分

- **要**：只在一處使用的小段邏輯留在原處，不抽成 helper：一兩行的計算寫在呼叫端，只被一個 computed property 使用的格式化直接寫在該 property 內。命名空間裡給畫面顯示的格式化 helper 不適用這句，依「命名空間以成員為單位判斷」改寫成 `FormatStyle`，不搬進呼叫端的 property 就地寫。
- **要**：行數只數本體非空白、非註解的行：函式與 local function 數 `{` 與 `}` 之間，TCA `core` 的 case 從標籤的冒號之後，數到同一個 `switch` 的下一個 `case`／`default` 標籤或該 `switch` 的 `}` 之前，巢狀 `switch` 的標籤不算；`return` 也算一行，以逗號共用一份本體的多個 pattern 只算一次；因排版換行的引數與運算式照實際行數計算，包含 closure 依 `formatting.md` 必須寫成多行而展開的行（例如位在另一個 closure 內的 `#Predicate { }`）。
- **要**：有自己的輸入與輸出、本體達 15 行的獨立演算法，才抽成同型別的 private 方法，不寫成 local function（寫在使用它的函式內的 `func`）。
- **要**：重複使用的邏輯依範圍決定。由多個方法或 computed property 共用時，可抽成同型別的 private 方法，不受 15 行門檻限制。只在同一函式內重複時：本體一兩行的運算式不抽 helper，各處共用同一次計算結果時寫區域 `let`，各處需要分別求值時直接寫在各處；3 行以上的抽成同型別的 private 方法，只有需要捕捉外層區域變數、本體未達 15 行時才寫 local function。
- **要**：local function 只用於上一條的情況；不在 local function 內再宣告 local function，也不讓它逃逸。local function 讀取 class 的 instance 成員時不需要寫 `self.`，逃逸後會隱藏對 `self` 的強持有。
- **要**：`init` 同樣適用本節。例外是以 early return 算出 stored property 初始值的 helper：`init` 在 stored property 全部賦值前不能提早 `return`，寫回 `init` 得改成巢狀 `if let`，所以可以留成 private 方法；這時實例尚未建立完成，依「`static` 的使用時機」寫 `static`。
- **要**：View 的子 View 依 `file-templates.md` 的「`body` 只放大框架」抽取，不看行數；View 為了不在 `body` 宣告區域變數而抽出的成員（例如只用一次、回傳 `Binding` 的 computed property）比照子 View；TCA `core` 的 case 超過十行時依 `tca-architecture.md` 抽成 Private Method；TCA 中建構 `Destination` alert、confirmationDialog case 的方法依 `tca-architecture.md` 一律寫在 `extension <Screen>Feature.Destination.State`；樣板明定要獨立宣告的方法（例如 UI 測試的 `launchApp()`）照樣板寫。這些都不套用本節「只在一處使用就留在原處」與行數門檻的規定。
- **避免**：只被呼叫一次、只有幾行的 private helper，讀者得跳到別處才看得懂原本那一段。

```swift
// Bundle 的擴充：只被這個 property 使用的格式化，直接寫在 property 內，不另抽 helper
/// App 的版本號與建置編號，例如「1.2.0 (45)」
var appVersion: String {
    let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    let build = infoDictionary?["CFBundleVersion"] as? String ?? "-"
    return "\(version) (\(build))"
}
```

## Optional 處理

- **要**：`guard let` 優先於 `if let`：需要提早離開的用 `guard let`，只有在 nil 時仍要繼續執行後續邏輯，或 nil 時要執行業務邏輯（見下一句）才用 `if let`。`guard` 的 `else` 只放 `return`、`throw`、`continue`、`break`，不放其他邏輯；離開前先記錄警告或 log 不算其他邏輯，禁止的是業務邏輯，例如改變狀態、呼叫 Service。寫在 `return` 運算式裡也一樣：`return submitEdit(state: &state)` 這類會改變狀態或呼叫 Service 的呼叫，表示兩個分支都有業務邏輯，改用 `if let` / `else`（非 Optional 的條件用 `if` / `else`）。TCA reducer 的 `else` 可以 `return` 三種結束流程的 Effect：`.none`、向父層送出的 `.send(.delegate(...))`、關閉畫面的 `.run { _ in await dismiss() }`，也可以呼叫只回傳這三種 Effect、不帶 `inout` 參數的方法；這是 reducer 離開時的回傳值，和 `throw` 同類。送回本 Feature 或子 Feature 的 action（例如 `.send(.view(...))`、`.send(.loadResponse(...))`）、`.cancel(id:)` 與其他 `.run`，都不是結束流程，仍算業務邏輯。
- **要**：同名解包用簡寫 `guard let profile`、`if let profile`，不寫 `guard let profile = profile`。
- **要**：多個 Optional 用逗號串在同一個 `guard let` / `if let`，巢狀不超過一層。
- **要**：optional chaining 最多兩層（`user?.profile?.avatar`），更深就先 `guard let` 拆開，否則 nil 的來源無法辨識。
- **要**：`??` 只給真正有合理預設的情況（空字串、空陣列、0），不用它掩蓋應該視為錯誤的 nil。
- **要**：函式失敗有原因時 `throws`；只有「不存在」是正常結果時才回傳 Optional（`first(where:)`、`dictionary[key]`）。
- **要**：三態用 enum 表達，不用 `Bool?`。
- **避免**：`.none`，一律寫 `nil`。
- **避免**：隱式解包 Optional（`String!`），`IBOutlet` 例外。XCTest 在 `setUp` 才建立的屬性也不例外，UI 測試的 `XCUIApplication` 改法見 `file-templates.md` 的 tests/UITests.swift 一節。
- **避免**：`try!` 與 `as!`，無例外；`as!` 的轉型需求改用泛型 helper 或 `as?` 加 `guard let`。

### 強制解包 `!` 的唯一例外

**只允許在 `!` 左側的表達式完全由字面值組成、沒有任何變數參與時使用**，因為輸入固定，確認字面值有效後，執行期就不會是 nil。判斷標準是機械的：表達式裡有變數就禁止。字面值本身也要確認有效，例如時區識別字拼錯時，`TimeZone(identifier:)` 會回傳 nil；成功與否還取決於 App 打包內容或裝置上是否有某項資源的 API（例如 `Bundle(identifier:)`）不適用這個例外。允許時在同一行或上一行加註解說明是字面值常數。

- **要**：有非 Optional 的替代 API 就用替代，沒有才用字面值加 `!`：正規表達式用 `/\d+/` 字面值而非 `NSRegularExpression(pattern:)!`；SwiftUI 用 `Image("name")`、`Color("name")` 而非 `UIImage(named:)!`；`TimeZone.gmt`、`Locale.current` 這類靜態屬性優先。
- **要**：允許的例外只在 `static let` 常數或測試 fixture 出現，不在一般方法內。
- **避免**：對 `IBOutlet` 以外的隱式解包、對含變數的表達式、對 `try` 與 `as` 使用 `!`。

```swift
// 允許：全是字面值，輸入固定且已確認有效
/// App 內寫死的固定值
enum FixedValues {

    // MARK: - Properties

    /// 官方網站的網址
    static let siteURL = URL(string: "https://www.example.com")!  // 字面值常數

    /// 稅率，5%
    static let taxRate = Decimal(string: "0.05")!                 // 字面值常數

    /// 顯示時間時使用的時區，固定台北
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
- **避免**：空的 `catch {}`，以及只 `print` 不處理的 `catch`。只有註解的 `catch` 也算空的：錯誤確實可以忽略時改用 `try?`，並在同一行附上理由（見上方 `try?` 的規則），不能忽略就要處理。`catch` 內有實際敘述（例如只有 `return`）就不算空的。
- **避免**：`fatalError` / `precondition` 用於執行期可能發生的狀況；它們只用於違反程式不變量的邏輯錯誤，也就是程式或測試本身寫錯，例如 Preview 假資料或測試環境無法建立、測試替身注入的錯誤和 closure 的 typed throws 型別不符。呼叫前一行用 `//` 寫明為什麼無法繼續。

```swift
// Service：typed throws，包裝底層錯誤
/// 從伺服器取得個人資料的正式實作
struct ProfileService {

    /// 實際發出網路請求的物件
    private let client: any APIClientProtocol
}

// MARK: - ProfileServiceProtocol

extension ProfileService: ProfileServiceProtocol {

    /// 每次都向伺服器抓取，不做快取；伺服器與解析錯誤都轉成 `ProfileError`
    ///
    /// - Parameter id: 使用者識別碼
    /// - Returns: 伺服器回傳的最新個人資料
    /// - Throws: 資料格式不符丟 `.decoding`，其餘連線問題丟 `.network`
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
/// 載入個人資料並更新畫面狀態；被取消時不改變狀態
func load() async {
    state = .loading
    do {
        let profile = try await profileService.fetchProfile(id: userID)
        state = .loaded(profile)
    } catch {
        guard !Task.isCancelled else {
            return
        }
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
- **要**：`nonisolated` 只用於 `@MainActor` 型別內確實不碰狀態的純函式，且加註解說明。唯一例外是預設隔離為 `MainActor` 的 target 內的 `<Name>Records`，見 `file-templates.md` 的 `data/Records.swift`。
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
/// 首頁儀表板要顯示的資料與載入動作
@MainActor
@Observable
final class DashboardViewModel {

    // MARK: - Properties

    /// 目前使用者的個人資料，尚未載入時為 nil
    private(set) var profile: Profile?

    /// 目前使用者的訂單，尚未載入時為空
    private(set) var orders: [Order] = []

    /// 取得個人資料的物件
    private let profileService: any ProfileServiceProtocol

    /// 取得訂單的物件
    private let orderService: any OrderServiceProtocol

    /// 正在進行的載入工作，重新載入前先取消它
    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    // ...
}

// MARK: - Internal Method

extension DashboardViewModel {

    // async let 並行兩個獨立請求
    /// 同時載入個人資料與訂單，兩者都完成後才更新畫面；被取消時不更新
    func load() async {
        do {
            async let profile = profileService.fetchProfile(id: userID)
            async let orders = orderService.fetchOrders(customerID: userID)
            self.profile = try await profile
            self.orders = try await orders
        } catch {
            guard !Task.isCancelled else {
                return
            }
            // 轉成 State.failed
        }
    }

    // 重複觸發前取消上一次
    /// 重新載入；上一次還沒完成的話先取消，避免舊結果蓋掉新結果
    func reload() {
        loadTask?.cancel()
        loadTask = Task { await load() }
    }

    // 系統通知用 AsyncSequence 消費，不用 Combine
    /// 每次 App 從背景回到前景就重新載入一次，直到所在的 Task 被取消
    func observeForeground() async {
        for await _ in NotificationCenter.default.notifications(
            named: UIApplication.willEnterForegroundNotification
        ) {
            await load()
        }
    }
}

// View：兩個獨立的 .task，隨 View 消失自動取消
/// 儀表板畫面骨架：顯示時載入資料並開始監聽回前景事件
var body: some View {
    content
        .task {
            await viewModel.load()
        }
        .task {
            await viewModel.observeForeground()
        }
        .refreshable {
            viewModel.reload()
        }
}
```

## 註解與 Doc Comment

### Doc Comment（`///`）

- **要**：**所有宣告一律有 `///`，沒有例外**，不分存取層級：型別、protocol 與其每個要求、extension 內的每個方法與 computed property、stored property、enum 的每個 case、nested type、`private` 成員、測試方法、protocol 遵循 extension 內的實作。
- **要**：protocol 要求與其實作**兩邊都寫**，但內容不同：protocol 上寫「做什麼、呼叫端能期待什麼」；實作上寫「這個實作怎麼做」，例如資料來源、有無快取、平台限制、與其他實作的差異。實作端不複製 protocol 的句子。
- **要**：第一行一句話摘要，句末不加句號。摘要超過 100 字元時先精簡；精簡後仍超過，就在下一行 `///` 接著寫，中間不空行，DocC 仍視為同一段摘要。方法、函式、`init` 說明「做什麼」，動詞開頭：省略主詞，從這個宣告做的動作寫起，動作前可以先寫方式或時機（「依識別碼取得個人資料」「每個測試前以假資料模式啟動 App」）；測試方法一律以「驗證」開頭，見 `file-templates.md` 的 tests/Tests.swift 一節。型別、屬性、`case` 說明「這是什麼」，不受動詞開頭限制：型別說明職責與使用時機；屬性寫成名詞片語（「唯一識別碼」「顯示給使用者看的名稱」），`Bool` 屬性用「是否」問句（「是否已付款」），裝 closure 的屬性（TCA Service 的操作）視同方法、動詞開頭；`case` 寫它代表的情況（「使用者中途放棄」）。
- **要**：摘要後空一行，依序寫 `- Parameter x:`（單一參數）或 `- Parameters:`（多個參數，每個一行縮排）、`- Returns:`、`- Throws:`。**有參數就一定寫參數、有回傳值就一定寫回傳、會 throw 就一定寫 Throws**，不因名稱已清楚而省略；`Throws` 寫出哪些情況丟哪個 case。
- **要**：`init` 一律有摘要，說明建立出來的東西是什麼、需要什麼；參數依上一條寫。
- **要**：enum case 帶 associated value 時，每個 value 都以 `- Parameter` / `- Parameters:` 說明，寫法與函式參數相同；沒有 label 的 value 以型別名稱小寫作為名稱（`- Parameter profile:`）。
- **要**：摘要與參數之外還需要補充時用 `- Note:`，放在 `- Throws:` 之後；一個 `- Note:` 講一件事，例如使用前提、效能特性、與其他方法的關係、平台限制。不用自由段落補充，也不用 `- Important:`、`- Warning:`、`- Remark:` 等其他標記。
- **要**：正體中文，技術名詞、型別名、識別字保留英文。只有程式碼識別字（型別、成員、關鍵字、檔名）加反引號；sheet、alert、reducer、iPad 這類一般概念詞不加，即使它們是英文。`//` 註解同樣適用。
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
/// 向伺服器讀取與更新使用者個人資料的唯一入口
protocol ProfileServiceProtocol: Sendable {

    /// 依識別碼取得個人資料；最近抓過就用上次的，不再連網路
    ///
    /// - Parameter id: 要查詢的使用者識別碼
    /// - Returns: 該使用者的個人資料
    /// - Throws: 找不到使用者丟 `ProfileError.notFound`；網路連不上丟 `ProfileError.network`
    /// - Note: 快取保留五分鐘，要強制重抓請先呼叫 `invalidateCache()`
    func fetchProfile(id: UserID) async throws(ProfileError) -> Profile
}

/// 個人資料畫面要顯示什麼、按鈕按下後做什麼，都由它決定
@MainActor
@Observable
final class ProfileViewModel {

    // MARK: - Properties

    /// 畫面目前處於未開始、載入中、完成或失敗哪一種，決定顯示內容
    private(set) var state: State = .idle

    /// 實際去拿個人資料的物件，測試時換成假的以免連網路
    private let profileService: any ProfileServiceProtocol

    // MARK: - Init

    /// 建立個人資料畫面的 ViewModel，初始狀態為未開始
    ///
    /// - Parameter profileService: 實際去拿個人資料的物件
    init(profileService: any ProfileServiceProtocol) {
        self.profileService = profileService
    }
}

// MARK: - Private Method

private extension ProfileViewModel {

    /// 把內部錯誤翻譯成使用者看得懂的一句話，所有錯誤都顯示同一句通用訊息
    ///
    /// - Parameter error: 載入個人資料時發生的錯誤
    /// - Returns: 可直接顯示在畫面上的文案
    func message(for error: ProfileError) -> String {
        // iOS 17 的 String(localized:) 在 Preview 內不會套用 bundle，故明確指定
        String(localized: "profile.unavailable", bundle: .main)
    }
}
```

## 常見錯誤檢查清單

- [ ] 命名：`Manager` / `Handler` / `Provider` 用在不符本意的型別、`Helper` / `Util` 後綴、`get` 前綴、否定式 `Bool`、以型別當後綴（`userArray`）、`Id` 而非 `ID`、泛型用單字母
- [ ] 存取控制：成員未從 `private` 起手、明寫 `internal`、出現 `fileprivate`、為測試放寬存取層級、屬性包裝與存取控制順序顛倒
- [ ] 型別：`class` 未加 `final`、不打算被覆寫的型別成員寫 `class` 而非 `static`、可變共享狀態用 `class` 加 lock 而非 `actor`、`typealias` 給基本型別取別名、tuple 跨函式邊界、只有一個實作卻定義 protocol
- [ ] `static`：語言、框架或本規範未要求，卻在可直接寫、寫成區域 `let` 或 instance 成員時用 `static`（包含只被 instance 成員共用的常數，以及包成型別內 `Layout` 列舉的常數）；型別無法或不宜保存 instance 常數，卻仍寫成 instance `let`，導致自動合成的遵循、編碼輸出或持久化欄位改變；常數型別不遵循 `Sendable` 時為了寫成 `static let` 改成 `& Sendable`；收納共用函式的命名空間內，有只被一個型別呼叫，或沒有任何呼叫端的成員（範圍與例外都見「命名空間以成員為單位判斷」）；唯一呼叫端是 View 時，業務邏輯被搬進 View，或純 UI 計算被搬進 `State`、ViewModel；給畫面顯示的格式化 helper 留在命名空間而沒有改寫成 `FormatStyle`；只因沒用到 `self` 就改成 `static`、不符合使用時機表、只為消除編譯錯誤才改成 `static`、用途是字面值常數卻不符合三項條件（自訂 `static` 工廠不算字面值）、以 `static` 寫死會隨環境或測試改變的值、`Logger` 不符合專屬條件或 `subsystem` 用 `!`、可變的 stored `static var`（`@TaskLocal` 宣告不算）、`static let` 指向 actor、lock 或帶可變狀態的 `class`（`GlobalActor.shared` 除外）、`static func` 本身發起 I/O 或讀寫共享狀態（錯誤轉換 helper 執行傳入的操作、資料存取 helper 使用傳入的 `context` 不算）、資料存取 helper 自行取得依賴、開啟交易、保存 `context`、呼叫 `save()` 或在 `read` 範圍內修改資料、正式程式碼以 `static let`、`static var` 或 `static func` 建立、保存或回傳 Service、Client、Store、Database，或 `ModelContainer` 等儲存容器與包著它們的值（框架要求的成員除外）；正式程式碼裡供 Preview 與 snapshot 共用、要求每次結果相同的範例資料，仍用會產生識別值的預設參數（不論寫成 `static let`、getter 或工廠），而非改傳固定識別值
- [ ] 函式拆分：只在一處使用、只有幾行的邏輯抽成 helper（本規範或樣板明定要獨立宣告的方法除外，例如 `Destination` 的 alert 建構方法、UI 測試的 `launchApp()`；`init` 以 early return 算出初始值的 helper、View 為了不在 `body` 宣告區域變數而抽出的成員也不算）；本體達 15 行的獨立演算法沒有抽出，或抽成 local function；local function 沒有捕捉外層區域變數、本體達 15 行、巢狀或逃逸；同一函式內重複的一兩行運算式另抽 helper，或 3 行以上的邏輯既沒有抽成 private 方法，也不是符合條件的 local function；行數含宣告行、空行或註解，或排版換行的運算式只算一行
- [ ] Optional：`if let` 用在該提早離開、nil 時又沒有業務邏輯的地方、`guard` 的 `else` 內有業務邏輯（離開前記錄 log 不算；`return` 會改變狀態或呼叫 Service 的呼叫也算業務邏輯，TCA 回傳 `.none`、`.delegate`、`dismiss` 三種結束流程的 Effect 不算）、optional chaining 超過兩層、`??` 掩蓋錯誤、`Bool?`、`Optional` 寫 `.none` 而非 `nil`（TCA 的 `Effect.none` 不算）
- [ ] 強制解包：`!` 左側含變數、`try!`、`as!`、`IBOutlet` 以外的隱式解包、字面值 `!` 出現在一般方法內而非 `static let` 或測試 fixture、字面值 `!` 的成功與否取決於 App 打包內容或裝置資源（例如 `Bundle(identifier:)`）
- [ ] Error：全域 `AppError`、Error 帶 raw value、Service 方法未用 typed throws、Service 外洩 `URLError` / `DecodingError`、`catch` 子句分散而非通用 `catch` 內 `switch`
- [ ] Error：`try?` 用在主要資料讀寫或必要欄位、`try?` 未附「失敗可忽略」註解、空的 `catch`（含只有註解的）、只 `print` 的 `catch`、`CancellationError` 顯示給使用者、`fatalError` 用於執行期狀況或呼叫前沒有 `//` 說明原因
- [ ] Concurrency：completion handler、自建 Combine pipeline、`DispatchQueue`、`Thread.sleep`、可並行的請求循序 `await`
- [ ] Concurrency：`@MainActor` 標在方法而非型別、Service / Model 標 `@MainActor`、`@unchecked Sendable` 壓警告、`nonisolated(unsafe)`、`DispatchQueue.main.async`
- [ ] Task：`Task.detached`、`init` 內建 Task、可重複觸發的 Task 未持有與取消、`catch` 內未先檢查 `Task.isCancelled`
- [ ] 註解：任何宣告缺 `///`（含 `private`、`case`、`init`、protocol 實作）、有參數缺 `- Parameter`、有回傳缺 `- Returns`、會 throw 缺 `- Throws`、associated value 缺 `- Parameter`
- [ ] 註解：方法的摘要不是動詞開頭、測試方法的摘要不是以「驗證」開頭、摘要未先精簡就換行，或換行時中間空行、術語與縮寫、複述名稱、冗言贅字、實作端複製 protocol 的句子、`// TODO` 沒有 issue 編號、被註解掉的程式碼、複述程式碼的 `//`、一般概念詞（sheet、alert、iPad）加了反引號
