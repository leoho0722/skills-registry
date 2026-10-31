package __BASE_PACKAGE__.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.navigation3.rememberViewModelStoreNavEntryDecorator
import androidx.navigation3.runtime.entryProvider
import androidx.navigation3.runtime.rememberSaveableStateHolderNavEntryDecorator
import androidx.navigation3.ui.NavDisplay
import __BASE_PACKAGE__.core.navigation.rememberNavigator
import __FEATURE_PACKAGE__.navigation.__FEATURE_LOWER_CAMEL__Entry
import __FEATURE_PACKAGE__.navigation.__NAME__NavKey

/** App 的導航起點：依畫面堆疊顯示各功能的畫面，第一個畫面是 [__NAME__NavKey]。 */
@Composable
fun AppNavHost(modifier: Modifier = Modifier) {
    val navigator = rememberNavigator(startKey = __NAME__NavKey)
    NavDisplay(
        backStack = navigator.backStack,
        modifier = modifier,
        onBack = navigator::goBack,
        entryDecorators = listOf(
            rememberSaveableStateHolderNavEntryDecorator(),
            rememberViewModelStoreNavEntryDecorator()
        ),
        entryProvider = entryProvider {
            __FEATURE_LOWER_CAMEL__Entry(navigator)
        }
    )
}
