package __BASE_PACKAGE__.core.domain

import __BASE_PACKAGE__.core.common.Outcome
import __BASE_PACKAGE__.core.model.__ERROR__
import javax.inject.Inject

/** __NAME__ 流程，替換時改寫成這個流程替使用者完成什麼、組合了哪些 Repository。 */
class __NAME__UseCase @Inject constructor() {

    /** 執行流程，成功時回傳產出，失敗時為 [__ERROR__]。替換時改寫參數、回傳值與此說明。 */
    suspend operator fun invoke(): Outcome<Unit, __ERROR__> = Outcome.Success(Unit)
}
