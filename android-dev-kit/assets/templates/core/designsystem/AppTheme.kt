package __BASE_PACKAGE__.core.designsystem

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/** App 的間距規格，畫面上的間距一律從這裡取，不直接寫數字。 */
@Immutable
data class Spacing(
    /** 元件內部的小間距。 */
    val small: Dp = 8.dp,
    /** 元件之間的標準間距。 */
    val medium: Dp = 16.dp,
    /** 區塊之間的大間距。 */
    val large: Dp = 24.dp,
)

/** 讓子畫面取得目前主題的間距規格。 */
private val LocalSpacing = staticCompositionLocalOf { Spacing() }

/**
 * App 的主題，所有畫面、Preview 與 UI 測試都包在它裡面。
 *
 * [darkTheme] 預設跟隨系統的深色模式，[content] 是套用主題的畫面。
 */
@Composable
fun AppTheme(darkTheme: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit) {
    CompositionLocalProvider(LocalSpacing provides Spacing()) {
        MaterialTheme(
            colorScheme = if (darkTheme) darkColorScheme() else lightColorScheme(),
            content = content
        )
    }
}

/** 取得目前主題的自訂設計規格，寫法為 `AppTheme.spacing.medium`。 */
object AppTheme {

    /** 目前主題的間距規格。 */
    val spacing: Spacing
        @Composable
        @ReadOnlyComposable
        get() = LocalSpacing.current
}
