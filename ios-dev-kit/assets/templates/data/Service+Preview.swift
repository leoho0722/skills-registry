//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

#if DEBUG

import Foundation

struct Preview__NAME__Service: __NAME__ServiceProtocol {

    // MARK: - Properties

    // MARK: - Init

    init() {
        assert(
            RuntimeEnvironment.allowsPreviewStub,
            "Preview__NAME__Service 只能在 Preview、UI Test 或單元測試中使用，正式 App 請在根部注入正式實作"
        )
    }
}

// MARK: - __NAME__ServiceProtocol

extension Preview__NAME__Service {

}

#endif
