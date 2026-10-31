package __BASE_PACKAGE__.core.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.navigation3.runtime.NavBackStack
import androidx.navigation3.runtime.NavKey
import androidx.navigation3.runtime.rememberNavBackStack

/** App 的導航：持有畫面堆疊，前往新畫面或回到上一個畫面。 */
class Navigator(
    /** 畫面堆疊，最後一個是正在顯示的畫面。 */
    val backStack: NavBackStack<NavKey>,
) {

    /** 前往 [key] 代表的畫面。 */
    fun navigate(key: NavKey) {
        backStack.add(key)
    }

    /** 回到上一個畫面，已在第一個畫面時不動作。 */
    fun goBack() {
        if (backStack.size > 1) {
            backStack.removeLastOrNull()
        }
    }
}

/**
 * 建立並記住 [Navigator]，第一個畫面是 [startKey]。
 *
 * 畫面旋轉或 App 被系統回收後恢復時，保留原本的畫面堆疊。
 */
@Composable
fun rememberNavigator(startKey: NavKey): Navigator {
    val backStack = rememberNavBackStack(startKey)
    return remember(backStack) { Navigator(backStack) }
}
