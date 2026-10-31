package __BASE_PACKAGE__.core.testing

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.TestDispatcher
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.rules.TestWatcher
import org.junit.runner.Description

/** 把主執行緒的 dispatcher 換成 [testDispatcher]，讓 `viewModelScope` 的工作在測試中立刻執行。 */
@OptIn(ExperimentalCoroutinesApi::class)
class MainDispatcherRule(
    /** 測試期間取代主執行緒的 dispatcher。 */
    val testDispatcher: TestDispatcher = UnconfinedTestDispatcher(),
) : TestWatcher() {

    /** 每個測試開始前換掉主執行緒的 dispatcher。 */
    override fun starting(description: Description) {
        Dispatchers.setMain(testDispatcher)
    }

    /** 每個測試結束後換回原本的 dispatcher。 */
    override fun finished(description: Description) {
        Dispatchers.resetMain()
    }
}
