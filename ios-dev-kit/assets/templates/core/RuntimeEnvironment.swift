//
//  RuntimeEnvironment.swift
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

/// 判斷目前執行環境，供 Preview stub 的 assert 與 App 根部決定是否注入 stub 使用
enum RuntimeEnvironment {

}

// MARK: - Computed Properties

extension RuntimeEnvironment {

    /// 是否正在 Xcode Preview 中執行
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    /// 是否由 UI Test 啟動，以 `-uiTesting` 旗標判斷
    static var isUITesting: Bool {
        CommandLine.arguments.contains("-uiTesting")
    }

    /// 是否正在跑單元測試
    static var isUnitTesting: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["XCTestConfigurationFilePath"] != nil || environment["XCTestBundlePath"] != nil
    }

    /// 是否允許使用 Preview stub：Preview、UI Test、單元測試三者任一成立即可
    static var allowsPreviewStub: Bool {
        isPreview || isUITesting || isUnitTesting
    }
}
