//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

/// __NAME__ 的所有可能狀態，部分狀態附帶資料；替換時改寫成這個狀態機代表什麼。
enum __NAME__: Equatable, Sendable {

    /// 示範 case，不帶資料；替換為實際的值並改寫此說明。
    case example

    /// 示範 case，附帶資料；替換為實際的值與資料型別並改寫此說明。
    ///
    /// - Parameter string: 示範用的附帶資料。
    case exampleWithValue(String)
}

// MARK: - Nested Types

extension __NAME__ {

    /// JSON 欄位名稱：`type` 放 case 名稱，`value` 放附帶的資料。
    enum CodingKeys: String, CodingKey {

        /// 哪一個 case。
        case type

        /// 該 case 附帶的資料，沒有資料的 case 不寫這個欄位。
        case value
    }
}

// MARK: - Computed Properties

extension __NAME__ {

    /// 顯示給使用者看的名稱。
    var title: String {
        switch self {
        case .example:
            "Example"
        case .exampleWithValue(let value):
            value
        }
    }
}

// MARK: - Internal Method

extension __NAME__ {

}

// MARK: - Codable

extension __NAME__: Codable {

    /// 從 JSON 還原：依 `type` 欄位決定是哪個 case，需要資料的 case 再讀 `value`。
    ///
    /// - Parameter decoder: 提供 JSON 內容的解碼器。
    /// - Throws: `type` 不是已知的 case 時丟 `DecodingError.dataCorrupted`。
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "example":
            self = .example
        case "exampleWithValue":
            self = .exampleWithValue(try container.decode(String.self, forKey: .value))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown type: \(type)"
            )
        }
    }

    /// 轉成 JSON：`type` 放 case 名稱，有資料的 case 再寫 `value`。
    ///
    /// - Parameter encoder: 接收 JSON 內容的編碼器。
    /// - Throws: 底層編碼失敗時丟出。
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .example:
            try container.encode("example", forKey: .type)
        case .exampleWithValue(let value):
            try container.encode("exampleWithValue", forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}

// MARK: - Private Method

private extension __NAME__ {

}
