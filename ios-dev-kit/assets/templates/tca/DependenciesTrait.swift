//
//  DependenciesTrait.swift
//  __PROJECT__Tests
//
//  Created by __AUTHOR__ on __DATE__.
//

import Dependencies
import Testing

/// 包住整個測試注入依賴的 Swift Testing trait，取代 `DependenciesTestSupport` 的 `.dependencies(_:)`，語意與函式庫相同
struct DependenciesTrait: TestTrait {

    // MARK: - Properties

    /// 是否位於最外層的 trait，最外層才換成新的依賴，內層只疊加覆寫
    @TaskLocal static var isRoot = true

    /// 設定這次要注入的依賴
    let updateValues: @Sendable (inout DependencyValues) async throws -> Void
}

// MARK: - SuiteTrait

extension DependenciesTrait: SuiteTrait {

    /// 是否套用到 `@Suite` 底下的每個測試
    var isRecursive: Bool {
        true
    }
}

// MARK: - TestScoping

extension DependenciesTrait: TestScoping {

    /// 在注入的依賴下執行測試，最外層先換成新的 `DependencyValues`，讓每個測試有自己的依賴快取
    ///
    /// - Parameters:
    ///   - test: 要執行的測試或測試型別
    ///   - testCase: 要執行的測試案例，套用在測試型別時為 `nil`
    ///   - function: 執行測試本體的函式
    /// - Throws: 設定依賴或測試本體丟出的錯誤
    func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @concurrent @Sendable () async throws -> Void
    ) async throws {
        try await withDependencies {
            if Self.isRoot {
                $0 = DependencyValues()
            }
            try await updateValues(&$0)
        } operation: {
            try await Self.$isRoot.withValue(false) {
                try await function()
            }
        }
    }
}

// MARK: - Convenience

extension Trait where Self == DependenciesTrait {

    /// 讓測試能寫 `@Suite(.dependencies(TestEnvironment.fixDateEnvironment))` 的便利存取子
    ///
    /// - Parameter updateValues: 設定這組依賴的函式
    /// - Returns: 注入這組依賴的 trait
    static func dependencies(
        _ updateValues: @escaping @Sendable (inout DependencyValues) async throws -> Void
    ) -> Self {
        DependenciesTrait(updateValues: updateValues)
    }
}
