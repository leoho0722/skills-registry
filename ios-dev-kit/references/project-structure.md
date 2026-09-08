# Project Structure（專案目錄結構）

Leo Ho 個人 iOS 專案目錄結構規範，版本 2026-09。

## 目錄

- [分層原則](#分層原則)
- [根目錄結構](#根目錄結構)
- [Feature 模組結構](#feature-模組結構)
- [共用程式碼的擺放](#共用程式碼的擺放)
- [測試目錄](#測試目錄)
- [常見錯誤檢查清單](#常見錯誤檢查清單)

## 分層原則

<!-- TODO：採用的架構（Clean Architecture / MVVM / TCA 等）、各層職責與依賴方向。 -->

- **要**：
- **避免**：

### Data 層內的兩種型別

| 種類 | 職責 | 可依賴 |
|---|---|---|
| Client / Store | 純技術能力（HTTP、Keychain、資料庫），不含業務語意 | 系統 framework、第三方 SDK |
| Service | 面向業務的一組操作 | Client / Store，**不可依賴其他 Service** |

### UseCase（可選）

跨多個 Service 的流程預設放在 ViewModel。只有當同一流程被多個 ViewModel 重複使用時，才在 `Domain/UseCases/` 以 `domain/UseCase.swift` 樣板建立：一個 UseCase 一個檔案，init 注入所需的 Service，對外只暴露一個 `execute` 方法。引入前先確認確實有重複，不預先建立空的 `UseCases/` 資料夾。

### Coordinator

每個 Feature 一個 Coordinator，放在該 Feature 的 `Presentation/` 內，以 `presentation/Coordinator.swift` 樣板建立。App 層有一個根 Coordinator 持有各 Feature 的 Coordinator，負責 Feature 之間的切換；Feature 之間不互相引用。多步驟流程（onboarding、結帳）視為獨立 Feature，以 `presentation/FlowCoordinator.swift` 樣板建立，由呼叫它的 Feature 以 `fullScreenCover` 呈現。

### 依賴注入

init 注入為主；Service 透過 SwiftUI Environment 送到 View，`@Entry` key 集中放 `Core/Environment/EnvironmentValues+Services.swift` 一個檔案。不使用 `.shared` 單例，不引入 DI container。細則見 `file-templates.md` 的 Service 一節。

## 根目錄結構

<!-- TODO：填入實際目錄樹，並註明每個資料夾放什麼。 -->

```text
<Project>/
├── App/
├── Features/
├── Domain/
├── Data/
├── Core/
└── Resources/
```

## Feature 模組結構

<!-- TODO：新增一個 Feature 時固定要建的子資料夾與對應樣板（對照 file-templates.md 的樣板選擇表）。 -->

```text
Features/<Feature>/
├── Presentation/
├── Domain/
└── Data/
```

## 共用程式碼的擺放

<!-- TODO：Extension、Utility、共用 UI 元件、DI container 各放哪裡；何時該從 Feature 內抽到共用層。 -->

- **要**：
- **避免**：

### Formatters

自訂 `FormatStyle` 實作放在 `Core/Formatters/`，一個樣式一個檔案，檔名 `<Name>FormatStyle.swift`，對應測試放在測試 target 的鏡像路徑。View 與 ViewModel 都不得自行定義格式化邏輯，規則見 `file-templates.md` 的 View 一節。

<!-- TODO：確認 Core/ 的實際名稱與位置後同步修改此節與根目錄結構樹。 -->

## 測試目錄

<!-- TODO：測試 target 的目錄是否鏡像主 target、fixture 的位置。 -->

- **要**：
- **避免**：

### Mock 與 Preview stub

| 型別 | 位置 |
|---|---|
| `Mock<Name>Service` | 測試 target 的 `Mocks/`，不放主 target |
| `Preview<Name>Service` | 主 target 的 `Preview Content/`，Xcode 的 Development Assets 設定會將其排除於 Release |

<!-- TODO：確認測試 target 內 Mocks/ 是否依主 target 的分層再分子資料夾。 -->

## 常見錯誤檢查清單

- [ ]
- [ ]
