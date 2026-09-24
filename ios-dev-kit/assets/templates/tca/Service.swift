//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

/// __NAME__ 相關操作的入口，替換時改寫成這組操作對使用者的意義；
/// 正式實作在 `liveValue`、測試預設值在 `testValue`、Preview 假資料在 `previewValue`
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
