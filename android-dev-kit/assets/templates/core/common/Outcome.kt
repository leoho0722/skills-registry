package __BASE_PACKAGE__.core.common

/** 可能失敗的操作結果：成功時帶著值，失敗時帶著這個領域的錯誤。 */
sealed interface Outcome<out T, out E> {

    /** 操作成功，結果是 [value]。 */
    data class Success<out T>(
        /** 成功得到的值。 */
        val value: T,
    ) : Outcome<T, Nothing>

    /** 操作失敗，原因是 [error]。 */
    data class Failure<out E>(
        /** 失敗的原因。 */
        val error: E,
    ) : Outcome<Nothing, E>
}

/** 成功時用 [transform] 把值換成另一個值，失敗原樣保留。 */
inline fun <T, E, R> Outcome<T, E>.map(transform: (T) -> R): Outcome<R, E> = when (this) {
    is Outcome.Success -> Outcome.Success(transform(value))
    is Outcome.Failure -> this
}

/** 失敗時用 [transform] 把錯誤換成另一個領域的錯誤，成功原樣保留。 */
inline fun <T, E, F> Outcome<T, E>.mapError(transform: (E) -> F): Outcome<T, F> = when (this) {
    is Outcome.Success -> this
    is Outcome.Failure -> Outcome.Failure(transform(error))
}

/** 成功時額外做 [action]，例如存進快取，結果原樣回傳。 */
inline fun <T, E> Outcome<T, E>.onSuccess(action: (T) -> Unit): Outcome<T, E> {
    if (this is Outcome.Success) {
        action(value)
    }
    return this
}

/** 失敗時額外做 [action]，例如記錄，結果原樣回傳。 */
inline fun <T, E> Outcome<T, E>.onFailure(action: (E) -> Unit): Outcome<T, E> {
    if (this is Outcome.Failure) {
        action(error)
    }
    return this
}
