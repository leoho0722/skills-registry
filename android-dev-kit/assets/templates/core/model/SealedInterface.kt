package __BASE_PACKAGE__.core.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/** __NAME__ 可能的情況，替換時改寫成這組情況的意義。 */
@Serializable
sealed interface __NAME__ {

    /** 示範：不帶資料的情況，替換時改寫此說明。 */
    @Serializable
    @SerialName("example")
    data object Example : __NAME__

    /** 示範：帶資料的情況，替換時改寫此說明。 */
    @Serializable
    @SerialName("exampleWithValue")
    data class ExampleWithValue(
        /** 示範資料，替換時改寫此說明。 */
        val value: String,
    ) : __NAME__
}
