package __BASE_PACKAGE__.core.model

/** 讀寫 __NAME__ 資料時可能發生的錯誤，替換時改寫成這類資料的失敗情況。 */
sealed interface __NAME__Error {

    /** 找不到 [id] 對應的資料。 */
    data class NotFound(
        /** 查詢時用的識別碼。 */
        val id: String,
    ) : __NAME__Error

    /** 使用者輸入的 [field] 不合規則，原因是 [reason]。 */
    data class InvalidInput(
        /** 不合規則的欄位。 */
        val field: String,
        /** 為什麼不合規則。 */
        val reason: String,
    ) : __NAME__Error

    /** 網路連不上或伺服器沒有正常回應。 */
    data class Network(
        /** 底層的原始例外，除錯用。 */
        val cause: Throwable,
    ) : __NAME__Error

    /** 伺服器回傳的資料格式和預期不同。 */
    data class Decoding(
        /** 底層的原始例外，除錯用。 */
        val cause: Throwable,
    ) : __NAME__Error
}
