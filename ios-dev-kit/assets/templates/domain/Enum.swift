//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

enum __NAME__: __RAW_TYPE__, CaseIterable, Codable, Sendable {

    case example
}

// MARK: - Computed Properties

extension __NAME__ {

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
