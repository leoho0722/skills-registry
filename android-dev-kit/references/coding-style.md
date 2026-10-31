# Coding Style（命名與語意慣例）

Leo Ho 個人 Kotlin / Android 開發規範。所有規則以下列官方文件為依據，本檔只在官方允許的範圍內做選擇或加嚴，不與官方牴觸：

- Kotlin：[Coding conventions](https://kotlinlang.org/docs/coding-conventions.html)、[KDoc](https://kotlinlang.org/docs/kotlin-doc.html)
- Google：[Android Kotlin style guide](https://developer.android.com/kotlin/style-guide)、[App architecture](https://developer.android.com/topic/architecture)、[Coroutines best practices](https://developer.android.com/kotlin/coroutines/coroutines-best-practices)
- Compose：[Compose API guidelines](https://android.googlesource.com/platform/frameworks/support/+/androidx-main/compose/docs/compose-api-guidelines.md)

兩份官方文件說法不同時，以 Google 的 Android Kotlin style guide 為準。排版見 `formatting.md`，本檔的範例皆已依其排版。

## 目錄

- [命名](#命名)
  - [型別與 interface](#型別與-interface)
  - [泛型](#泛型)
  - [變數、屬性與常數](#變數屬性與常數)
  - [函式與方法](#函式與方法)
  - [Composable](#composable)
  - [enum entry 與 sealed 子型別](#enum-entry-與-sealed-子型別)
  - [檔名、package 與資源](#檔名package-與資源)
- [存取控制](#存取控制)
- [型別選擇](#型別選擇)
- [函式拆分](#函式拆分)
- [Extension](#extension)
- [Null Safety](#null-safety)
- [Error Handling](#error-handling)
- [Concurrency](#concurrency)
- [註解與 KDoc](#註解與-kdoc)
- [常見錯誤檢查清單](#常見錯誤檢查清單)

## 命名

### 型別與 interface

- **要**：型別 UpperCamelCase，用名詞；interface 用名詞或形容詞（`ProfileRepository`、`Refreshable`），不加 `I` 前綴或 `Impl` 後綴。
- **要**：角色後綴依 Android 架構指南的命名慣例：

  | 角色 | 命名 | 例子 |
  |---|---|---|
  | 畫面 | `<Screen>Screen`、`<Screen>ViewModel`、`<Screen>UiState`、`<Screen>NavKey` | `ProfileScreen`、`ProfileViewModel` |
  | Repository | `<資料類型>Repository` | `ProfileRepository`、`OrderRepository` |
  | Data source | `<資料類型><來源>DataSource`，來源用 `Remote` / `Local`；來源本身很重要時用 `Network` / `Disk` | `ProfileRemoteDataSource`、`ProfileLocalDataSource` |
  | Room | `<App>Database`、`<資料類型>Dao`、`<資料類型>Entity` | `AppDatabase`、`ProfileDao` |
  | UseCase | `<動詞><名詞>UseCase` | `GetProfileUseCase`、`PlaceOrderUseCase` |
  | 錯誤 | `<資料類型>Error` | `ProfileError` |
  | 顯示格式 | `<Name>Formatter` | `RelativeDateFormatter` |
  | Hilt module | `<主題>Module` | `DataModule`、`NetworkModule` |
  | 測試 | `<TypeUnderTest>Test`（過大時拆成 `<TypeUnderTest><行為>Test`）、`<Screen>ScreenTest`、`<流程>UiTest`；共用 helper `<TypeUnderTest>TestSupport`；測試替身 `Fake<Name>` | `ProfileViewModelTest`、`ProfileViewModelRetryTest`、`ProfileViewModelTestSupport`、`FakeProfileRepository` |

- **要**：interface 的實作取有意義的名稱，說明它和其他實作的差異（`OfflineFirstProfileRepository`、`RetrofitProfileRemoteDataSource`、`InMemoryCartRepository`）；找不到更好的名稱時才用 `Default` 前綴（`DefaultProfileRepository`）。
- **要**：data source 不以實作細節命名：`ProfileLocalDataSource` 而非 `ProfileSharedPreferencesDataSource`，Repository 不該知道資料怎麼存；實作 class 才帶技術名稱。
- **避免**：`Manager`、`Wrapper`、`Helper`、`Util` 這類沒有意義的字（Kotlin 官方：avoid using meaningless words）。改用說明職責的具體名詞：`DownloadQueue`、`ConnectionPool`；共用函式寫成 extension 或收進以主題命名的 `object`；測試共用的 helper 收進 `<TypeUnderTest>TestSupport`（`file-templates.md` 的 tests/Test.kt 一節）。
- **避免**：型別名前綴（`LhProfile`），Kotlin 有 package 命名空間。

### 泛型

依 Android Kotlin style guide：型別參數用單一大寫字母（`T`、`E`、`K`、`V`，可加數字 `T2`），或類別名稱加 `T`（`RequestT`、`ValueT`）。

- **要**：只有一兩個型別參數且角色一目了然時用單一字母：`Outcome<T, E>`、`Map<K, V>`。
- **要**：需要表達角色時用 `<名稱>T`：`fun <InputT, OutputT> convert(...)`。
- **避免**：與標準函式庫型別同名的型別參數（`Error`、`Result`），會遮蔽原本的型別。

### 變數、屬性與常數

- **要**：lowerCamelCase；依角色而非型別命名，集合用複數：`users` 而非 `userList`。
- **要**：`Boolean` 用 `is` / `has` / `can` / `should` 開頭的肯定斷言：`isLoading`、`hasUnreadMessages`、`canSubmit`；避免否定式（`isDisabled` 改用 `isEnabled`）。
- **要**：縮寫依 Android 的 camel case 規則，把整個片語轉成一般的字再組合：`customerId`、`baseUrl`、`parseJson`、`HttpClient`、`UiState`；不寫 `customerID`、`HTTPClient`。
- **要**：值是純量（數字、字串、`Boolean`）的常數一律 `const val`。`const val`，以及 top-level 或 `object` 內、內容深度不可變（deeply immutable）且沒有自訂 getter 的 `val`，用 SCREAMING_SNAKE_CASE：`private const val MAX_RETRY_COUNT = 3`。只是「打算不改」不算不可變，`List` 裡放可變物件也不算。
- **要**：持有單例物件參考的屬性可以用 `object` 的命名方式；`CompositionLocal` 依 Compose 慣例命名 `Local<Name>`（`LocalSpacing`）。
- **要**：對外唯讀、內部可變的狀態，優先用 explicit backing field（Kotlin 2.4 起穩定）：

  ```kotlin
  /** 畫面目前的狀態，只有自己能改。 */
  val uiState: StateFlow<ProfileUiState>
      field = MutableStateFlow<ProfileUiState>(ProfileUiState.Loading)
  ```

  專案的 Kotlin 版本低於 2.4 時，改用官方的 backing property 寫法：私有屬性加底線前綴 `_uiState`，對外的 `uiState` 回傳唯讀型別。
- **避免**：`k` / `m` 前綴（`kMaxRetry`、`mName`）；單字母變數，只有數學公式與極短的 lambda 例外。

### 函式與方法

- **要**：動詞開頭：`fetchProfile(id)`、`insert(item, index)`；有副作用的用祈使動詞（`sort()`），回傳新值的用過去分詞或形容詞（`sorted()`），轉型用 `to` 前綴（`toProfile()`），取得檢視用 `as` 前綴（`asFlow()`）。
- **要**：沒有參數、沒有副作用、計算便宜且每次結果相同的取值寫成屬性（`val isEmpty`）；否則寫成函式。
- **要**：ViewModel 處理使用者事件的方法依「做什麼」命名，不依 UI 手勢命名：`retry()`、`updateName(name)`、`saveProfile()`，不寫 `onRetryClick()`；ViewModel 不該知道 UI 的實作細節。
- **避免**：`get` 前綴（`getProfile()` 改 `profile` 屬性或 `fetchProfile()`），Repository 的串流例外（官方寫法 `getProfileStream()`）；`do`、`handle`、`process` 這類不說明做了什麼的動詞。

### Composable

- **要**：回傳 `Unit` 的 `@Composable` 函式一律 UpperCamelCase 名詞，不論有沒有畫出 UI：`ProfileScreen`、`Header`、`EmptyState`；不加 `Composable`、`View` 後綴。
- **要**：有回傳值的 `@Composable` 函式用 lowerCamelCase，依一般函式命名；建立並記住狀態持有者的固定 `remember` 前綴：`rememberNavigator()`。
- **要**：事件 lambda 參數以 `on` 開頭，接事件的描述：`onRetryClick`、`onNameChange`、`onBackClick`。
- **要**：同一畫面的有狀態與無狀態版本同名（overload），見 `file-templates.md` 的 Screen 一節。

### enum entry 與 sealed 子型別

- **要**：enum entry 與 sealed 子型別一律 UpperCamelCase：`OrderStatus.Pending`、`ProfileUiState.Loading`。Kotlin 官方允許 UpperCamelCase 或 SCREAMING_SNAKE_CASE 二選一，本規範統一前者，狀態從 enum 改成 sealed 時不用改名。
- **要**：不重複型別名（`Direction.North` 而非 `Direction.DirectionNorth`）。
- **要**：sealed 子型別沒有資料時用 `data object`，有資料時用 `data class`。

### 檔名、package 與資源

- **要**：檔案只有一個頂層型別時，檔名與型別同名；包含多個頂層宣告時，檔名描述內容（`ProfileScreen.kt` 含有狀態與無狀態兩個 `ProfileScreen`）。
- **要**：package 全小寫、不含底線，多個字直接連寫：`com.example.app.feature.editprofile`。
- **要**：字串資源 snake_case，依 `<feature>_<用途>` 命名：`profile_title`、`profile_error_unavailable`；全 App 共用的加 `common_` 前綴（`common_retry`）。圖示 `ic_<名稱>`。

## 存取控制

- **要**：成員預設 `private`，只在有外部使用者時放寬，且放寬到剛好夠用的層級。
- **要**：外部要讀、只有自己改的狀態，對外只暴露唯讀型別（`StateFlow` 而非 `MutableStateFlow`、`List` 而非 `MutableList`），寫法見上面的 explicit backing field。
- **要**：只給同一檔案用的 composable、函式與常數寫成 top-level `private`；只給同一型別用的輔助型別寫成 nested type。
- **要**：方案 B、C 的 library module 內，不屬於 module 對外 API 的宣告一律 `internal`；方案 A 的單一 `:app` 不寫 `internal`，它等同 `public`。
- **要**：annotation 在前、修飾字在後：`@Inject lateinit var`、`@IoDispatcher private val ioDispatcher`。
- **避免**：明寫 `public`，它是預設；唯一例外是 module 開啟 `explicitApi()` 時，依 Kotlin library 慣例一律明寫。
- **避免**：為了測試放寬存取層級；`private` 的東西透過公開行為驗證。

## 型別選擇

- **要**：資料用 `data class`，屬性一律 `val`，修改用 `copy()`。
- **要**：`class` 預設即 final，`open` 只給刻意設計要被繼承的 class，並以 KDoc 說明可覆寫的點。
- **要**：命名空間與無狀態的工具用 `object`；與某型別綁定的常數或工廠方法才放 `companion object`。
- **要**：有限且不帶資料的選項用 `enum class`；互斥且帶資料的狀態用 `sealed interface`，子型別需要共用狀態時才用 `sealed class`。
- **要**：需要語意上不同的識別碼或單位時用 `@JvmInline value class`，底層值的屬性叫 `value`：`value class UserId(val value: String)`。
- **要**：interface 只在有第二個實作或需要 Fake 時定義。Repository 與遠端 data source 一律有 interface（測試以 Fake 取代）；UseCase、ViewModel 用具體 class，測試時替換它們的依賴。
- **要**：有可變狀態且會被多個 coroutine 同時存取時，用 `Mutex`（`withLock`）或 `MutableStateFlow.update { }` 保護。
- **避免**：`typealias` 給基本型別取別名（`typealias UserId = String`），它不提供型別安全；`typealias` 只用於縮短長的函式型別或泛型簽章。
- **避免**：`Pair` / `Triple` 跨越函式邊界，改用有名稱的 `data class`。
- **避免**：`synchronized`、`@Volatile` 保護業務狀態，它們不能跨 `suspend` 點持有。

## 函式拆分

- **要**：只在一處使用的小段邏輯留在原處，不抽成 helper：一兩行的計算寫在呼叫端，只被一個屬性的 `get()` 使用的格式化直接寫在該屬性內。
- **要**：有自己的輸入與輸出、約 15 行以上的獨立演算法，才抽成函式或 local function（寫在使用它的函式內的 `fun`）。被兩處以上使用的邏輯不受本節限制。
- **要**：Screen 的子 composable 依 `formatting.md` 的「Compose 排版」抽取，不看行數，不套用本節的門檻。
- **避免**：只被呼叫一次、只有幾行的 `private` helper，讀者得跳到別處才看得懂原本那一段。

```kotlin
/** App 的版本名稱與版本碼，例如「1.2.0 (45)」。 */
val PackageInfo.displayVersion: String
    get() {
        val name = versionName ?: "-"
        val code = PackageInfoCompat.getLongVersionCode(this)
        return "$name ($code)"
    }
```

## Extension

依 Kotlin 官方：「Use extension functions liberally」，但「Avoid creating files just to hold all extensions of some class」。

- **要**：一個函式主要在處理某個物件時，考慮寫成它的 extension，並盡量限制可見度。
- **要**：只有某處用得到的 extension，寫成 `private`，放在使用它的程式碼旁邊。
- **要**：多個 Feature 共用的 extension 放 `core/` 下對應主題的 package，檔名描述功能（`InstantRelativeTime.kt`、`FlowRetry.kt`）。
- **要**：跨層的轉換函式寫成 extension，放在轉換結果那一層：`fun ProfileEntity.asExternalModel(): Profile` 放 data 層。
- **避免**：為了收納某個型別的所有 extension 而建立 `<Type>Extensions.kt`。

## Null Safety

- **要**：需要提早離開時用 `?: return`；`?:` 右側只放 `return`、`throw`、`continue`、`break`。
- **要**：null 時仍要繼續執行後續邏輯才用 `if (value != null)`，靠 smart cast 使用。
- **要**：`?.let { }` 只用於單一表達式的轉換或呼叫；不串成 `?.let { } ?: run { }` 取代 `if` / `else`。
- **要**：safe call 最多串兩層，更深就先用 `?: return` 拆開。
- **要**：`?:` 給預設值只用在真正有合理預設的情況（空字串、空清單、0）。
- **要**：集合一律回傳空集合，不回傳 null；三態用 `enum class` 或 `sealed interface`，不用 `Boolean?`。
- **要**：呼叫 Java API 取得的值（platform type）立刻指定明確的 Kotlin 型別。
- **要**：`lateinit` 只用於 Kotlin 官方列出的兩種情況：依賴注入（Hilt 在 Android entry point 的 field injection），以及測試的 `@Before` setup。
- **避免**：`!!`，沒有例外；有非 null 的替代 API 就用替代（`toHttpUrl()`、`Regex(...)`），值照程式邏輯不可能是 null 時用 `checkNotNull(value) { "原因" }`。
- **避免**：不安全轉型 `as`，一律 `as?` 加 `?: return`。

## Error Handling

Android 架構指南的資料層有兩種表達錯誤的方式：丟出自訂例外，或「use a Result class」。本規範採後者，以 `core/common/Outcome.kt`（`Outcome<T, E>`）讓呼叫端從型別知道會拿到哪種錯誤，並由編譯器保證 `when` 窮舉；Kotlin 目前沒有 typed throws。

### 定義錯誤

- **要**：錯誤一律 `sealed interface`，一種資料一個型別，命名 `<資料類型>Error`（`ProfileError`），以 `core/model/Error.kt` 樣板建立，放 `core/model`。
- **要**：錯誤型別不繼承 `Throwable`，它是一般的值。
- **要**：子型別帶除錯需要的上下文：`data class NotFound(val id: UserId)`；沒有上下文的用 `data object`；包裝底層例外時屬性叫 `cause: Throwable`。
- **要**：UseCase 組合多種資料時，回傳其中一種資料的錯誤，或定義 `<Verb><Noun>Error` 把各 Repository 的錯誤包成子型別（`data class Payment(val error: PaymentError)`）。

### 回傳與轉換

- **要**：Repository、data source、UseCase 可能失敗的一次性操作回傳 `Outcome<T, <資料類型>Error>`；持續更新的資料回傳 `Flow<T>`，同步失敗由另一個回傳 `Outcome` 的方法（`refresh()`）表達。
- **要**：例外只在與外部世界的邊界（data source 包裝的 Retrofit、Room、DataStore、系統 API）用 `try` / `catch` 接住，**只 catch 具體的例外型別**（`IOException`、`HttpException`、`SerializationException`、`SQLiteException`），轉成錯誤型別後回傳 `Outcome.Failure`。
- **要**：Repository 拿到 data source 的錯誤時，用 `mapError` 轉成自己資料類型的錯誤；ViewModel 不應該看到例外。
- **避免**：`runCatching`、`mapCatching`、`recoverCatching`：它們接住所有 `Throwable`，包含 `CancellationException`，會讓 coroutine 的取消失效；`kotlin.Result` 的錯誤型別又固定是 `Throwable`，無法窮舉。
- **避免**：`catch (e: Exception)` / `catch (e: Throwable)`；真的無法列舉時，前面必須先有 `catch (e: CancellationException) { throw e }`。

### 接住與處理

- **要**：用 `when (outcome)` 處理結果，失敗分支再 `when (outcome.error)` 窮舉；`when` 作用在 sealed 或 enum 上時不寫 `else`。
- **要**：ViewModel 的失敗處理最後一定把狀態轉成錯誤狀態，畫面不能停在載入中。
- **要**：丟棄 `Outcome` 只用於「失敗後使用者原本要做的事仍做得成」的情況（快取、分析、預先載入），在上一行加註解寫明「失敗可忽略，因為 …」。
- **避免**：空的 `catch {}`，以及只 `Log` 不處理的 `catch`。
- **避免**：`require` / `check` / `error()` 用於執行期可能發生的狀況；它們只用於違反程式不變量的邏輯錯誤，也就是程式或測試本身寫錯，例如 Preview 的假資料或測試環境無法建立。訊息寫明為什麼無法繼續：`check(isReady) { "原因" }`。

```kotlin
/** 以伺服器為唯一來源的 [ProfileRepository]，每次都重新向伺服器取得。 */
class RemoteProfileRepository @Inject constructor(
    /** 實際發出網路請求的來源。 */
    private val remoteDataSource: ProfileRemoteDataSource,
) : ProfileRepository {

    /** 向伺服器取得 [id] 的個人資料，找不到時為 [ProfileError.NotFound]，其他連線問題為 [ProfileError.Network]。 */
    override suspend fun fetchProfile(id: UserId): Outcome<Profile, ProfileError> =
        remoteDataSource.fetchProfile(id.value).mapError { error ->
            when (error) {
                is NetworkError.HttpStatus if error.code == 404 -> ProfileError.NotFound(id)
                is NetworkError.HttpStatus -> ProfileError.Network(cause = error.cause)
                is NetworkError.Connection -> ProfileError.Network(cause = error.cause)
                is NetworkError.Decoding -> ProfileError.Decoding(cause = error.cause)
            }
        }

    /** 不做任何事，因為這個實作沒有快取。 */
    override fun invalidateCache() = Unit
}
```

data source 在邊界只 catch 具體的例外，並自己負責切換執行緒：

```kotlin
/** 以 Retrofit 取得個人資料的 [ProfileRemoteDataSource]。 */
class RetrofitProfileRemoteDataSource @Inject constructor(
    /** Retrofit 產生的 API 介面。 */
    private val api: ProfileApi,
    /** 發出網路請求時使用的 dispatcher。 */
    @IoDispatcher private val ioDispatcher: CoroutineDispatcher,
) : ProfileRemoteDataSource {

    /** 取得 [id] 的個人資料，連線失敗、狀態碼非 2xx、格式不符時回傳對應的 [NetworkError]。 */
    override suspend fun fetchProfile(id: String): Outcome<Profile, NetworkError> =
        withContext(ioDispatcher) {
            try {
                Outcome.Success(api.fetchProfile(id))
            } catch (e: HttpException) {
                Outcome.Failure(NetworkError.HttpStatus(code = e.code(), cause = e))
            } catch (e: IOException) {
                Outcome.Failure(NetworkError.Connection(cause = e))
            } catch (e: SerializationException) {
                Outcome.Failure(NetworkError.Decoding(cause = e))
            }
        }
}
```

## Concurrency

### 模型

- **要**：Coroutines 與 Flow 是唯一的非同步模型。一次性操作寫成 `suspend fun`；會持續更新的資料寫成回傳 `Flow<T>` 的函式。
- **要**：既有的 callback API 在 data source 內包裝：一次性結果用 `suspendCancellableCoroutine`，持續事件用 `callbackFlow`（`awaitClose` 內取消註冊）。
- **要**：多個獨立請求用 `coroutineScope { }` 內的 `async` 並行，再一起 `await`；數量不定時 `map { async { ... } }.awaitAll()`。
- **避免**：RxJava、LiveData、`AsyncTask`、`Executor`、`Thread`；`Thread.sleep`，改用 `delay`；`runBlocking`，測試改用 `runTest`。

### Dispatcher 與 main-safety

依官方：「If a class is doing long-running blocking operations in a coroutine, it's in charge of moving the execution off the main thread using `withContext`. This applies to all classes in your app, regardless of the part of the architecture the class is in.」

- **要**：所有 `suspend fun` 都是 main-safe，主執行緒直接呼叫也不會卡住畫面。
- **要**：誰做阻塞或大量計算，誰就以 `withContext` 切換：讀寫網路、資料庫、檔案的 data source 用 `@IoDispatcher`；做大量計算的 Repository、UseCase、ViewModel 用 `@DefaultDispatcher`。只是轉呼叫其他 `suspend fun` 的類別不需要切換。
- **要**：Dispatcher 一律注入，不寫死 `Dispatchers.IO`：以 `@IoDispatcher private val ioDispatcher: CoroutineDispatcher` 取得，qualifier 定義在 `core/common/di/DispatchersModule.kt`；測試時換成 `TestDispatcher`。
- **避免**：`Dispatchers.Main` / `Dispatchers.IO` 直接出現在正式碼（DI module 除外）；`Dispatchers.Unconfined`。

### Coroutine 的建立與取消

- **要**：用 `launch` 開始的工作一定屬於有生命週期管理的 scope：ViewModel 的 `viewModelScope`（業務工作）、Compose 的 `LaunchedEffect` / `rememberCoroutineScope`（純 UI 工作，例如捲動、動畫）、注入的 `@ApplicationScope CoroutineScope`（畫面離開後仍要完成的短暫工作）。`suspend fun` 內以 `coroutineScope { }` 並行屬於結構化並行，不受此限。
- **要**：要撐過 process death、或超過幾秒的工作，交給 WorkManager；官方：「Don't use the viewModelScope to run requests that last for 5 seconds or more」。
- **要**：可能被重複觸發的長時間工作存成 `private var loadJob: Job? = null`，重新觸發前先 `cancel()`；資料流型的重複觸發用 `collectLatest`、`mapLatest`、`debounce`。
- **要**：長迴圈或多步驟流程內定期 `ensureActive()`；`CancellationException` 一律往外傳，不接住、不顯示給使用者。
- **避免**：`GlobalScope`、自行 `CoroutineScope(Job())` 建立沒人管理生命週期的 scope（DI 提供的 `@ApplicationScope` 除外）。
- **避免**：ViewModel 的 `init` 區塊或建構子內啟動非同步工作；初始載入依 `file-templates.md` 的 ViewModel 一節。
- **避免**：在 composable 的 `LaunchedEffect` 內呼叫 Repository 或執行業務邏輯，一律交給 ViewModel。

### Flow

- **要**：UI 狀態用 `StateFlow`，對外只暴露唯讀型別；畫面端一律 `collectAsStateWithLifecycle()`。
- **要**：把資料層的 Flow 轉成 UI 狀態時用 `stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), 初始值)`。
- **要**：一次性事件（儲存成功後返回、顯示提示）表達成 UiState 的欄位，見 `file-templates.md`；不用 `Channel` 或 `SharedFlow` 傳 UI 事件。

```kotlin
/** 同時載入個人資料與訂單，兩者都完成後才一起更新畫面。 */
private suspend fun loadDashboard() {
    coroutineScope {
        val profile = async { profileRepository.fetchProfile(userId) }
        val orders = async { orderRepository.fetchOrders(userId) }
        uiState.value = DashboardUiState.from(profile = profile.await(), orders = orders.await())
    }
}
```

## 註解與 KDoc

### KDoc（`/** */`）

依 Kotlin 官方 KDoc 文件與 Android Kotlin style guide 的格式；範圍比官方嚴格：官方只要求 public API 必寫，本規範要求所有宣告都寫。

- **要**：**所有宣告一律有 KDoc**：型別、interface 與其成員、方法與屬性、主建構子宣告的每個屬性、enum entry、sealed 子型別、nested type、`private` 成員、top-level 函式與常數、`@Composable` 與 `@Preview` 函式、Hilt module 的 `@Binds` / `@Provides`、測試方法、`override` 的實作。
- **要**：第一句是摘要，以句號「。」結尾（Android：punctuated as if it were a complete sentence）。只有摘要時寫成單行 `/** 摘要。 */`。
- **要**：函式（含 `override` 的實作）的摘要說明「做什麼」，動詞開頭：省略主詞，從這個宣告做的動作寫起，動作前可以先寫方式或時機（「依 [id] 取得個人資料」「每個測試前以假資料模式啟動 App」）；測試方法一律以「驗證」開頭，見 `file-templates.md` 的 tests/Test.kt 一節。
- **要**：型別、屬性、enum entry、sealed 子型別與回傳 `Unit` 的 `@Composable` 說明「這是什麼」，不受動詞開頭限制：型別說明職責與使用時機；屬性寫成名詞片語（「唯一識別碼」「顯示給使用者看的名稱」），`Boolean` 屬性用「是否」問句（「是否已付款」）；enum entry 與 sealed 子型別寫它代表的情況（「使用者中途放棄」）；`@Composable` 的元件名稱是名詞，說明它是什麼、顯示什麼。
- **要**：參數與回傳值的說明**直接寫進內文**，提到參數或其他宣告時用中括號連結：`/** 依 [id] 取得個人資料，找不到時為 [ProfileError.NotFound]。 */`。Kotlin 官方：「Generally, avoid using `@param` and `@return` tags」。
- **要**：只有描述太長、放不進內文時才用 block tag，順序依 Android：`@constructor`、`@receiver`、`@param`、`@property`、`@return`、`@throws`、`@see`，每個 tag 都要有說明。
- **要**：回傳 `Outcome` 時，內文寫出成功的內容與每種失敗對應哪個錯誤子型別。
- **要**：主建構子宣告的屬性在各自前面寫單行 KDoc；不是屬性的建構子參數在型別的 KDoc 內文中以 `[參數名]` 說明。
- **要**：interface 成員與其實作兩邊都寫，但內容不同：interface 上寫「做什麼、呼叫端能期待什麼」；實作上寫「這個實作怎麼做」，例如資料來源、有無快取。
- **要**：摘要之後可以再寫一段補充說明，一段只講一件事，例如使用前提、效能特性、平台限制。
- **要**：正體中文；可連結的宣告用 `[名稱]`，無法連結的程式碼文字（設定值、指令）才用反引號。一般概念詞（snackbar、back stack、Compose）不加反引號，即使它們是英文；`//` 註解同樣適用。
- **要**：用白話文寫，目標是**完全不懂程式的人也能看懂這段程式碼在做什麼**：說使用者看得到的結果與情境，不說實作機制；能用日常詞就不用術語。
- **要**：白話但精簡，摘要一句話說完；每個詞拿掉後意思有沒有變，沒變就刪。
- **避免**：冗言贅字（「這個函式的用途是用來」「基本上」「進行 … 的動作」）；複述名稱的廢話（`/** 使用者 ID。 */` 放在 `userId` 上）；只有工程師才懂的縮寫與設計模式名稱。
- **避免**：`//` 或 `/* */` 代替 KDoc；KDoc 內寫 HTML。

### 一般註解（`//`）

- **要**：只寫「為什麼」：非直覺的決定、workaround 的原因與對應版本、丟棄 `Outcome` 為何可忽略、`@Suppress` 為何必要。
- **要**：`// TODO:` 與 `// FIXME:` 固定格式 `// TODO: [#123] 描述`，必附 issue 編號。
- **避免**：複述程式碼的註解、被註解掉的程式碼。

```kotlin
/** 個人資料的唯一入口，讀取與更新都經過它。 */
interface ProfileRepository {

    /**
     * 依 [id] 取得個人資料，成功時回傳個人資料，找不到使用者為 [ProfileError.NotFound]，
     * 網路連不上為 [ProfileError.Network]。
     *
     * 最近五分鐘內抓過就用上次的結果，要強制重抓請先呼叫 [invalidateCache]。
     */
    suspend fun fetchProfile(id: UserId): Outcome<Profile, ProfileError>

    /** 清掉快取，下次 [fetchProfile] 一定向伺服器重抓。 */
    fun invalidateCache()
}
```

## 常見錯誤檢查清單

- [ ] 命名：`Manager` / `Wrapper` / `Helper` / `Util`、`Impl` 後綴或 `I` 前綴、Service / Client / Store 等非官方的資料層名稱、實作無故用 `Default`、data source 以實作細節命名
- [ ] 命名：縮寫全大寫（`userID`）、型別參數不是單字母或 `XxxT`、型別參數遮蔽 `Error` 等標準型別、`const val` 或深度不可變常數不是 SCREAMING_SNAKE_CASE、純量常數沒有 `const`
- [ ] 命名：ViewModel 方法以 UI 手勢命名（`onRetryClick()`）、回傳 `Unit` 的 composable 用 lowerCamelCase、有回傳值的 composable 用 UpperCamelCase
- [ ] 存取控制：成員未從 `private` 起手、明寫 `public`、方案 A 寫 `internal`、暴露 `MutableStateFlow`、為了測試放寬存取層級
- [ ] 型別：data class 有 `var`、class 無故 `open`、`typealias` 給基本型別、`Pair` / `Triple` 跨函式邊界、UseCase 或 ViewModel 定義了 interface、`synchronized` 保護業務狀態
- [ ] 函式拆分：只在一處使用、只有幾行的邏輯抽成 helper；約 15 行以上的獨立演算法沒有抽出
- [ ] Extension：為收納而建的 `<Type>Extensions.kt`、只有一處用的 extension 沒有 `private` 且不在使用處旁
- [ ] Null safety：`!!`、`as`、`lateinit` 用在 DI 與測試 setup 以外、`?.let { } ?: run { }`、safe call 超過兩層、`Boolean?`、回傳 null 集合
- [ ] Error：錯誤型別繼承 `Throwable`、可能失敗的操作未回傳 `Outcome`、`runCatching` 系列、`catch (e: Exception)` 未先重新丟出 `CancellationException`、例外外洩到 ViewModel、sealed `when` 寫 `else`、失敗未轉成錯誤狀態、`require` / `check` / `error()` 用於執行期狀況或沒有訊息說明原因
- [ ] Concurrency：做阻塞或大量計算的類別沒有 `withContext`、寫死 `Dispatchers.IO`、`GlobalScope`、`runBlocking`、`init` 內啟動非同步工作、超過數秒或要撐過 process death 的工作沒交給 WorkManager
- [ ] Flow：`collectAsState` 未帶 lifecycle、用 `Channel` / `SharedFlow` 傳 UI 事件、資料層的 Flow 未以 `stateIn(WhileSubscribed(5_000))` 轉成狀態
- [ ] KDoc：任何宣告缺 KDoc、摘要沒有句號、函式的摘要不是動詞開頭、測試方法的摘要不是以「驗證」開頭、慣性地寫 `@param` / `@return` 而非併入內文、可連結的宣告用反引號而非 `[名稱]`、block tag 順序錯誤或沒有說明、`Outcome` 沒寫失敗情況
- [ ] 註解：術語與縮寫、複述名稱、冗言贅字、`// TODO` 沒有 issue 編號、被註解掉的程式碼、一般概念詞（snackbar、back stack）加了反引號
