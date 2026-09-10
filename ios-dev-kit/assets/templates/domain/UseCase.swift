//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

// MARK: - Protocol

/// __NAME__ 這個跨 Service 流程的入口，替換時改寫成這個流程對使用者的意義。
protocol __NAME__UseCaseProtocol: Sendable {

    /// 執行整個流程。
    ///
    /// - Throws: 流程中任一步驟失敗時丟出該步驟的錯誤。
    func execute() async throws
}

// MARK: - Implementation

/// `__NAME__UseCaseProtocol` 的正式實作，組合多個 Service 完成流程。
struct __NAME__UseCase {

    // MARK: - Properties

    // MARK: - Init

    /// 建立流程實作，所需的 Service 由此注入。
    init() {

    }
}

// MARK: - __NAME__UseCaseProtocol

extension __NAME__UseCase: __NAME__UseCaseProtocol {

    /// 依序呼叫各 Service 完成流程，替換時寫出步驟順序與中途失敗的處理。
    ///
    /// - Throws: 任一步驟失敗時丟出該步驟的錯誤，已完成的步驟不回復。
    func execute() async throws {

    }
}

// MARK: - Private Method

private extension __NAME__UseCase {

}
