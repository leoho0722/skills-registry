//
//  __FILE_NAME__
//  __PROJECT__UITests
//
//  Created by __AUTHOR__ on __DATE__.
//

import XCTest

/// __NAME__ 畫面的 UI 測試，以 `-uiTesting` 啟動 App 並使用假資料
final class __NAME__UITests: XCTestCase {

    // MARK: - Properties

    /// 受測的 App，每個測試重新啟動
    private var app: XCUIApplication!

    // MARK: - Lifecycle

    /// 每個測試前以假資料模式啟動 App，第一步失敗即停止
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
    }

    /// 每個測試後釋放 App
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    /// 示範測試，替換為實際案例
    func testExample() throws {
        // Given

        // When

        // Then
    }
}
