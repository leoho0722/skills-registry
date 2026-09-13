//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

// MARK: - Protocol

/// __NAME__ 相關操作的入口，替換時改寫成這組操作對使用者的意義
protocol __NAME__ServiceProtocol: Sendable {

}

// MARK: - Implementation

/// `__NAME__ServiceProtocol` 的正式實作，實際連線到伺服器或本機儲存
struct __NAME__Service {

    // MARK: - Properties

    // MARK: - Init

    /// 建立正式實作，所需的 Client / Store 由此注入
    init() {

    }
}

// MARK: - __NAME__ServiceProtocol

extension __NAME__Service: __NAME__ServiceProtocol {

}

// MARK: - Private Method

private extension __NAME__Service {

}
