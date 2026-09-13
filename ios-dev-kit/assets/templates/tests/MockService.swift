//
//  __FILE_NAME__
//  __PROJECT__Tests
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

@testable import __PROJECT__

/// 以 lock-free 的方式記錄呼叫；測試皆為單執行緒存取，故標記 `@unchecked Sendable`
final class Mock__NAME__Service: @unchecked Sendable {

    // MARK: - Properties

    /// `example(_:)` 被呼叫的次數
    private(set) var exampleCallCount = 0

    /// `example(_:)` 每次收到的參數，依呼叫順序排列
    private(set) var exampleReceivedArguments: [String] = []

    /// `example(_:)` 要回傳的結果，測試端在呼叫前設定
    var exampleResult: Result<Void, any Error> = .success(())

    // MARK: - Init

    /// 建立 mock，所有計數歸零、結果預設為成功
    init() {

    }
}

// MARK: - __NAME__ServiceProtocol

extension Mock__NAME__Service: __NAME__ServiceProtocol {

    /// 記錄呼叫次數與參數，然後回傳測試端預先設定的結果
    ///
    /// - Parameter argument: 呼叫端傳入的參數，會被記錄
    /// - Throws: `exampleResult` 設為失敗時丟出其中的錯誤
    func example(_ argument: String) async throws {
        exampleCallCount += 1
        exampleReceivedArguments.append(argument)
        try exampleResult.get()
    }
}
