package __PACKAGE__

import androidx.annotation.MainThread
import androidx.annotation.StringRes
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

/** __NAME__ 畫面的狀態與邏輯：載入畫面資料、處理重試。替換時改寫此說明。 */
@HiltViewModel
class __NAME__ViewModel @Inject constructor() : ViewModel() {

    /** 畫面目前的狀態，給畫面讀，只有自己能改。 */
    val uiState: StateFlow<__NAME__UiState>
        field = MutableStateFlow<__NAME__UiState>(__NAME__UiState.Loading)

    /** 是否已經開始載入，讓 [initialize] 重複呼叫也只載入一次。 */
    private var isInitialized = false

    /** 正在進行的載入，重新載入前先取消它。 */
    private var loadJob: Job? = null

    /**
     * 開始載入畫面資料，重複呼叫只有第一次有效。
     *
     * 只在主執行緒呼叫，畫面顯示時由 [__NAME__Screen] 呼叫。
     */
    @MainThread
    fun initialize() {
        if (isInitialized) return
        isInitialized = true
        load()
    }

    /** 載入失敗後重新載入。 */
    fun retry() {
        load()
    }

    /** 取消上一次還沒完成的載入，重新取得畫面資料。替換時改寫成向 Repository 取資料並處理失敗。 */
    private fun load() {
        loadJob?.cancel()
        loadJob = viewModelScope.launch {
            uiState.value = __NAME__UiState.Loading
            uiState.value = __NAME__UiState.Success(title = "__NAME__")
        }
    }
}

/** __NAME__ 畫面可能呈現的樣子。 */
sealed interface __NAME__UiState {

    /** 正在載入。 */
    data object Loading : __NAME__UiState

    /** 載入完成，替換時改成畫面要顯示的資料。 */
    data class Success(
        /** 示範欄位，替換時改寫此說明。 */
        val title: String,
    ) : __NAME__UiState

    /** 載入失敗。 */
    data class Error(
        /** 要顯示給使用者的錯誤訊息。 */
        @StringRes val messageRes: Int,
    ) : __NAME__UiState
}
