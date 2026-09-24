//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import ComposableArchitecture
import Foundation

// MARK: - DependencyKey

/// 把 `__NAME__Protocol` 註冊進 TCA 依賴系統：正式 App 用正式實作，Preview 用 stub；
/// 不宣告測試值，測 Service 時漏了以 `withDependencies` 注入 mock 就會直接失敗
enum __NAME__Key: DependencyKey {

    /// 正式 App 使用的實作，所需的其他依賴在此以 `@Dependency` 取得後傳入 init
    static var liveValue: any __NAME__Protocol {
        __NAME__()
    }

    #if DEBUG

    /// Preview 使用的 stub，固定回傳假資料
    static var previewValue: any __NAME__Protocol {
        Preview__NAME__()
    }

    #endif
}

// MARK: - DependencyValues

extension DependencyValues {

    /// 供 Service 的 `liveValue` 以 `@Dependency(\.__NAME_LOWER_CAMEL__)` 取得的 __NAME__
    var __NAME_LOWER_CAMEL__: any __NAME__Protocol {
        get { self[__NAME__Key.self] }
        set { self[__NAME__Key.self] = newValue }
    }
}
