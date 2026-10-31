package __PACKAGE__

import androidx.navigation3.runtime.EntryProviderScope
import androidx.navigation3.runtime.NavKey
import __BASE_PACKAGE__.core.navigation.Navigator
import __FEATURE_PACKAGE__.__NAME__Screen

/** 把 __FEATURE__ 功能的畫面註冊到 App 的導航，畫面要換頁時透過 [navigator]。 */
fun EntryProviderScope<NavKey>.__FEATURE_LOWER_CAMEL__Entry(navigator: Navigator) {
    entry<__NAME__NavKey> {
        __NAME__Screen(onBackClick = navigator::goBack)
    }
}
