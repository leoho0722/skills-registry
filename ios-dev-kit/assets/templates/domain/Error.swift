//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

/// __NAME__ 相關操作可能發生的錯誤，替換時只保留這個領域會出現的 case
enum __NAME__Error: Error {

    /// 找不到指定的資料
    ///
    /// - Parameter id: 查詢時用的識別碼
    case notFound(id: String)

    /// 使用者輸入不合法
    ///
    /// - Parameters:
    ///   - field: 出問題的欄位名稱
    ///   - reason: 不合法的原因，可直接顯示給使用者
    case invalidInput(field: String, reason: String)

    /// 網路連不上或伺服器回錯
    ///
    /// - Parameter underlying: 原始錯誤，供除錯用
    case network(underlying: any Error)

    /// 伺服器回的資料格式不符預期
    ///
    /// - Parameter underlying: 原始錯誤，供除錯用
    case decoding(underlying: any Error)
}

// MARK: - LocalizedError

extension __NAME__Error: LocalizedError {

    /// 顯示給使用者的錯誤訊息；輸入錯誤直接顯示原因，其餘顯示本地化的通用訊息
    var errorDescription: String? {
        switch self {
        case .notFound:
            String(localized: "error.__NAME_LOWER_CAMEL__.notFound")
        case .invalidInput(_, let reason):
            reason
        case .network, .decoding:
            String(localized: "error.__NAME_LOWER_CAMEL__.unavailable")
        }
    }
}
