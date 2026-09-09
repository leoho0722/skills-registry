//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

struct __NAME__FormatStyle {

    // MARK: - Properties

    // MARK: - Init

    init() {

    }
}

// MARK: - FormatStyle

extension __NAME__FormatStyle: FormatStyle {

    func format(_ value: __VALUE_TYPE__) -> String {
        ""
    }
}

// MARK: - Convenience

extension FormatStyle where Self == __NAME__FormatStyle {

    static var __NAME_LOWER_CAMEL__: __NAME__FormatStyle {
        __NAME__FormatStyle()
    }
}
