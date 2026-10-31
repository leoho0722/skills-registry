package __BASE_PACKAGE__

import android.app.Application
import android.content.Context
import androidx.test.runner.AndroidJUnitRunner
import dagger.hilt.android.testing.HiltTestApplication

/** 以 Hilt 的測試用 Application 啟動 instrumented test，讓 `@TestInstallIn` 生效。 */
class HiltTestRunner : AndroidJUnitRunner() {

    /** 忽略原本的 [className]，改用 `HiltTestApplication` 建立 Application。 */
    override fun newApplication(
        cl: ClassLoader?,
        className: String?,
        context: Context?,
    ): Application = super.newApplication(cl, HiltTestApplication::class.java.name, context)
}
