//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

struct __NAME__: Identifiable, Codable, Equatable, Sendable {

    // MARK: - Properties

    let id: UUID

    // MARK: - Init

    init(id: UUID = UUID()) {
        self.id = id
    }
}

// MARK: - Computed Properties

extension __NAME__ {

    var title: String {
        "Example"
    }
}
