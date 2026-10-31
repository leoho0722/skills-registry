# Project Structure（專案目錄結構）

Leo Ho 個人 Android 專案目錄結構規範。分層依 Android 官方的 [App architecture](https://developer.android.com/topic/architecture)，模組依 [Modularization](https://developer.android.com/topic/modularization) 與 [Navigation 3 模組化](https://developer.android.com/guide/navigation/navigation-3/modularize)，module 與 package 名稱對齊官方範例 [Now in Android](https://github.com/android/nowinandroid)。

## 目錄

- [分層原則](#分層原則)
- [Package 命名](#package-命名)
- [根目錄結構](#根目錄結構)
  - [方案判斷](#方案判斷)
  - [方案選擇](#方案選擇)
  - [方案 A：單一 `:app`](#方案-a單一-app)
  - [B 與 C 共通的 module 規則](#b-與-c-共通的-module-規則)
  - [方案 B：core 抽成 module](#方案-bcore-抽成-module)
  - [方案 C：Feature 也抽成 module](#方案-cfeature-也抽成-module)
- [Feature 結構](#feature-結構)
- [App 層](#app-層)
- [共用程式碼的擺放](#共用程式碼的擺放)
- [測試目錄](#測試目錄)
- [Gradle 設定](#gradle-設定)
- [常見錯誤檢查清單](#常見錯誤檢查清單)

## 分層原則

依官方架構指南分三層，UI 層依 Feature 分，資料層依資料類型分：

| 層 | 放什麼 | 位置 |
|---|---|---|
| UI layer | 畫面（Screen、ViewModel、UiState）、導航（NavKey、entry 註冊、Navigator、AppNavHost）、主題與共用 UI | `feature/<feature>/`、`ui/`、`core/navigation`、`core/designsystem`、`core/ui` |
| Domain layer（選用） | UseCase | `core/domain` |
| Data layer | Repository、data source、Model、錯誤型別 | `core/data`、`core/network`、`core/database`、`core/datastore`、`core/model` |

依賴方向固定單向，箭頭指向被依賴者（官方：the domain layer depends on data layer classes）：

```text
feature ──▶ core/domain（選用）──▶ core/data ──▶ core/network、core/database、core/datastore
   │                                    │
   └──────────────▶ core/data           └──▶ core/model、core/common
```

- **要**：ViewModel 依賴 Repository 或 UseCase；UseCase 依賴 Repository 與其他 UseCase；Repository 依賴 data source 與其他 Repository；data source 只依賴 `core/model` 與 `core/common`。
- **要**：Model 與錯誤型別放 `core/model`，各層都可以使用。
- **要**：Repository 依資料類型切分，不依 Feature；多個 Feature 需要同一種資料時共用同一個 Repository。
- **要**：跨 Feature 只透過對方的 NavKey 與導航函式導航，不引用對方的 Screen、ViewModel。
- **避免**：ViewModel 或 UseCase 直接依賴 data source；資料層依賴 UI 層；`core` 內任何東西依賴 Feature。

## Package 命名

三個方案用**同一套 package**，module 只負責把檔案分組；方案之間遷移時只搬檔案、不改 package。

| package | 內容 |
|---|---|
| `<base>` | `<App>Application`、`MainActivity` |
| `<base>.ui` | `AppNavHost` |
| `<base>.feature.<feature>` | 該 Feature 的 Screen 與 ViewModel |
| `<base>.feature.<feature>.navigation` | NavKey、導航函式、`<Feature>EntryProvider` |
| `<base>.core.common` | `Outcome`；`.di` 為 `DispatchersModule` |
| `<base>.core.model` | Model、錯誤型別 |
| `<base>.core.data` | Repository；`.di` 為 `DataModule` |
| `<base>.core.network` | 遠端 data source、API 定義；`.di` 為 `NetworkModule` |
| `<base>.core.database` | Room 的 database、DAO、entity；引入 Room 時才建 |
| `<base>.core.datastore` | DataStore 的 data source；引入 DataStore 時才建 |
| `<base>.core.domain` | UseCase；出現第一個 UseCase 時才建 |
| `<base>.core.navigation` | `Navigator` |
| `<base>.core.ui` | 多個 Feature 共用的 composable 與顯示格式 |
| `<base>.core.designsystem` | `AppTheme`、設計 token、基礎元件 |
| `<base>.core.testing` | `MainDispatcherRule`；`.repository` 為各 Repository 的 Fake |

`<base>` 是 `:app` 的 `namespace`（例如 `com.example.app`）；`<feature>` 是 Feature 名稱的全小寫連寫（`editprofile`）。

## 根目錄結構

三種方案的差別在 Gradle module 切到哪一層。**新專案與既有專案都由使用者決定**，agent 不預設任何一種；對既有專案 agent 只負責偵測並提出建議值。

### 方案判斷

- **新專案**：詢問使用者三選一，附「方案選擇」表的適用情境，沒有特殊需求時建議 A。不自行決定。
- **既有專案**：依下表偵測 `settings.gradle.kts` 的 `include`，把偵測結果與依據告訴使用者，請使用者確認或改選；偵測結果只是建議值。
- **偵測結果與使用者的選擇不一致時**，視為使用者要求遷移，動手前列出會搬動的檔案與新增的 module 讓使用者確認。

| `settings.gradle.kts` 的 `include` | 方案 |
|---|---|
| 只有 `:app` | A |
| 有 `:core:*`，沒有 `:feature:*` | B |
| 有 `:feature:*` | C |

### 方案選擇

| 方案 | 邊界由誰守 | 適合 | 不適合 |
|---|---|---|---|
| A 單一 `:app` | 紀律與 code review | 單人或小團隊、只有一個 application module、Feature 少於八個 | 已知會有 Wear OS、TV 或第二個 App |
| B core 抽成 module | 資料層與共用 UI 的邊界由 Gradle 守，Feature 之間仍靠紀律 | 一開始就有第二個 application module，或資料層要共用，但 Feature 由同一組人開發 | 多組人平行開發 |
| C Feature 也抽成 module | 全部由 Gradle 守 | 多組人各自負責 Feature、Feature 超過八個、全量建置太慢 | 單人專案，module 設定的成本高於收益 |

「第二個 application module」指 Wear OS、TV、Automotive 或另一個 App；Glance widget、Tiles 與 App 在同一個 module，不算。方案之間可以遷移，方向固定 A → B → C；遷移只在使用者要求時做，agent 看到條件出現只提示。

### 方案 A：單一 `:app`

package 即分層邊界。

```text
<Project>/
├── settings.gradle.kts
├── build.gradle.kts
├── gradle.properties
├── gradle/libs.versions.toml             # project/libs.versions.toml
├── .editorconfig                          # project/.editorconfig
└── app/
    ├── build.gradle.kts
    └── src/
        ├── main/
        │   ├── AndroidManifest.xml
        │   ├── kotlin/<base>/
        │   │   ├── <App>Application.kt
        │   │   ├── MainActivity.kt
        │   │   ├── ui/AppNavHost.kt
        │   │   ├── feature/<feature>/     # 結構見「Feature 結構」
        │   │   └── core/                  # common、model、data、network、database、datastore、domain、navigation、ui、designsystem
        │   └── res/
        ├── test/kotlin/<base>/            # 單元測試
        ├── testFixtures/kotlin/<base>/core/testing/   # Fake 與 MainDispatcherRule
        └── androidTest/kotlin/<base>/     # UI 測試、TestDataModule、HiltTestRunner
```

- **要**：`core/` 下的 package 用到才建（`database`、`datastore`、`domain`），不預先建立空的 package。
- **避免**：出現 `util/`、`helper/`、`common/`（`core/common` 除外）、`misc/`、`base/` 這類無主 package。

### B 與 C 共通的 module 規則

- **要**：module 名稱與 package 對應：`:core:data` 的 `namespace` 為 `<base>.core.data`，`:feature:profile:impl` 為 `<base>.feature.profile`。
- **要**：只含純 Kotlin 型別的 module（`:core:model`、`:core:common` 不含 Android 時）做成 Kotlin/JVM module；官方：Android modules come with overhead，能用 Kotlin module 就用。
- **要**：以 `build-logic/` 的 convention plugin 套用共通設定，module 的 `build.gradle.kts` 只寫 plugin id、`namespace` 與自己的依賴。
- **要**：依賴優先用 `implementation`，只有型別出現在本 module 的公開 API 時才用 `api`（官方：prefer implementation over api）。例如 `:core:data` 的 Repository 回傳 `:core:common` 的 `Outcome` 與 `:core:model` 的型別，所以 `:core:data` 對這兩個 module 用 `api`。
- **要**：module 內部的宣告預設 `internal`，只有被其他 module 使用的才維持 public。
- **要**：每個 module 宣告自己的 Hilt module（`:core:data` 的 `DataModule`、`:core:network` 的 `NetworkModule`）。
- **要**：Fake 與 `MainDispatcherRule` 放 `:core:testing` module，各 module 以 `testImplementation(projects.core.testing)`、`androidTestImplementation(projects.core.testing)` 使用。
- **避免**：Feature 的 `impl` 依賴其他 Feature 的 `impl`；library module 依賴 `:app`。

`build-logic/settings.gradle.kts` 讀取專案根目錄的版本清單：

```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    versionCatalogs {
        create("libs") {
            from(files("../gradle/libs.versions.toml"))
        }
    }
}

rootProject.name = "build-logic"
include(":convention")
```

`build-logic/convention/build.gradle.kts` 以 `compileOnly` 依賴各 plugin 的 artifact（版本清單另加 `android-gradlePlugin`（`com.android.tools.build:gradle-api`）、`compose-gradlePlugin`、`hilt-gradlePlugin`、`kotlin-gradlePlugin`、`ksp-gradlePlugin`、`ktlint-gradlePlugin` 六個 library），註冊三個 plugin：

```kotlin
plugins {
    `kotlin-dsl`
}

dependencies {
    compileOnly(libs.android.gradlePlugin)
    compileOnly(libs.compose.gradlePlugin)
    compileOnly(libs.hilt.gradlePlugin)
    compileOnly(libs.kotlin.gradlePlugin)
    compileOnly(libs.ksp.gradlePlugin)
    compileOnly(libs.ktlint.gradlePlugin)
}

gradlePlugin {
    plugins {
        register("androidLibrary") {
            id = "app.android.library"
            implementationClass = "AndroidLibraryConventionPlugin"
        }
        register("hilt") {
            id = "app.hilt"
            implementationClass = "HiltConventionPlugin"
        }
        register("jvmLibrary") {
            id = "app.jvm.library"
            implementationClass = "JvmLibraryConventionPlugin"
        }
    }
}
```

`build-logic/convention/src/main/kotlin/VersionCatalogExtensions.kt` 讓 plugin 以短寫法取用版本清單：

```kotlin
import org.gradle.api.Project
import org.gradle.api.artifacts.MinimalExternalModuleDependency
import org.gradle.api.artifacts.VersionCatalog
import org.gradle.api.artifacts.VersionCatalogsExtension
import org.gradle.api.provider.Provider
import org.gradle.kotlin.dsl.getByType

/** 專案根目錄 `gradle/libs.versions.toml` 的版本清單。 */
internal val Project.libs: VersionCatalog
    get() = extensions.getByType<VersionCatalogsExtension>().named("libs")

/** 從版本清單取得名稱為 [alias] 的函式庫，例如 `androidx-compose-bom`。 */
internal fun VersionCatalog.library(alias: String): Provider<MinimalExternalModuleDependency> =
    findLibrary(alias).get()
```

`build-logic/convention/src/main/kotlin/AndroidLibraryConventionPlugin.kt`：

```kotlin
import com.android.build.api.dsl.LibraryExtension
import org.gradle.api.JavaVersion
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.kotlin.dsl.configure
import org.gradle.kotlin.dsl.dependencies
import org.jlleitschuh.gradle.ktlint.KtlintExtension

/** 所有 Android library module 共用的 Compose、ktlint 與測試設定。 */
class AndroidLibraryConventionPlugin : Plugin<Project> {

    /** 套用到 [target] 這個 library module。 */
    override fun apply(target: Project) {
        with(target) {
            with(pluginManager) {
                apply("com.android.library")
                apply("org.jetbrains.kotlin.plugin.compose")
                apply("org.jlleitschuh.gradle.ktlint")
            }
            extensions.configure<LibraryExtension> {
                compileSdk = 37
                defaultConfig {
                    minSdk = 26
                    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
                }
                buildFeatures {
                    compose = true
                }
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
            extensions.configure<KtlintExtension> {
                version.set(libs.findVersion("ktlint").get().requiredVersion)
            }
            dependencies {
                val composeBom = platform(libs.library("androidx-compose-bom"))
                add("implementation", composeBom)
                add("implementation", libs.library("androidx-compose-runtime"))
                add("testImplementation", libs.library("junit"))
                add("testImplementation", libs.library("kotlin-test"))
                add("testImplementation", libs.library("kotlinx-coroutines-test"))
                add("testImplementation", libs.library("turbine"))
                add("androidTestImplementation", composeBom)
                add("androidTestImplementation", libs.library("androidx-compose-ui-test-junit4"))
                add("androidTestImplementation", libs.library("androidx-test-ext-junit"))
                add("androidTestImplementation", libs.library("androidx-test-runner"))
                add("androidTestImplementation", libs.library("kotlin-test"))
                add("debugImplementation", libs.library("androidx-compose-ui-test-manifest"))
            }
        }
    }
}
```

`build-logic/convention/src/main/kotlin/HiltConventionPlugin.kt`：

```kotlin
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.kotlin.dsl.dependencies

/** 需要注入的 Android module 共用的 KSP 與 Hilt 設定。 */
class HiltConventionPlugin : Plugin<Project> {

    /** 套用到 [target] 這個需要 Hilt 的 module。 */
    override fun apply(target: Project) {
        with(target) {
            with(pluginManager) {
                apply("com.google.devtools.ksp")
                apply("com.google.dagger.hilt.android")
            }
            dependencies {
                add("implementation", libs.library("hilt-android"))
                add("ksp", libs.library("hilt-compiler"))
            }
        }
    }
}
```

`build-logic/convention/src/main/kotlin/JvmLibraryConventionPlugin.kt`：

```kotlin
import org.gradle.api.JavaVersion
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.plugins.JavaPluginExtension
import org.gradle.kotlin.dsl.configure
import org.gradle.kotlin.dsl.dependencies
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension
import org.jlleitschuh.gradle.ktlint.KtlintExtension

/** 只含純 Kotlin 型別的 module 共用的設定，不帶 Android 的額外負擔。 */
class JvmLibraryConventionPlugin : Plugin<Project> {

    /** 套用到 [target] 這個純 Kotlin module。 */
    override fun apply(target: Project) {
        with(target) {
            with(pluginManager) {
                apply("org.jetbrains.kotlin.jvm")
                apply("org.jlleitschuh.gradle.ktlint")
            }
            extensions.configure<JavaPluginExtension> {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
            extensions.configure<KotlinJvmProjectExtension> {
                compilerOptions.jvmTarget.set(JvmTarget.JVM_17)
            }
            extensions.configure<KtlintExtension> {
                version.set(libs.findVersion("ktlint").get().requiredVersion)
            }
            dependencies {
                add("testImplementation", libs.library("junit"))
                add("testImplementation", libs.library("kotlin-test"))
            }
        }
    }
}
```

根目錄的 `settings.gradle.kts` 以 `pluginManagement { includeBuild("build-logic") }` 接上 build-logic；根目錄的 `build.gradle.kts` 把所有 plugin 以 `alias(...) apply false` 宣告一次，讓各 module 共用同一份 plugin classpath。`compileSdk`、`minSdk` 依專案替換。

### 方案 B：core 抽成 module

`core/` 下的每個 package 抽成對應的 module，Feature 仍在 `:app`：

```text
<Project>/
├── build-logic/
├── core/
│   ├── common/        # :core:common，app.jvm.library（含 Hilt module 時改 app.android.library + app.hilt）
│   ├── model/         # :core:model，app.jvm.library
│   ├── data/          # :core:data，依賴 :core:common 與 :core:model（api）、:core:network
│   ├── network/       # :core:network，用到網路時才建
│   ├── database/      # :core:database，引入 Room 時才建
│   ├── domain/        # :core:domain，出現 UseCase 時才建
│   ├── navigation/    # :core:navigation
│   ├── ui/            # :core:ui，共用 composable、顯示格式、common_ 字串
│   ├── designsystem/  # :core:designsystem
│   └── testing/       # :core:testing，Fake 與 MainDispatcherRule
├── app/               # :app，所有 Feature 的 UI、AppNavHost
└── wear/              # 第二個 application module，依賴需要的 core module
```

`core/data/build.gradle.kts`：

```kotlin
plugins {
    id("app.android.library")
    id("app.hilt")
}

android {
    namespace = "com.example.app.core.data"
}

dependencies {
    api(projects.core.common)
    api(projects.core.model)
}
```

### 方案 C：Feature 也抽成 module

依 Navigation 3 官方模組化指南，每個 Feature 拆成兩個 module：

```text
feature/
└── profile/
    ├── api/           # :feature:profile:api：NavKey 與導航函式，依賴 :core:navigation
    └── impl/          # :feature:profile:impl：Screen、ViewModel、ProfileEntryProvider，依賴自己的 api、:core:*
```

- **要**：`api` 只放 NavKey 與 `Navigator` 的導航函式；其他 Feature 需要導航過來時依賴這個 `api`，不依賴 `impl`（官方：Create two submodules: api and impl for each feature）。
- **要**：`impl` 放 Screen、ViewModel 與 `<Feature>EntryProvider`；兩個 Screen、ViewModel、UiState 都標 `internal`（有狀態的 Screen 以 ViewModel 為參數型別，也必須 `internal`），只有 `<feature>Entry` 對外。
- **要**：`:app` 依賴所有 Feature 的 `impl`，在 `AppNavHost` 呼叫各 `<feature>Entry`。

`feature/profile/impl/build.gradle.kts`：

```kotlin
plugins {
    id("app.android.library")
    id("app.hilt")
}

android {
    namespace = "com.example.app.feature.profile"
}

dependencies {
    implementation(projects.feature.profile.api)
    implementation(projects.core.data)
    implementation(projects.core.designsystem)
    implementation(projects.core.navigation)
    implementation(projects.core.ui)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.hilt.lifecycle.viewmodel.compose)
    implementation(libs.androidx.lifecycle.runtime.compose)
    implementation(libs.androidx.navigation3.runtime)
    debugImplementation(libs.androidx.compose.ui.tooling)
    testImplementation(projects.core.testing)
}
```

## Feature 結構

新增一個 Feature 時固定建立的結構（方案 A、B 在 `:app`，方案 C 分成 `api` 與 `impl`）：

```text
feature/<feature>/
├── <Screen>Screen.kt                    # feature/Screen.kt
├── <Screen>ViewModel.kt                 # feature/ViewModel.kt，含 <Screen>UiState
├── navigation/
│   ├── <Screen>NavKey.kt                # feature/NavKey.kt，含 Navigator.navigateTo<Screen>()
│   └── <Feature>EntryProvider.kt        # feature/EntryProvider.kt
└── component/                           # 選用，同一 Feature 內多個畫面共用的 composable
```

- **要**：最小檔案組四個：Screen、ViewModel、NavKey、EntryProvider，並在 `AppNavHost` 的 `entryProvider` 加一行 `<feature>Entry(navigator)`。
- **要**：Feature 需要新的資料時，在 `core/` 新增對應的 Model、Repository、data source，並在 `DataModule` 與 `TestDataModule` 各加一行；不在 Feature 內放資料層的東西。
- **要**：一個 Feature 有多個畫面時，每個畫面各自一組 `<Screen>Screen.kt`、`<Screen>ViewModel.kt`、`<Screen>NavKey.kt`，平放在同一個 Feature package。
- **要**：Feature 命名用名詞、單數、UpperCamelCase（`Profile`、`Checkout`），package 為其全小寫。
- **避免**：一個畫面有兩個 ViewModel；Feature 內放 Repository、data source 或 Model。

## App 層

`<base>` 與 `<base>.ui` package（方案 C 為 `:app` module）只放進入點與導航起點：

- **要**：`MainActivity` 是唯一的 Activity，`@AndroidEntryPoint`，`onCreate` 內 `enableEdgeToEdge()` 後 `setContent { AppTheme { AppNavHost() } }`，不放其他邏輯。
- **要**：`<App>Application` 只加 `@HiltAndroidApp`，啟動時要初始化的第三方 SDK 以 `androidx.startup` 的 `Initializer` 處理。
- **要**：`AppNavHost` 以 `app/AppNavHost.kt` 樣板建立，是唯一的 `NavDisplay`。

## 共用程式碼的擺放

| 東西 | 位置 | 何時放這裡 |
|---|---|---|
| `Outcome`、dispatcher qualifier | `core/common` | 一開始就放 |
| Model、錯誤型別 | `core/model` | 一開始就放 |
| Repository、`DataModule` | `core/data` | 出現第一種資料時 |
| 遠端、資料庫、DataStore 的 data source | `core/network`、`core/database`、`core/datastore` | 用到該技術時 |
| UseCase | `core/domain` | 出現第一個 UseCase 時 |
| `Navigator` | `core/navigation` | 一開始就放 |
| 多個 Feature 共用的 composable、顯示格式、`common_` 字串 | `core/ui` | 第二個 Feature 需要時才抽 |
| 主題、設計 token、基礎元件（按鈕、輸入框） | `core/designsystem` | `AppTheme` 一開始就放；元件在第二個 Feature 要用時才抽 |
| 多個 Feature 共用的 extension | `core/` 下對應主題的 package，檔名描述功能 | 出現第二個使用者時 |

- **要**：抽到 `core/` 的門檻是「第二個 Feature 出現需求」，不預先抽；資料層與 `AppTheme` 例外，它們天生共用。
- **要**：`core/designsystem` 只放與業務無關的基礎元件，只依賴 Compose；帶業務意義的共用元件（顯示使用者資料的卡片）放 `core/ui`。
- **要**：畫面內不得出現未經 token 的值：顏色與字型用 `MaterialTheme`，間距等自訂 token 用 `AppTheme`。
- **要**：字串資源依 `<feature>_<用途>` 命名，全 App 共用的 `common_` 字串方案 A 放 `:app`，方案 B、C 放 `:core:ui`，Feature 內以 `import <base>.core.ui.R as CoreUiR` 引用。
- **避免**：`core/` 內出現特定 Feature 的名詞；Feature 之間直接引用對方的 component。

## 測試目錄

```text
app/src/
├── test/kotlin/<base>/                  # 單元測試，package 與被測型別相同
│   ├── feature/<feature>/
│   │   ├── <Screen>ViewModelTest.kt
│   │   └── <Screen>ViewModel<行為>Test.kt   # 過大時依受測行為拆出，放同一個 package
│   └── core/
│       ├── data/<資料類型>RepositoryTest.kt
│       ├── data/<資料類型>RepositoryTestSupport.kt   # 同 package 多個測試類別共用的 helper
│       ├── domain/<Verb><Noun>UseCaseTest.kt
│       └── ui/<Name>FormatterTest.kt
├── testFixtures/kotlin/<base>/core/testing/   # 方案 A；方案 B、C 為 :core:testing module
│   ├── MainDispatcherRule.kt
│   └── repository/Fake<資料類型>Repository.kt
└── androidTest/kotlin/<base>/
    ├── HiltTestRunner.kt
    ├── TestDataModule.kt
    ├── feature/<feature>/<Screen>ScreenTest.kt
    └── <流程或功能>UiTest.kt
```

- **要**：單元測試只為 ViewModel、Repository、data source、UseCase、Formatter 與共用 extension 寫；Model 只測自訂的序列化或對應邏輯。
- **要**：UI 測試為每個畫面寫 `<Screen>ScreenTest`，跨畫面的主要流程寫 `<流程或功能>UiTest`。
- **要**：Repository 的測試以 Fake data source 或暫存檔建立的真實 DataStore / in-memory Room 進行；ViewModel 與 UseCase 的測試以 Fake Repository 進行。
- **要**：測試資料寫成 top-level 函式，所有參數都有預設值，測試只覆寫它關心的欄位，放 `core/testing` 的 `data` package：`fun profileTestData(id: String = "user-1"): Profile`。
- **要**：測試類別過大時依受測行為拆成 `<TypeUnderTest><行為>Test.kt`，放同一個 package，見 `file-templates.md` 的 tests/Test.kt 一節。
- **要**：多個測試類別共用的 helper 不放 Fake、測試資料：同 package 共用的放該 package 的 `<TypeUnderTest>TestSupport.kt`，跨 package 共用的放 `core/testing`；規則見 `file-templates.md` 的 tests/Test.kt 一節。
- **避免**：為 AppNavHost、EntryProvider、Hilt module 寫單元測試，它們由 UI 測試覆蓋；測試資料含隨機值或目前時間。

## Gradle 設定

- **要**：Gradle 設定一律 Kotlin DSL（`.gradle.kts`）；依賴與 plugin 一律經由 `gradle/libs.versions.toml`（`project/libs.versions.toml` 樣板），`build.gradle.kts` 不寫死版本號。方案 B、C 在 `settings.gradle.kts` 以 `enableFeaturePreview("TYPESAFE_PROJECT_ACCESSORS")` 開啟 `projects.core.data` 寫法（Gradle 仍標為 incubating，Now in Android 同樣使用）。
- **要**：原始碼放 `src/<source set>/kotlin/`。
- **要**：`compileSdk` 與 `targetSdk` 用最新穩定版；`minSdk` 由使用者決定，至少 26；Java 與 Kotlin 的 JVM target 為 17；Kotlin 至少 2.4.0。
- **要**：方案 A 的 `:app` 以 `android { testFixtures { enable = true } }` 開啟 testFixtures（AGP 9 起直接支援 Kotlin，不需要額外的 gradle.properties 開關），並讓 testFixtures 依賴 Compose BOM 與 `androidx.compose.runtime`：Compose compiler plugin 也會處理 testFixtures，缺 runtime 會編譯失敗。
- **要**：`defaultConfig.testInstrumentationRunner` 指向 `HiltTestRunner`；`androidTest` 以 `kspAndroidTest(libs.hilt.compiler)` 產生 Hilt 測試元件。
- **要**：所有 module 套用 `org.jlleitschuh.gradle.ktlint`，並以 `ktlint { version.set(libs.versions.ktlint) }` 指定 ktlint 版本。

`app/build.gradle.kts`（方案 A）：

```kotlin
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.ksp)
    alias(libs.plugins.hilt)
    alias(libs.plugins.ktlint)
}

android {
    namespace = "com.example.app"
    compileSdk = 37

    defaultConfig {
        applicationId = "com.example.app"
        minSdk = 26
        targetSdk = 37
        versionCode = 1
        versionName = "1.0"
        testInstrumentationRunner = "com.example.app.HiltTestRunner"
    }

    buildFeatures {
        compose = true
    }

    testFixtures {
        enable = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

ktlint {
    version.set(libs.versions.ktlint)
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.hilt.lifecycle.viewmodel.compose)
    implementation(libs.androidx.lifecycle.runtime.compose)
    implementation(libs.androidx.lifecycle.viewmodel.navigation3)
    implementation(libs.androidx.navigation3.runtime)
    implementation(libs.androidx.navigation3.ui)
    implementation(libs.hilt.android)
    implementation(libs.kotlinx.coroutines.android)
    implementation(libs.kotlinx.serialization.json)
    ksp(libs.hilt.compiler)
    debugImplementation(libs.androidx.compose.ui.test.manifest)
    debugImplementation(libs.androidx.compose.ui.tooling)

    testFixturesImplementation(platform(libs.androidx.compose.bom))
    testFixturesImplementation(libs.androidx.compose.runtime)
    testFixturesImplementation(libs.junit)
    testFixturesImplementation(libs.kotlinx.coroutines.test)

    testImplementation(libs.junit)
    testImplementation(libs.kotlin.test)
    testImplementation(libs.kotlinx.coroutines.test)
    testImplementation(libs.turbine)

    androidTestImplementation(platform(libs.androidx.compose.bom))
    androidTestImplementation(libs.androidx.compose.ui.test.junit4)
    androidTestImplementation(libs.androidx.test.ext.junit)
    androidTestImplementation(libs.androidx.test.runner)
    androidTestImplementation(libs.hilt.android.testing)
    androidTestImplementation(libs.kotlin.test)
    kspAndroidTest(libs.hilt.compiler)
}
```

## 常見錯誤檢查清單

- [ ] 出現 Service / Client / Store、Presenter、Interactor 等非官方的層或名稱
- [ ] 依賴方向錯誤：ViewModel 或 UseCase 直接用 data source、資料層依賴 UI、`core` 依賴 Feature
- [ ] Repository 依 Feature 切分；Feature 內放了 Repository、data source 或 Model
- [ ] 跨 Feature 引用對方的 Screen 或 ViewModel；方案 C 的 Feature `impl` 依賴其他 Feature 的 `impl`
- [ ] 建立新專案未詢問方案，或對既有專案未告知偵測結果就自行決定
- [ ] 預先建立空的 package 或 module；出現 `util/`、`helper/`、`misc/`、`base/`
- [ ] 新 Feature 缺四個最小檔案，或沒在 `AppNavHost` 註冊
- [ ] 純 Kotlin 的 module 做成 Android module；無故使用 `api`；module 重複 `android { }` 設定而非用 convention plugin
- [ ] Gradle 寫死版本號、用 Groovy DSL、原始碼放 `java/`；testFixtures 缺 Compose runtime；Kotlin 低於 2.4 或 ktlint 低於 1.8
- [ ] 測試檔位置未鏡像 main；為 AppNavHost 或 Hilt module 寫單元測試；Fake 不在 testFixtures 或 `:core:testing`；共用的測試 helper 放進 Fake 或測試資料檔
