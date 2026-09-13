//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import SwiftUI

@MainActor
@Observable
/// __NAME__ 功能內的畫面切換都由它決定：往下一頁、回上一頁、彈出視窗
final class __NAME__Coordinator {

    // MARK: - Properties

    /// 目前堆疊中的頁面，最後一個是正在顯示的頁面
    var path: [Route] = []

    /// 正在彈出的視窗，沒有時為 nil
    var sheet: Sheet?

    // MARK: - Init

    /// 建立 Coordinator，初始為根頁面且沒有彈出視窗
    init() {

    }
}

// MARK: - Nested Types

extension __NAME__Coordinator {

    /// 這個功能內可以前往的頁面
    enum Route: Hashable {

        /// 示範頁面，替換為實際頁面並改寫此說明
        case example
    }

    /// 這個功能內可以彈出的視窗
    enum Sheet: Identifiable {

        /// 示範視窗，替換為實際視窗並改寫此說明
        case example

        /// 以自身作為識別，供 `.sheet(item:)` 使用
        var id: Self { self }
    }
}

// MARK: - Internal Method

extension __NAME__Coordinator {

    /// 前往下一頁
    ///
    /// - Parameter route: 要前往的頁面
    func push(_ route: Route) {
        path.append(route)
    }

    /// 回到上一頁；已在根頁面時不動作
    func pop() {
        _ = path.popLast()
    }

    /// 一路回到根頁面
    func popToRoot() {
        path.removeAll()
    }

    /// 彈出視窗
    ///
    /// - Parameter sheet: 要彈出的視窗
    func present(_ sheet: Sheet) {
        self.sheet = sheet
    }

    /// 關閉目前的彈出視窗；沒有視窗時不動作
    func dismissSheet() {
        sheet = nil
    }
}

// MARK: - Destinations

extension __NAME__Coordinator {

    /// 每個頁面對應要顯示的畫面
    ///
    /// - Parameter route: 要顯示的頁面
    /// - Returns: 該頁面的畫面
    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .example:
            Text("example")
        }
    }

    /// 每個彈出視窗對應要顯示的畫面
    ///
    /// - Parameter sheet: 要顯示的視窗
    /// - Returns: 該視窗的畫面
    @ViewBuilder
    func view(for sheet: Sheet) -> some View {
        switch sheet {
        case .example:
            Text("example")
        }
    }
}

// MARK: - Private Method

private extension __NAME__Coordinator {

}
