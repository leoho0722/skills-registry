//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

/// 一筆 __NAME__ 資料，替換時改寫成這筆資料代表什麼
struct __NAME__: Identifiable, Codable, Equatable, Sendable {

    // MARK: - Properties

    /// 唯一識別碼
    let id: UUID

    // MARK: - Init

    /// 建立一筆資料；不指定識別碼時自動產生新的
    ///
    /// - Parameter id: 唯一識別碼
    init(id: UUID = UUID()) {
        self.id = id
    }
}

// MARK: - Computed Properties

extension __NAME__ {

    /// 顯示給使用者看的名稱
    var title: String {
        "Example"
    }
}
