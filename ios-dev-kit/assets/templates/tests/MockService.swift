//
//  __FILE_NAME__
//  __PROJECT__Tests
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation
@testable import __PROJECT__

/// 以 lock-free 的方式記錄呼叫；測試皆為單執行緒存取，故標記 `@unchecked Sendable`。
final class Mock__NAME__Service: @unchecked Sendable {

    // MARK: - Properties

    private(set) var exampleCallCount = 0
    
    private(set) var exampleReceivedArguments: [String] = []
    
    var exampleResult: Result<Void, any Error> = .success(())

    // MARK: - Init

    init() {

    }
}

// MARK: - __NAME__ServiceProtocol

extension Mock__NAME__Service: __NAME__ServiceProtocol {

    func example(_ argument: String) async throws {
        exampleCallCount += 1
        exampleReceivedArguments.append(argument)
        try exampleResult.get()
    }
}
