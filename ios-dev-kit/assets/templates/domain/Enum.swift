//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

/// __NAME__ 的所有可能值，替換時改寫成這個分類代表什麼
enum __NAME__: __RAW_TYPE__, CaseIterable, Codable, Sendable {

    /// 示範 case，替換為實際的值並改寫此說明
    case example
}

// MARK: - Computed Properties

extension __NAME__ {

    /// 顯示給使用者看的名稱
    var title: String {
        switch self {
        case .example:
            "Example"
        }
    }
}

// MARK: - Internal Method

extension __NAME__ {

}

// MARK: - Private Method

private extension __NAME__ {

}
