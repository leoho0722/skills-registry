//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import SwiftData

/// __NAME__ 的資料存取操作，只使用呼叫端傳入的 `context`，何時提交由呼叫端決定
enum __NAME__Records {

}

// MARK: - Internal Method

extension __NAME__Records {

    /// 新增一筆資料；替換為實際操作並改寫此說明
    ///
    /// - Parameters:
    ///   - record: 要新增的資料
    ///   - context: 呼叫端已開啟的資料存取範圍
    static func insert(_ record: __NAME__Record, in context: ModelContext) {
        context.insert(record)
    }
}

// MARK: - Private Method

private extension __NAME__Records {

}
