package __BASE_PACKAGE__.core.data

import javax.inject.Inject

/** __NAME__ 資料的唯一入口，替換時改寫成這份資料對使用者的意義。 */
interface __NAME__Repository

/** 替換時改成說明資料來源的名稱與說明，例如 `OfflineFirst__NAME__Repository`；找不到更好的名稱才用 `Default`。 */
class Default__NAME__Repository @Inject constructor() : __NAME__Repository
