//
//  EnvironmentValues+Services.swift
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import SwiftUI

/// App 可注入的 Service 清單。一行一個 entry，依名稱字母排序；預設值一律為 Preview stub，正式實作於 App 根部以 `.environment(\.xxx, ...)` 覆寫。
extension EnvironmentValues {

    /// 示範 entry：__NAME__ 的資料來源，替換為實際 Service 並改寫此說明。
    @Entry var __NAME_LOWER_CAMEL__Service: any __NAME__ServiceProtocol = Preview__NAME__Service()
}
