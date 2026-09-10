//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

/// 把 `__VALUE_TYPE__` 轉成畫面上顯示的文字，規則見 `format(_:)`；替換時改寫此說明。
struct __NAME__FormatStyle {

    // MARK: - Properties

    // MARK: - Init

    /// 建立此格式化樣式，`Locale`、`TimeZone` 等環境設定由此注入。
    init() {

    }
}

// MARK: - FormatStyle

extension __NAME__FormatStyle: FormatStyle {

    /// 把值轉成顯示文字，替換時說明轉換規則與範例輸出。
    ///
    /// - Parameter value: 要格式化的值。
    /// - Returns: 顯示在畫面上的文字。
    func format(_ value: __VALUE_TYPE__) -> String {
        ""
    }
}

// MARK: - Convenience

extension FormatStyle where Self == __NAME__FormatStyle {

    /// 讓呼叫端能寫 `.formatted(.__NAME_LOWER_CAMEL__)` 的便利存取子。
    static var __NAME_LOWER_CAMEL__: __NAME__FormatStyle {
        __NAME__FormatStyle()
    }
}
