package __PACKAGE__

import __BASE_PACKAGE__.core.testing.MainDispatcherRule
import kotlin.test.assertEquals
import kotlinx.coroutines.test.runTest
import org.junit.Rule
import org.junit.Test

/** [__NAME__] 的單元測試，替換時改寫成測試對象。 */
class __NAME__Test {

    /** 替換主執行緒 dispatcher 的規則，只有測試對象用到 `viewModelScope` 時保留。 */
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    /** 驗證示範情境的結果；替換為實際測試並改寫此說明。 */
    @Test
    fun `example_情境_預期`() = runTest {
        // Given
        val expected = 1

        // When
        val actual = 1

        // Then
        assertEquals(expected, actual)
    }
}
