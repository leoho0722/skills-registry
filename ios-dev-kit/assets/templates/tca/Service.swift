//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import ComposableArchitecture

/// __NAME__ 相關操作的入口，替換時改寫成這組操作對使用者的意義；
/// 正式實作在 `liveValue`、Preview 假資料在 `previewValue`、測試預設值在 `testValue`
struct __NAME__Service: Sendable {

    // MARK: - Properties

    /// 示範操作：取得一段文字，替換為實際操作並改寫此說明
    ///
    /// - Returns: 取得的文字
    /// - Throws: 取得失敗時丟出
    var example: Example
}

// MARK: - Nested Types

extension __NAME__Service {

    /// `example` 的函式型別
    typealias Example = @Sendable () async throws(__NAME__Error) -> String
}

// MARK: - DependencyKey

extension __NAME__Service: DependencyKey {

    /// 正式 App 使用的實作，所需的 Client / Store 在此以 `@Dependency` 取得；
    /// 必須是 computed property，測試才能用 `withDependencies` 換掉 Client / Store
    static var liveValue: Self {
        Self(
            example: { "Example" }
        )
    }

    #if DEBUG

    /// Preview 使用的假資料，只回傳固定內容；在正式 App 中誤用時 Debug 會立刻中止
    static var previewValue: Self {
        assert(
            RuntimeEnvironment.allowsPreviewStub,
            "__NAME__Service.previewValue 只能在 Preview、UI Test 或單元測試中使用"
        )
        return Self(
            example: { "Preview" }
        )
    }

    #endif

    /// 測試用的預設值，每個 closure 都未實作，測試沒覆寫就呼叫會直接失敗
    static var testValue: Self {
        Self(
            example: unimplemented("__NAME__Service.example", placeholder: "")
        )
    }
}

// MARK: - Private Method

private extension __NAME__Service {

}

// MARK: - DependencyValues

extension DependencyValues {

    /// 供 reducer 以 `@Dependency(\.__NAME_LOWER_CAMEL__Service)` 取得的 __NAME__ Service
    var __NAME_LOWER_CAMEL__Service: __NAME__Service {
        get { self[__NAME__Service.self] }
        set { self[__NAME__Service.self] = newValue }
    }
}
