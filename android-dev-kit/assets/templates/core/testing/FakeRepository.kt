package __BASE_PACKAGE__.core.testing.repository

import __BASE_PACKAGE__.core.common.Outcome
import __BASE_PACKAGE__.core.data.__NAME__Repository
import __BASE_PACKAGE__.core.model.__NAME__Error

/** 測試用的 [__NAME__Repository]：記錄每次呼叫，回傳測試預先設定的結果。 */
class Fake__NAME__Repository : __NAME__Repository {

    /** `example` 每次收到的參數，依呼叫順序排列。 */
    val exampleCalls: List<String>
        field = mutableListOf()

    /** `example` 要回傳的結果，測試在呼叫前設定。 */
    var exampleResult: Outcome<Unit, __NAME__Error> = Outcome.Success(Unit)

    /** 記錄 [argument]，然後回傳 [exampleResult]。 */
    override suspend fun example(argument: String): Outcome<Unit, __NAME__Error> {
        exampleCalls += argument
        return exampleResult
    }
}
