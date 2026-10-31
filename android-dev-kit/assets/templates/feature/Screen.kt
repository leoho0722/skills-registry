package __PACKAGE__

import androidx.annotation.StringRes
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import __MODULE_PACKAGE__.R
import __BASE_PACKAGE__.core.designsystem.AppTheme

/**
 * __NAME__ 畫面：顯示 [__NAME__ViewModel] 的狀態，並把使用者的操作交給它。替換時改寫此說明。
 *
 * 按下返回時呼叫 [onBackClick]，去哪裡由導航決定。
 */
@Composable
fun __NAME__Screen(
    onBackClick: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: __NAME__ViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) {
        viewModel.initialize()
    }
    __NAME__Screen(
        uiState = uiState,
        onRetryClick = viewModel::retry,
        onBackClick = onBackClick,
        modifier = modifier
    )
}

/**
 * __NAME__ 畫面的內容，依 [uiState] 顯示載入中、內容或錯誤。替換時改寫此說明。
 *
 * 載入失敗時按下重試呼叫 [onRetryClick]，按下返回呼叫 [onBackClick]。
 */
@Composable
fun __NAME__Screen(
    uiState: __NAME__UiState,
    onRetryClick: () -> Unit,
    onBackClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Box(modifier = modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        when (uiState) {
            __NAME__UiState.Loading -> LoadingContent()

            is __NAME__UiState.Success -> SuccessContent(
                title = uiState.title,
                onBackClick = onBackClick
            )

            is __NAME__UiState.Error -> ErrorContent(
                messageRes = uiState.messageRes,
                onRetryClick = onRetryClick
            )
        }
    }
}

/** 載入中，顯示轉圈圈。 */
@Composable
private fun LoadingContent() {
    CircularProgressIndicator()
}

/** 載入完成，顯示 [title] 與返回按鈕，按下返回呼叫 [onBackClick]。替換時改寫。 */
@Composable
private fun SuccessContent(title: String, onBackClick: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(text = title)
        TextButton(onClick = onBackClick) {
            Text(text = stringResource(R.string.__BACK_TEXT_RES__))
        }
    }
}

/** 載入失敗，顯示 [messageRes] 的訊息與重試按鈕，按下重試呼叫 [onRetryClick]。 */
@Composable
private fun ErrorContent(@StringRes messageRes: Int, onRetryClick: () -> Unit) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(AppTheme.spacing.medium)
    ) {
        Text(text = stringResource(messageRes))
        Button(onClick = onRetryClick) {
            Text(text = stringResource(R.string.__RETRY_TEXT_RES__))
        }
    }
}

/** 載入中的樣子。 */
@Preview(showBackground = true)
@Composable
private fun __NAME__ScreenLoadingPreview() {
    AppTheme {
        __NAME__Screen(uiState = __NAME__UiState.Loading, onRetryClick = {}, onBackClick = {})
    }
}

/** 載入完成的樣子。 */
@Preview(showBackground = true)
@Composable
private fun __NAME__ScreenSuccessPreview() {
    AppTheme {
        __NAME__Screen(
            uiState = __NAME__UiState.Success(title = "__NAME__"),
            onRetryClick = {},
            onBackClick = {}
        )
    }
}

/** 載入失敗的樣子。 */
@Preview(showBackground = true)
@Composable
private fun __NAME__ScreenErrorPreview() {
    AppTheme {
        __NAME__Screen(
            uiState = __NAME__UiState.Error(messageRes = R.string.__ERROR_MESSAGE_RES__),
            onRetryClick = {},
            onBackClick = {}
        )
    }
}
