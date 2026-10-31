# File Templates（檔案樣板）

Leo Ho 個人 Kotlin / Android 檔案樣板規範。實體樣板放在 [`../assets/templates/`](../assets/templates/)，本檔說明「何時用哪個」與各樣板的填寫規則。寫法依 Android 官方的 [App architecture](https://developer.android.com/topic/architecture)、[Navigation 3](https://developer.android.com/guide/navigation/navigation-3)、[Hilt](https://developer.android.com/training/dependency-injection/hilt-android) 與 [測試](https://developer.android.com/training/testing) 文件，以及官方範例 [Now in Android](https://github.com/android/nowinandroid)、[nav3-recipes](https://github.com/android/nav3-recipes)。

## 目錄

- [樣板選擇](#樣板選擇)
- [佔位符](#佔位符)
- [檔案開頭](#檔案開頭)
- [各樣板說明](#各樣板說明)
  - [feature：畫面](#feature畫面)
  - [feature 與 app：導航](#feature-與-app導航)
  - [多步驟流程](#多步驟流程)
  - [core/model](#coremodel)
  - [core/data](#coredata)
  - [core/domain](#coredomain)
  - [core/common、core/ui、core/designsystem](#corecommoncoreuicoredesignsystem)
  - [core/testing 與 tests](#coretesting-與-tests)
  - [project](#project)
- [常見錯誤檢查清單](#常見錯誤檢查清單)

## 樣板選擇

| 要建立的東西 | 用這個樣板（相對於 `assets/templates/`） | 檔名 | package（方案 A） |
|---|---|---|---|
| 一個畫面：有狀態與無狀態的 Screen、私有 composable、Preview | `feature/Screen.kt` | `<Screen>Screen.kt` | `<base>.feature.<feature>` |
| 畫面的狀態與邏輯，含 `UiState` | `feature/ViewModel.kt` | `<Screen>ViewModel.kt` | `<base>.feature.<feature>` |
| 畫面的導航目的地與導航函式 | `feature/NavKey.kt` | `<Screen>NavKey.kt` | `<base>.feature.<feature>.navigation` |
| 把 Feature 的畫面註冊到 App 的導航 | `feature/EntryProvider.kt` | `<Feature>EntryProvider.kt` | `<base>.feature.<feature>.navigation` |
| App 的導航起點（每個專案一份） | `app/AppNavHost.kt` | 固定 `AppNavHost.kt` | `<base>.ui` |
| 持有畫面堆疊的 Navigator（每個專案一份） | `core/navigation/Navigator.kt` | 固定 `Navigator.kt` | `<base>.core.navigation` |
| 資料模型 | `core/model/Model.kt` | `<Name>.kt` | `<base>.core.model` |
| 不帶資料的選項 | `core/model/Enum.kt` | `<Name>.kt` | `<base>.core.model` |
| 互斥且帶資料的情況 | `core/model/SealedInterface.kt` | `<Name>.kt` | `<base>.core.model` |
| 一種資料的錯誤型別 | `core/model/Error.kt` | `<資料類型>Error.kt` | `<base>.core.model` |
| Repository 的 interface 與實作 | `core/data/Repository.kt` | `<資料類型>Repository.kt` | `<base>.core.data` |
| Data source 的 interface 與實作 | `core/data/Repository.kt`（複製後把 `Repository` 換成 `RemoteDataSource` 或 `LocalDataSource`） | `<資料類型><來源>DataSource.kt` | `<base>.core.network`、`<base>.core.datastore` |
| Repository 的注入清單（方案 A 每個專案一份） | `core/data/DataModule.kt` | 固定 `DataModule.kt` | `<base>.core.data.di` |
| 被多個 ViewModel 重複使用、或簡化 ViewModel 的業務邏輯 | `core/domain/UseCase.kt` | `<Verb><Noun>UseCase.kt` | `<base>.core.domain` |
| 可能失敗的操作結果（每個專案一份） | `core/common/Outcome.kt` | 固定 `Outcome.kt` | `<base>.core.common` |
| Dispatcher 與 App 層級 scope（每個專案一份） | `core/common/DispatchersModule.kt` | 固定 `DispatchersModule.kt` | `<base>.core.common.di` |
| 多個畫面共用的顯示格式 | `core/ui/Formatter.kt` | `<Name>Formatter.kt` | `<base>.core.ui` |
| App 的主題與自訂設計 token（每個專案一份） | `core/designsystem/AppTheme.kt` | 固定 `AppTheme.kt` | `<base>.core.designsystem` |
| Repository 的 Fake | `core/testing/FakeRepository.kt` | `Fake<資料類型>Repository.kt` | `<base>.core.testing.repository` |
| 主執行緒 dispatcher 替換（每個專案一份） | `core/testing/MainDispatcherRule.kt` | 固定 `MainDispatcherRule.kt` | `<base>.core.testing` |
| 單元測試 | `tests/Test.kt` | `<TypeUnderTest>Test.kt`；過大時 `<TypeUnderTest><行為>Test.kt` | 與被測型別相同 |
| 單一畫面的 UI 測試 | `tests/ScreenTest.kt` | `<Screen>ScreenTest.kt` | 與畫面相同 |
| 啟動整個 App 的流程 UI 測試 | `tests/UiTest.kt` | `<流程或功能>UiTest.kt` | `<base>` |
| UI 測試把 Repository 換成 Fake（每個專案一份） | `tests/TestDataModule.kt` | 固定 `TestDataModule.kt` | `<base>` |
| instrumented test 的 runner（每個專案一份） | `tests/HiltTestRunner.kt` | 固定 `HiltTestRunner.kt` | `<base>` |
| ktlint 與編輯器設定（每個專案一份） | `project/.editorconfig` | 固定 `.editorconfig` | 專案根目錄 |
| 依賴版本清單（每個專案一份） | `project/libs.versions.toml` | 固定 `gradle/libs.versions.toml` | 專案根目錄 |

各樣板放在哪個 source set：`core/testing/` 在方案 A 放 `app/src/testFixtures/kotlin/`，方案 B、C 放 `:core:testing` module；`tests/Test.kt` 放 `src/test/kotlin/`；其餘 `tests/` 放 `src/androidTest/kotlin/`；其他樣板放 `src/main/kotlin/`。方案 B、C 的 module 對應見 `project-structure.md`。

表中沒有的型別先不建樣板，等實際專案出現該型別再補，避免留下沒人用的空樣板；新增時同步在對應子資料夾放檔案並在此表加一列。

## 佔位符

樣板內所有佔位符都是 `__UPPER_SNAKE__` 形式，複製後必須全數替換，殘留即視為錯誤。替換後跑一次 `./gradlew ktlintFormat`：佔位符以底線開頭，替換後的 import 順序與行寬都會改變。

| 佔位符 | 意義 |
|---|---|
| `__PACKAGE__` | 這個檔案的 package |
| `__BASE_PACKAGE__` | App 的根 package（`:app` 的 `namespace`），例如 `com.example.app` |
| `__MODULE_PACKAGE__` | 這個檔案所在 Gradle module 的 `namespace`，用於 import 該 module 的 `R`；方案 A 與 `__BASE_PACKAGE__` 相同 |
| `__NAME__` | 主要型別名稱（不含後綴），UpperCamelCase |
| `__NAME_LOWER_CAMEL__` | `__NAME__` 的 lowerCamelCase 形式 |
| `__FEATURE__` | Feature 名稱，UpperCamelCase，例如 `Profile` |
| `__FEATURE_LOWER_CAMEL__` | `__FEATURE__` 的 lowerCamelCase 形式，用於 `<feature>Entry` |
| `__FEATURE_PACKAGE__` | Feature 的 package，例如 `com.example.app.feature.profile` |
| `__ERROR__` | UseCase 回傳的錯誤型別，例如 `ProfileError` |
| `__VALUE_TYPE__` | 被格式化的輸入型別，例如 `Instant`、`Long`；非 `kotlin` 內建型別時補上 import |
| `__ERROR_MESSAGE_RES__`、`__RETRY_TEXT_RES__`、`__BACK_TEXT_RES__` | 字串資源名稱，例如 `profile_error_unavailable`、`common_retry`、`common_back`；要同時在 `strings.xml` 建立 |

## 檔案開頭

- **要**：第一行是 `package`，接著空一行、`import`；不加檔頭註解，作者與建立日期由 git 記錄。
- **要**：只給本檔用的常數寫成 `private const val`，放在 import 之後、第一個宣告之前。

## 各樣板說明

### feature：畫面

#### feature/Screen.kt

一個畫面一個檔案，內有兩個同名的 `<Screen>Screen`（Now in Android 的寫法）：

- **有狀態的 `<Screen>Screen`**：參數為導航 lambda → `modifier` → `viewModel: <Screen>ViewModel = hiltViewModel()`。只做這些事：`collectAsStateWithLifecycle()` 收集狀態、需要時呼叫 `viewModel.initialize()`、依 UiState 的一次性事件欄位呼叫導航 lambda，並把 ViewModel 的方法與導航 lambda 接到無狀態版本（`onRetryClick = viewModel::retry`）。
- **無狀態的 `<Screen>Screen`**：參數為 `uiState`、每個事件一個 lambda（`onRetryClick`、`onNameChange`、`onBackClick`）、`modifier`。只依參數畫出畫面，Preview 與 UI 測試都呼叫這個版本。
- **方案 C**：Feature `impl` 內的兩個 Screen、ViewModel 與 UiState 都標 `internal`（有狀態的 Screen 以 ViewModel 為參數型別，也必須 `internal`），對外只有 `<feature>Entry`。
- **要**：事件以個別 lambda 傳入，不包成單一的 `onAction` 或 wrapper class（官方：property drilling is preferable over creating wrapper classes）。
- **要**：本體只放大框架，實際內容抽到私有 composable（`formatting.md` 的 Compose 排版）。
- **要**：只有純 UI 的元件狀態（捲動位置、展開與否）可以用 `remember` / `rememberSaveable`；畫面資料一律來自 `uiState`。
- **避免**：有狀態版本寫畫面內容、呼叫 Repository，或把 ViewModel 往下傳。

**UI 邏輯與業務邏輯的界線**。只留在 Screen 檔的是 UI 邏輯（官方：UI behavior logic），三條同時成立：

1. 輸入只來自畫面已有的值：`uiState` 的欄位、參數、`remember` 的狀態、版面尺寸。
2. 輸出是給版面或外觀用的值：`Dp`、`Color`、欄數、顯示與否、顯示用的文字。
3. 沒有副作用。

這類計算寫成檔案內的 `private` 函式。過濾、排序、驗證輸入、依業務規則決定狀態（「超過三次失敗就鎖定」）、組合多個欄位推導出業務狀態，都屬於 ViewModel 或 UseCase。一秒判斷：值得寫單元測試的就不屬於 Screen。

**顯示格式（日期、金額、數量）**：

1. UiState 放原始型別（`Instant`、`Long`、`Int`），由 composable 顯示時格式化；語言切換時 ViewModel 不會重建，格式化放在 UI 層才會跟著更新。
2. 系統格式（`DateTimeFormatter.ofLocalizedDate`、`NumberFormat.getCurrencyInstance`）直接在 composable 內 `remember` 後使用；多個畫面共用的格式以 `core/ui/Formatter.kt` 樣板建立。
3. 格式取決於使用者在 App 內的偏好設定（偏好的幣別、24 小時制）時，偏好值由 ViewModel 從 Repository 讀出後放進 UiState，或由 UseCase 產生（官方的 `FormatDateUseCase` 範例）。

**一次性事件**（儲存成功後返回、顯示提示）表達成 UiState 的欄位，有狀態的 Screen 以 `LaunchedEffect` 處理（官方 UI events 指南）：

```kotlin
/**
 * 編輯個人資料畫面，儲存成功後呼叫 [onSaved]。
 *
 * [navKey] 決定要編輯哪一位使用者，由 Hilt 帶給 [viewModel]。
 */
@Composable
fun EditProfileScreen(
    navKey: EditProfileNavKey,
    onSaved: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: EditProfileViewModel =
        hiltViewModel<EditProfileViewModel, EditProfileViewModel.Factory>(
            creationCallback = { factory -> factory.create(navKey) }
        ),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val currentOnSaved by rememberUpdatedState(onSaved)
    LaunchedEffect(uiState.isSaved) {
        if (uiState.isSaved) {
            currentOnSaved()
        }
    }
    EditProfileScreen(
        uiState = uiState,
        onNameChange = viewModel::updateName,
        onSaveClick = viewModel::save,
        modifier = modifier
    )
}
```

- **要**：`LaunchedEffect` 內呼叫的 lambda 以 `rememberUpdatedState` 包住，避免用到舊的 lambda。
- **要**：處理事件後畫面仍留在 back stack（例如跳到下一頁而不是返回）時，處理完呼叫 ViewModel 的 `xxxHandled()` 把欄位清掉，返回時才不會再觸發一次；顯示提示的事件同理（`snackbarShown()`）。
- **要**：使用者點擊觸發的導航以 `dropUnlessResumed { }` 包住，避免畫面轉場中重複點擊（官方 recipes 的寫法）；帶參數的 lambda 在點擊處包：`onClick = dropUnlessResumed { onItemClick(item.id) }`。

**Preview 必備**：UiState 的每種狀態各一個 `@Preview`，命名 `<Screen>Screen<狀態>Preview`，包在 `AppTheme` 內，直接建立 UiState，不經過 ViewModel 與 Hilt。

#### feature/ViewModel.kt

一個檔案放 `<Screen>ViewModel` 與 `<Screen>UiState`；UiState 大到讓檔案難讀時才拆成 `<Screen>UiState.kt`。

- **要**：一律 `@HiltViewModel` 加 `@Inject constructor`，依賴為 Repository 或 UseCase。
- **要**：處理使用者事件的方法依「做什麼」命名（`retry()`、`updateName(name)`、`save()`），每個事件一個方法；不用單一的 `onAction` 入口，也不以 UI 手勢命名（官方：ViewModel functions … are named with a verb based on the action that they handle）。
- **避免**：持有 `Context`、`Resources`、Navigator 或任何 Compose 型別；在 `init` 或建構子內啟動非同步工作（官方 Warning）。

**狀態的產生方式依官方 state production 指南二選一**：

1. **資料層提供 Flow**（優先）：`uiState` 由 Repository 的 Flow 經 `map` / `combine` 後 `stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), 初始值)` 產生；畫面開始收集才啟動，設定變更時不重新開始。

   ```kotlin
   /** 個人資料畫面的狀態與邏輯。 */
   @HiltViewModel
   class ProfileViewModel @Inject constructor(
       /** 個人資料的來源。 */
       private val profileRepository: ProfileRepository,
   ) : ViewModel() {

       /** 畫面要顯示的狀態，資料更新時自動跟著變。 */
       val uiState: StateFlow<ProfileUiState> = profileRepository.getProfileStream()
           .map<Profile, ProfileUiState>(ProfileUiState::Success)
           .stateIn(
               scope = viewModelScope,
               started = SharingStarted.WhileSubscribed(5_000),
               initialValue = ProfileUiState.Loading
           )
   }
   ```

2. **沒有 Flow 可用**（例如一次性的網路請求）：樣板的寫法。`uiState` 用 explicit backing field 持有 `MutableStateFlow`，另寫一個冪等的 `@MainThread fun initialize()`，以旗標確保只載入一次，由有狀態的 Screen 在 `LaunchedEffect(Unit)` 內呼叫；重試等事件方法再呼叫同一個 `load()`。`load()` 先取消上一次的 `loadJob`。

**`<Screen>UiState`**：官方兩種寫法都可以，依畫面選擇：

- 各狀態互斥（載入中、內容、錯誤）時用 sealed interface，樣板的寫法。
- 內容、載入中與錯誤會同時出現（下拉重新整理時保留舊內容、表單）時用 `data class`，例如 `data class ProfileUiState(val profile: Profile?, val isRefreshing: Boolean, @StringRes val errorMessageRes: Int?)`。
- **要**：錯誤訊息以 `@StringRes` 的字串資源 ID 帶出，由 ViewModel 決定顯示哪一句。

**頁面參數**（NavKey 帶的資料）用 Hilt 的 assisted inject 傳進 ViewModel，`Factory` 只給外部用，放在 class 最後：

```kotlin
/** 編輯個人資料畫面的狀態與邏輯。 */
@HiltViewModel(assistedFactory = EditProfileViewModel.Factory::class)
class EditProfileViewModel @AssistedInject constructor(
    /** 要編輯哪一位使用者，來自導航參數。 */
    @Assisted private val navKey: EditProfileNavKey,
) : ViewModel() {

    /** 表單目前的內容，只有自己能改。 */
    val uiState: StateFlow<EditProfileUiState>
        field = MutableStateFlow(EditProfileUiState(name = navKey.userId))

    /** 把名字改成 [name]。 */
    fun updateName(name: String) {
        uiState.update { it.copy(name = name) }
    }

    /** 儲存目前的表單內容。 */
    fun save() {
        uiState.update { it.copy(isSaved = true) }
    }

    /** 由 Hilt 實作，建立 ViewModel 時帶入頁面參數。 */
    @AssistedFactory
    interface Factory {

        /** 建立編輯 [navKey] 指定使用者的 ViewModel。 */
        fun create(navKey: EditProfileNavKey): EditProfileViewModel
    }
}
```

### feature 與 app：導航

整個 App 只有一個 `NavDisplay`，放在 `app/AppNavHost.kt`；每個 Feature 提供自己的 NavKey、導航函式與 entry 註冊函式（Navigation 3 官方的模組化指南與 Now in Android 的寫法）。

#### core/navigation/Navigator.kt

- **要**：每個專案一份。`Navigator` 持有以 `rememberNavBackStack` 建立的 `NavBackStack<NavKey>`（畫面旋轉與 process death 後會還原），提供 `navigate(key)` 與 `goBack()`；以 `rememberNavigator(startKey)` 建立。
- **要**：畫面之間的導航只經由 `Navigator`；Screen 與 ViewModel 都不直接操作 back stack。
- **要**：需要底部分頁、每個分頁各自保留堆疊時，改用 Now in Android 的 `NavigationState`（多個 back stack 攤平成一個 `NavDisplay`）寫法。

#### feature/NavKey.kt

- **要**：每個畫面一個 `@Serializable` 的 NavKey：沒有參數用 `data object`，有參數用 `data class`，參數用 value class 或基本型別。
- **要**：同檔提供 `Navigator` 的導航函式，其他地方只呼叫它：`fun Navigator.navigateToEditProfile(userId: UserId)`。
- **要**：方案 C 的 NavKey 與導航函式放 Feature 的 `api` module，其他 Feature 依賴 `api` 就能導航過來。

#### feature/EntryProvider.kt

- **要**：每個 Feature 一個 `fun EntryProviderScope<NavKey>.<feature>Entry(navigator: Navigator)`，在裡面以 `entry<XxxNavKey> { key -> ... }` 註冊每個畫面，並把畫面的導航 lambda 接到 `navigator`：`onBackClick = navigator::goBack`、`onEditClick = dropUnlessResumed { navigator.navigateToEditProfile(key.userId) }`。
- **要**：對話框形式的目的地，以 `entry<XxxNavKey>(metadata = DialogSceneStrategy.dialog()) { ... }` 註冊，`AppNavHost` 的 `NavDisplay` 加上 `sceneStrategies = listOf(remember { DialogSceneStrategy() })`（Navigation 3 1.1 起的 API）。

#### app/AppNavHost.kt

- **要**：每個專案一份。`NavDisplay` 的 `entryDecorators` 固定兩個：`rememberSaveableStateHolderNavEntryDecorator()`、`rememberViewModelStoreNavEntryDecorator()`；預設只有前者，少了後者 ViewModel 不會隨頁面清除。
- **要**：`entryProvider` 內依序呼叫每個 Feature 的 `<feature>Entry(navigator)`，新增 Feature 時在這裡加一行。

### 多步驟流程

有明確起點與終點的多步驟畫面（onboarding、結帳、註冊精靈）不另立特殊結構，每一步都是一般的畫面：

- **要**：每一步一個 NavKey，後面步驟的 NavKey 帶著前面步驟收集到的資料：`@Serializable data class CheckoutPaymentNavKey(val address: Address) : NavKey`。NavKey 會存進 saved state，process death 後仍能還原，不需要跨步驟共用的 ViewModel。
- **要**：每一步有自己的 ViewModel，以 assisted inject 取得自己的 NavKey。
- **要**：流程的導航函式寫在該 Feature 的 NavKey 檔：`navigateToCheckoutPayment(address)`；依已填資料決定下一步（貨到付款跳過刷卡頁）的分支寫在 entry 註冊處或導航函式內，屬於導航邏輯；驗證資料屬於 ViewModel。
- **要**：離開流程時一次移除流程內所有 NavKey：`fun Navigator.exitCheckout() { backStack.removeAll { it is CheckoutStepNavKey } }`，流程內的 NavKey 以共同的 sealed interface 標記。
- **要**：流程的產出（建立的訂單、帳號）由最後一步的 ViewModel 寫進 Repository，呼叫端從資料層讀取，不經導航傳回。

### core/model

- **Model**：`data class`，屬性一律 `val`；需要與 JSON 互轉時加 `@Serializable`，欄位名稱不同時在屬性加 `@SerialName`；識別碼用 value class。資料庫與網路各自的格式不同時，另建 `<Name>Entity`（Room）、`Network<Name>`，以 `asExternalModel()` 轉成這裡的 Model。
- **Enum**：預設 `@Serializable`；與外部字串對應時每個 entry 加 `@SerialName`，與數字代碼對應時建構子帶 `val code: Int` 並在 `companion object` 提供 `fromCode(code): X?`。`when` 列出所有 entry，不寫 `else`；列出全部選項用 `entries`。
- **SealedInterface**：不帶資料的子型別用 `data object`，帶資料的用 `data class`；只在需要與 JSON 互轉時加 `@Serializable`，此時每個子型別都加 `@Serializable` 與 `@SerialName`，kotlinx.serialization 以 `type` 欄位放子型別名稱：`{"type": "exampleWithValue", "value": "x"}`。
- **Error**：一種資料一個 sealed interface，規則見 `coding-style.md`。樣板的四個子型別是示範，替換成實際的失敗情況。錯誤到使用者文案的對應由 ViewModel 處理，這裡不依賴 Android 資源。

### core/data

#### core/data/Repository.kt

依官方資料層指南：「create a repository class for each different type of data you handle」。

- **要**：一種資料一個 Repository，不依 Feature 切分；多個 Feature 需要同一種資料時共用同一個 Repository。
- **要**：interface 加有意義名稱的實作（`OfflineFirstProfileRepository`），找不到才用 `Default`；實作 `@Inject constructor`，依賴 data source。
- **要**：一次性操作是 `suspend fun` 並回傳 `Outcome`；持續更新的資料回傳 `Flow`，命名 `get<Data>Stream()`。
- **要**：業務需要時 Repository 可以依賴其他 Repository（官方：a repository might need to depend on other repositories）。
- **要**：依有無可變狀態決定 scope：

  | 實作的狀態 | 寫法 | Hilt scope |
  |---|---|---|
  | 沒有可變狀態，只持有注入的依賴 | 一般 class | 不加 scope |
  | 有可變狀態（記憶體快取、進行中的工作） | 以 `Mutex` 或 `MutableStateFlow.update` 保護 | 實作 class 加 `@Singleton` |
  | 包裝本身就是單例的第三方物件（`OkHttpClient`、Room database、`DataStore`） | 以 `@Provides` 建立並加 `@Singleton`，放 `<技術>Module` | 包裝它的 data source 不加 |

  官方：Minimize the use of scoped bindings，只有真的需要同一份實例時才加 scope。

**Data source**：複製同一份樣板，把 `Repository` 換成 `RemoteDataSource` 或 `LocalDataSource`。

- **要**：data source 只負責一個來源（一個 API、一個檔案、一個資料庫），在這裡 catch 具體的例外並轉成 `Outcome`，並以注入的 `@IoDispatcher` 切換執行緒。
- **要**：遠端 data source 有 interface（Repository 的測試以 Fake 取代）；Room 用 DAO（本身就是 interface）；DataStore 包成具體 class，測試用暫存檔建立真的 DataStore。
- **要**：Repository 以外的地方不直接使用 data source；UseCase 與 ViewModel 只依賴 Repository。

#### core/data/DataModule.kt

方案 A 每個專案一份，是「App 有哪些 Repository」的清單：一行一個 `@Binds`，依名稱字母排序。data source 的綁定與第三方物件的 `@Provides` 放各自技術的 module（`NetworkModule`、`DatabaseModule`），不放這裡。UseCase 是具體 class，不需要綁定。

### core/domain

#### core/domain/UseCase.kt

官方：domain layer 是選用的。建立 UseCase 的時機是「同一段業務邏輯被多個 ViewModel 重複使用」，或「想簡化某個 ViewModel 的業務邏輯複雜度」。

- **要**：命名 `<動詞><名詞>UseCase`，具體 class，`@Inject constructor` 注入 Repository；對外只有一個 `operator fun invoke(...)`，呼叫端寫 `getProfile(id)`。
- **要**：UseCase 可以呼叫其他 UseCase（官方：It's normal to have multiple levels of use cases）。
- **要**：做大量計算時以注入的 `@DefaultDispatcher` 自己 `withContext`。
- **要**：測試時用真的 UseCase 搭配 Fake Repository（官方：use fake repositories when testing the domain layer）。
- **避免**：UseCase 依賴 data source；為 UseCase 定義 interface。

### core/common、core/ui、core/designsystem

- **core/common/Outcome.kt**：每個專案一份。除了 `Success` / `Failure`，只提供 `map`、`mapError`、`onSuccess`、`onFailure`；不加 `getOrThrow` 這類把失敗變回例外的函式。
- **core/common/DispatchersModule.kt**：每個專案一份，定義 `@IoDispatcher`、`@DefaultDispatcher`、`@ApplicationScope` 三個 qualifier 與對應的 `@Provides`。
- **core/ui/Formatter.kt**：多個畫面共用的顯示格式，屬於 UI 邏輯。`format(value, locale)` 是純函式，需要目前時間的加 `now: Instant` 參數；同檔提供 `@Composable` 的便利函式，以 `LocalConfiguration.current.locales[0]` 取得語言。單元測試至少涵蓋預設語言、一個非預設語言、邊界值。
- **core/designsystem/AppTheme.kt**：每個專案一份。`AppTheme { }` 包住 `MaterialTheme`，預設跟隨系統深色模式；顏色與字型沿用 `MaterialTheme.colorScheme` 與 `MaterialTheme.typography`，Material 沒有的 token（樣板示範 `Spacing`）以 `CompositionLocal` 提供、`AppTheme.spacing.medium` 取用（官方 custom design system 寫法）。

### core/testing 與 tests

#### core/testing/FakeRepository.kt

官方：Prefer fakes to mocks、Prefix fake implementations with Fake。

- **要**：每個 Repository 一個 `Fake<資料類型>Repository`，實作完整的 interface；單元測試與 UI 測試共用。
- **要**：一次性方法對應兩個屬性：`<method>Calls`（依序記錄每次的參數，對外型別 `List`，以 explicit backing field 持有 `MutableList`；多個參數時記錄成 nested `data class <Method>Call`；沒有參數的改為 `<method>CallCount: Int`）與 `<method>Result`（測試設定的回傳值）。
- **要**：串流方法以 `MutableStateFlow` 或 `MutableSharedFlow` 實作，另提供 `send<Data>(value)` 讓測試送出新值（Now in Android 的 test repository 寫法）。
- **要**：屬性與 `override` 的順序和 interface 的宣告順序一致。
- **避免**：MockK、Mockito 等 mock 框架；Fake 放 `main` source set。

#### core/testing/MainDispatcherRule.kt

每個專案一份，與官方文件的版本相同：把 `Dispatchers.Main` 換成 `UnconfinedTestDispatcher`，讓 `viewModelScope` 的工作在測試中立即執行。

#### tests/Test.kt

**單元測試一律 JUnit 4**，斷言用 `kotlin.test`（`assertEquals`、`assertIs`），coroutine 用 `runTest`，Flow 的多次發送用 Turbine。放 `src/test`，package 與被測型別相同。

- **要**：命名 `` `<方法或行為>_<情境>_<預期>` ``：方法或行為段照抄程式碼名稱，情境與預期用正體中文，例如 `` `retry_載入失敗後_重新載入` ``。Kotlin 官方允許測試名稱用底線與反引號；名稱內不放空格（Android 11 以前的 DEX 不接受）。
- **要**：測試本體採 Given / When / Then，以 `// Given`、`// When`、`// Then` 分隔；Given 為空時仍保留註解；`// When`、`// Then` 前各空一行。
- **要**：一個測試只允許一組 When / Then。
- **要**：測試方法的 KDoc 摘要以「驗證」開頭，接情境與預期寫成一句白話，例如「驗證收到個人資料後，畫面變成載入完成並帶著取得的資料」。名稱的情境與預期段是縮寫，摘要把它說完整，並補上名稱沒說的資訊，例如受測的是哪一方、預期結果的細節、為什麼這樣預期；只把名稱三段換句話說就是複述名稱（`coding-style.md` 的「註解與 KDoc」）。UI 測試相同。只有 `@Test` 方法加「驗證」，helper、`@Before`、`@After` 等其他函式照一般函式動詞開頭；測試類別與屬性說明「這是什麼」，不加「驗證」：類別寫「[X] 的單元測試」，屬性寫成名詞片語（「替換主執行緒 dispatcher 的規則」）。
- **要**：測試類別過大時，依受測行為拆成獨立的測試類別：每個類別一個檔案，類別與檔名為 `<TypeUnderTest><行為>Test`，行為段用 UpperCamelCase 英文（例如 `ProfileViewModelRetryTest.kt`），與 `<TypeUnderTest>Test.kt` 放同一個 package。拆開後共用的 helper 依下一條放置。
- **要**：測試共用的 helper 依使用範圍放置，不留在其中一個測試類別上讓其他類別呼叫：只有一個測試類別用的，寫成該類別的 `private` 成員；同一個 package 多個測試類別共用的，放同 package 的 `<TypeUnderTest>TestSupport.kt`；跨 package 共用的，放 `core/testing`（`project-structure.md` 的「測試目錄」）。helper 幾乎只在改同一組測試時變動，放在使用它的測試旁邊，改動才集中、歸屬也清楚。
- **要**：`<TypeUnderTest>TestSupport` 是無狀態的 `object`，成員是函式與常數。`<TypeUnderTest>` 是這組測試類別共同的受測型別，也就是 `<TypeUnderTest>Test` 去掉 `Test`；不同受測型別的測試共用時，歸到 helper 處理的那個受測型別，例如建立 `OrderRepository` 的 helper 放 `OrderRepositoryTestSupport`。一個受測型別只有一個 TestSupport，位置依使用範圍最廣的成員決定；使用範圍擴大時整個檔案一起搬，不拆成兩份。跨 Feature 通用的 Model 測試資料仍是 `core/testing` 的 `data` package 內的 top-level 函式，Fake 仍放 `core/testing`；預設值和測試資料函式不同、只給一組測試用的建構 helper 留在 TestSupport。
- **要**：`MainDispatcherRule` 只在測試對象用到 `viewModelScope` 時加。
- **要**：用 `stateIn` 產生狀態的 ViewModel，在 When 以 `backgroundScope.launch(UnconfinedTestDispatcher(testScheduler)) { viewModel.uiState.collect() }` 開始收集，再斷言 `uiState.value`（官方 StateFlow 測試寫法）；用 `initialize()` 的 ViewModel，在 When 呼叫 `initialize()`。`UnconfinedTestDispatcher` 仍是實驗性 API，測試類別加 `@OptIn(ExperimentalCoroutinesApi::class)`。
- **避免**：`Thread.sleep`、真實的網路與資料庫、`@Ignore` 不附 issue 編號。

```kotlin
/** [ProfileViewModel] 的單元測試。 */
@OptIn(ExperimentalCoroutinesApi::class)
class ProfileViewModelTest {

    /** 替換主執行緒 dispatcher 的規則，測試對象用到 `viewModelScope`，所以需要。 */
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    /** 驗證開始收集狀態後，Repository 送出個人資料，畫面變成載入完成並帶著取得的資料。 */
    @Test
    fun `uiState_收到個人資料_變成載入完成`() = runTest {
        // Given
        val repository = FakeProfileRepository()
        val viewModel = ProfileViewModel(profileRepository = repository)
        backgroundScope.launch(UnconfinedTestDispatcher(testScheduler)) {
            viewModel.uiState.collect()
        }

        // When
        repository.sendProfile(Profile(id = "user-1"))

        // Then
        assertEquals(ProfileUiState.Success(Profile(id = "user-1")), viewModel.uiState.value)
    }
}
```

#### tests/ScreenTest.kt

單一畫面的 UI 測試，放 `src/androidTest`，以 `androidx.compose.ui.test.junit4.v2` 的 `createAndroidComposeRule<ComponentActivity>()` 顯示**無狀態**的 Screen，直接給定 UiState 與事件 lambda，不經過 ViewModel 與 Hilt。

- **要**：優先用使用者看得到的語意找元件：`onNodeWithText`、`onNodeWithContentDescription`，文字從字串資源取得（`composeTestRule.activity.getString(R.string.x)`），不寫死；官方測試以語意（semantics）為基礎，同時也驗證了無障礙資訊。
- **要**：元件沒有獨特的文字或描述時才加 `Modifier.testTag`，以 `onNodeWithTag` 查詢。
- **要**：驗證操作時在 lambda 內記錄呼叫，斷言次數或參數。
- **要**：UiState 的每種狀態至少一個顯示測試，主要操作各一個互動測試。
- **避免**：已 deprecated 的 `androidx.compose.ui.test.junit4.createComposeRule`（非 `v2`）。

#### tests/UiTest.kt、tests/TestDataModule.kt、tests/HiltTestRunner.kt

啟動整個 App 的流程測試，放 `src/androidTest`：

- **要**：`@HiltAndroidTest`，`HiltAndroidRule` 為 `order = 0`、`v2` 的 `createEmptyComposeRule()` 為 `order = 1`；`@Before` 呼叫 `hiltRule.inject()` 取得 Fake。
- **要**：先在 Given 設定 Fake 的結果，再以 `ActivityScenario.launch(MainActivity::class.java)` 啟動 App；`@After` 關閉 scenario。
- **要**：`TestDataModule` 以 `@TestInstallIn(replaces = [DataModule::class])` 把所有 Repository 換成 `@Singleton` 的 Fake（官方建議能用 `@TestInstallIn` 就用）；UseCase 與 ViewModel 用真的，data source 因為 Repository 已被取代而用不到。
- **要**：`HiltTestRunner` 在 `build.gradle.kts` 的 `testInstrumentationRunner` 指定。
- **要**：超過三個畫面的流程才為每個畫面建立 `<Screen>Robot` 封裝元件查詢與操作。

### project

- **project/.editorconfig**：複製到專案根目錄，內容見 `formatting.md`；專案已有 `.editorconfig` 時只補上缺少的 Kotlin 設定。
- **project/libs.versions.toml**：複製到 `gradle/libs.versions.toml`。所有 `__LATEST__` 替換為建立當下的最新穩定版（不用 alpha、beta、rc）；Kotlin 至少 2.4.0（explicit backing field）、ktlint 至少 1.8.0；`kotlin` 與 `kotlin-compose`、`kotlin-serialization` plugin 的版本必須相同。

## 常見錯誤檢查清單

- [ ] 佔位符全數替換，替換後跑過 `ktlintFormat`
- [ ] 所有宣告都有 KDoc，樣板的示範說明已改寫，不留「示範」「替換時改寫」字樣
- [ ] 檔名與主要型別名稱一致；檔案加了檔頭註解
- [ ] 有狀態的 Screen 寫了畫面內容、呼叫 Repository，或把 ViewModel 往下傳；無狀態的 Screen 用單一 `onAction` 或 wrapper class 接收事件
- [ ] 導航 lambda 在 `LaunchedEffect` 內使用卻沒有 `rememberUpdatedState`；點擊導航沒有 `dropUnlessResumed`；留在 back stack 的畫面處理事件後沒有清掉欄位
- [ ] Screen 檔寫了業務計算；UiState 放了預先格式化的字串；依 App 偏好的格式沒經過 ViewModel 或 UseCase
- [ ] UiState 的狀態缺 Preview；Preview 經過 ViewModel 或 Hilt
- [ ] ViewModel 在 `init` 載入、`initialize()` 不冪等、有 Flow 可用卻沒用 `stateIn(WhileSubscribed(5_000))`、方法以 UI 手勢命名、持有 `Context` 或 Navigator
- [ ] 一次性事件用 `Channel` / `SharedFlow` 而非 UiState 欄位
- [ ] 出現第二個 `NavDisplay`；NavKey 未加 `@Serializable`；導航不經過 `Navigator` 的導航函式；`AppNavHost` 缺 `rememberViewModelStoreNavEntryDecorator()`；對話框用已 deprecated 的 `sceneStrategy` 參數
- [ ] 流程另建共用 ViewModel 而非由 NavKey 帶資料；流程產出經導航傳回
- [ ] Repository 依 Feature 而非資料類型切分；UseCase 或 ViewModel 直接用 data source；有可變狀態卻沒有 `Mutex` 與 `@Singleton`；實作無故用 `Default`
- [ ] UseCase 定義了 interface 或依賴 data source
- [ ] 測試不是 JUnit 4、名稱沒有反引號或含空格、缺 Given / When / Then、不必要地加 `MainDispatcherRule`
- [ ] `@Test` 方法的 KDoc 摘要沒以「驗證」開頭（寫成「… 時，…」的情境句），或只把名稱三段換句話說；helper、`@Before` 這類其他函式的摘要加了「驗證」
- [ ] 測試類別過大卻沒依行為拆成 `<TypeUnderTest><行為>Test`；共用 helper 留在某個測試類別上讓其他類別呼叫；同 package 共用的沒放 `<TypeUnderTest>TestSupport`、跨 package 共用的沒放 `core/testing`，或一個受測型別有兩個 TestSupport
- [ ] 測試替身叫 `Mock` 或用了 MockK / Mockito；Fake 放在 `main`；UI 測試以 testTag 查詢有文字的元件；App 在設定 Fake 之前就啟動
