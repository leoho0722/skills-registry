//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

#if DEBUG

import Foundation

/// 給 Preview 與測試用的 `__NAME__ServiceProtocol` 假實作，只回傳固定資料，不連線
struct Preview__NAME__Service {

    // MARK: - Properties

    // MARK: - Init

    /// 建立假實作；在正式 App 中誤用時 Debug 會立刻中止
    init() {
        assert(
            RuntimeEnvironment.allowsPreviewStub,
            "Preview__NAME__Service 只能在 Preview、UI Test 或單元測試中使用，正式 App 請在根部注入正式實作"
        )
    }
}

// MARK: - __NAME__ServiceProtocol

extension Preview__NAME__Service: __NAME__ServiceProtocol {

}

#endif
