//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

enum __NAME__: Equatable, Sendable {

    case example

    case exampleWithValue(String)

}

// MARK: - Nested Types

extension __NAME__ {

    enum CodingKeys: String, CodingKey {

        case type

        case value
    }
}

// MARK: - Computed Properties

extension __NAME__ {

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
