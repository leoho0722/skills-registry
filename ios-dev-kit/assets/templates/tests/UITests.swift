//
//  __FILE_NAME__
//  __PROJECT__UITests
//
//  Created by __AUTHOR__ on __DATE__.
//

import XCTest

/// __NAME__ 畫面的 UI 測試，以 `-uiTesting` 啟動 App 並使用假資料
@MainActor
final class __NAME__UITests: XCTestCase {

    /// 驗證示範情境的結果；替換為實際案例並改寫此說明，名稱依「test方法或行為_情境_預期」，情境與預期用正體中文
    func testExample() throws {
        // Given
        let app = launchApp()

        // When

        // Then
    }
}

// MARK: - XCTestCase

extension __NAME__UITests {

    /// 每個測試前設定第一個失敗即停止，後續步驟不再執行
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    /// 每個測試後清理測試留下的狀態；沒有需要清理的資源時連同此方法刪除，保留時改寫此說明
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
}

// MARK: - Private Method

private extension __NAME__UITests {

    /// 以假資料模式啟動受測的 App
    ///
    /// - Returns: 已啟動的 App
    func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        return app
    }
}
