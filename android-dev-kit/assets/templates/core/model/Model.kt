package __BASE_PACKAGE__.core.model

import kotlinx.serialization.Serializable

/** __NAME__ 的資料，替換時改寫成這筆資料代表什麼。 */
@Serializable
data class __NAME__(
    /** 示範欄位，替換為實際欄位並改寫此說明；識別碼改用 value class。 */
    val id: String,
)
