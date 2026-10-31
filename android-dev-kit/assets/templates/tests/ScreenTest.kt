package __PACKAGE__

import androidx.activity.ComponentActivity
import androidx.compose.ui.test.junit4.v2.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import __MODULE_PACKAGE__.R
import __BASE_PACKAGE__.core.designsystem.AppTheme
import kotlin.test.assertEquals
import org.junit.Rule
import org.junit.Test

/** __NAME__ 畫面的 UI 測試：直接給定畫面狀態，檢查顯示內容與使用者操作。 */
class __NAME__ScreenTest {

    /** 顯示並操作 composable 的規則，同時提供 activity 取得字串資源。 */
    @get:Rule
    val composeTestRule = createAndroidComposeRule<ComponentActivity>()

    /** 驗證載入失敗時按下重試，會呼叫重試。 */
    @Test
    fun `retryClick_載入失敗_呼叫重試`() {
        // Given
        var retryCount = 0
        composeTestRule.setContent {
            AppTheme {
                __NAME__Screen(
                    uiState = __NAME__UiState.Error(messageRes = R.string.__ERROR_MESSAGE_RES__),
                    onRetryClick = { retryCount++ },
                    onBackClick = {}
                )
            }
        }
        val retryText = composeTestRule.activity.getString(R.string.__RETRY_TEXT_RES__)

        // When
        composeTestRule.onNodeWithText(retryText).performClick()

        // Then
        assertEquals(1, retryCount)
    }
}
