package __PACKAGE__

import androidx.compose.ui.test.junit4.v2.createEmptyComposeRule
import androidx.test.core.app.ActivityScenario
import __BASE_PACKAGE__.MainActivity
import __BASE_PACKAGE__.core.testing.repository.Fake__NAME__Repository
import dagger.hilt.android.testing.HiltAndroidRule
import dagger.hilt.android.testing.HiltAndroidTest
import javax.inject.Inject
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test

/** __NAME__ 流程的 UI 測試：啟動整個 App，Repository 換成 Fake，照使用者的操作走一遍。 */
@HiltAndroidTest
class __NAME__UiTest {

    /** 每個測試前建立 Hilt 元件的規則，必須最先執行。 */
    @get:Rule(order = 0)
    val hiltRule = HiltAndroidRule(this)

    /** 找元件與操作畫面的規則，App 由各測試自己啟動，才能先設定 Fake。 */
    @get:Rule(order = 1)
    val composeTestRule = createEmptyComposeRule()

    /** 測試用的假資料來源，由 `TestDataModule` 提供。 */
    @Inject
    lateinit var __NAME_LOWER_CAMEL__Repository: Fake__NAME__Repository

    /** 啟動中的 App，測試結束時關閉。 */
    private var scenario: ActivityScenario<MainActivity>? = null

    /** 注入測試用的物件。 */
    @Before
    fun setUp() {
        hiltRule.inject()
    }

    /** 關閉這個測試啟動的 App。 */
    @After
    fun tearDown() {
        scenario?.close()
    }

    /** 驗證示範流程的結果；替換為實際流程並改寫此說明。 */
    @Test
    fun `example_情境_預期`() {
        // Given
        launchApp()

        // When

        // Then
    }

    /** 在 Fake 設定完之後才啟動 App，讓第一次載入就拿到測試資料。 */
    private fun launchApp() {
        scenario = ActivityScenario.launch(MainActivity::class.java)
    }
}
