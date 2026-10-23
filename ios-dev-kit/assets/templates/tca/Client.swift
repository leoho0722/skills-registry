//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import ComposableArchitecture

// MARK: - Protocol

/// __NAME__ 提供的技術能力，替換時改寫成這組能力的用途
protocol __NAME__ClientProtocol: Sendable {

}

// MARK: - Implementation

/// `__NAME__ClientProtocol` 的正式實作，實際連線到伺服器或本機儲存
struct __NAME__Client {

    // MARK: - Properties

    // MARK: - Init

    /// 建立正式實作，所需的設定由此注入
    init() {

    }
}

// MARK: - __NAME__ClientProtocol

extension __NAME__Client: __NAME__ClientProtocol {

}

// MARK: - Private Method

private extension __NAME__Client {

}

// MARK: - DependencyKey

/// 把 `__NAME__ClientProtocol` 註冊進 TCA 依賴系統：正式 App 用正式實作，Preview 用 stub；
/// 不宣告測試值，測 Service 時漏了以 `withDependencies` 注入 mock 就會直接失敗
enum __NAME__ClientKey: DependencyKey {

    /// 正式 App 使用的實作，init 所需的設定在此傳入
    static var liveValue: any __NAME__ClientProtocol {
        __NAME__Client()
    }

    #if DEBUG

    /// Preview 使用的 stub，固定回傳假資料
    static var previewValue: any __NAME__ClientProtocol {
        Preview__NAME__Client()
    }

    #endif
}

// MARK: - DependencyValues

extension DependencyValues {

    /// 供 Service 的 `liveValue` 以 `@Dependency(\.__NAME_LOWER_CAMEL__Client)` 取得的 __NAME__ Client
    var __NAME_LOWER_CAMEL__Client: any __NAME__ClientProtocol {
        get { self[__NAME__ClientKey.self] }
        set { self[__NAME__ClientKey.self] = newValue }
    }
}

#if DEBUG

// MARK: - Preview

/// 給 Preview 用的 `__NAME__ClientProtocol` 假實作，只回傳固定資料，不連線
struct Preview__NAME__Client {

    // MARK: - Properties

    // MARK: - Init

    /// 建立假實作；在正式 App 中誤用時 Debug 會立刻中止
    init() {
        assert(
            RuntimeEnvironment.allowsPreviewStub,
            "Preview__NAME__Client 只能在 Preview、UI Test 或單元測試中使用"
        )
    }
}

// MARK: - __NAME__ClientProtocol

extension Preview__NAME__Client: __NAME__ClientProtocol {

}

#endif
