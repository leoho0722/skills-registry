package __BASE_PACKAGE__.core.ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.ui.platform.LocalConfiguration
import java.util.Locale

/** 把 `__VALUE_TYPE__` 轉成畫面上顯示的文字，替換時寫明顯示規則。 */
object __NAME__Formatter {

    /** 依 [locale] 把 [value] 轉成顯示用的文字。替換時改寫成實際規則。 */
    fun format(value: __VALUE_TYPE__, locale: Locale): String = value.toString()
}

/** 依使用者目前的語言顯示這個值，語言切換時畫面會自動更新。 */
@Composable
@ReadOnlyComposable
fun __VALUE_TYPE__.formatted__NAME__(): String =
    __NAME__Formatter.format(value = this, locale = LocalConfiguration.current.locales[0])
