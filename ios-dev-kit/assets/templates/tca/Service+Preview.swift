//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

#if DEBUG

import Foundation

// MARK: - DependencyKey

extension __NAME__Service {

    /// Preview 使用的假資料，只回傳固定內容；在正式 App 中誤用時 Debug 會立刻中止
    static var previewValue: Self {
        assert(
            RuntimeEnvironment.allowsPreviewStub,
            "__NAME__Service.previewValue 只能在 Preview、UI Test 或單元測試中使用"
        )
        return Self(example: { "Preview" })
    }
}

#endif
