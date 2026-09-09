//
//  RuntimeEnvironment.swift
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import Foundation

/// 判斷目前執行環境，供 Preview stub 的 assert 與 App 根部決定是否注入 stub 使用。
enum RuntimeEnvironment {

}

// MARK: - Computed Properties

extension RuntimeEnvironment {

    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    static var isUITesting: Bool {
        CommandLine.arguments.contains("-uiTesting")
    }

    static var isUnitTesting: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["XCTestConfigurationFilePath"] != nil || environment["XCTestBundlePath"] != nil
    }

    static var allowsPreviewStub: Bool {
        isPreview || isUITesting || isUnitTesting
    }
}
