//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import ComposableArchitecture
import Foundation

// MARK: - DependencyKey

extension __NAME__Service: DependencyKey {

    /// 正式 App 使用的實作，所需的 Client / Store 在此以 `@Dependency` 取得；
    /// 必須是 computed property，測試才能用 `withDependencies` 換掉 Client / Store
    static var liveValue: Self {
        Self(example: { "Example" })
    }

    /// 測試用的預設值，每個 closure 都未實作，測試沒覆寫就呼叫會直接失敗
    static var testValue: Self {
        Self(example: unimplemented("__NAME__Service.example", placeholder: ""))
    }
}

// MARK: - DependencyValues

extension DependencyValues {

    /// 供 reducer 以 `@Dependency(\.__NAME_LOWER_CAMEL__Service)` 取得的 __NAME__ Service
    var __NAME_LOWER_CAMEL__Service: __NAME__Service {
        get { self[__NAME__Service.self] }
        set { self[__NAME__Service.self] = newValue }
    }
}
