//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import ComposableArchitecture
import Foundation

// MARK: - DependencyKey

/// 把 `__NAME__ServiceProtocol` 註冊進 TCA 依賴系統：正式 App 用正式實作，Preview 用 stub；
/// 測試不在此宣告，由各測試以 `withDependencies` 注入 mock，漏注入時 TestStore 會直接失敗
enum __NAME__ServiceKey: DependencyKey {

    /// 正式 App 使用的實作，所需的 Client / Store 在此以 `@Dependency` 取得後傳入 init
    static var liveValue: any __NAME__ServiceProtocol {
        __NAME__Service()
    }

    #if DEBUG

    /// Preview 使用的 stub，固定回傳假資料
    static var previewValue: any __NAME__ServiceProtocol {
        Preview__NAME__Service()
    }

    #endif
}

// MARK: - DependencyValues

extension DependencyValues {

    /// 供 reducer 以 `@Dependency(\.__NAME_LOWER_CAMEL__Service)` 取得的 __NAME__ Service
    var __NAME_LOWER_CAMEL__Service: any __NAME__ServiceProtocol {
        get { self[__NAME__ServiceKey.self] }
        set { self[__NAME__ServiceKey.self] = newValue }
    }
}
