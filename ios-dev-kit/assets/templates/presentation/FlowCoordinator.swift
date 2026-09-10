//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import SwiftUI

@MainActor
@Observable
/// __NAME__ 流程的畫面切換與跨步驟資料都由它管理，流程結束即釋放。
final class __NAME__Coordinator {

    // MARK: - Properties

    /// 已進入的步驟，最後一個是正在顯示的步驟。
    var path: [Route] = []

    /// 正在彈出的視窗，沒有時為 nil。
    var sheet: Sheet?

    /// 各步驟填入的資料，流程完成時由最後一步轉成正式資料。
    let draft = Draft()

    /// 流程結束時通知父層的回呼。
    @ObservationIgnored
    private let onFinish: (Result) -> Void

    // MARK: - Init

    /// 建立流程 Coordinator，從第一步開始。
    ///
    /// - Parameter onFinish: 流程完成或取消時呼叫，由父層負責關閉畫面。
    init(onFinish: @escaping (Result) -> Void) {
        self.onFinish = onFinish
    }
}

// MARK: - Nested Types

extension __NAME__Coordinator {

    /// 流程的每個步驟，依順序排列。
    enum Route: Hashable {

        /// 示範第一步，替換為實際步驟並改寫此說明。
        case stepOne

        /// 示範第二步，替換為實際步驟並改寫此說明。
        case stepTwo
    }

    /// 流程中可以彈出的視窗。
    enum Sheet: Identifiable {

        /// 示範視窗，替換為實際視窗並改寫此說明。
        case example

        /// 以自身作為識別，供 `.sheet(item:)` 使用。
        var id: Self { self }
    }

    /// 流程的結束方式。
    enum Result {

        /// 走完全部步驟。
        ///
        /// - Parameter output: 流程的最終產出。
        case completed(__OUTPUT_TYPE__)

        /// 使用者中途放棄。
        case cancelled
    }

    /// 跨步驟累積的資料，流程結束時隨 Coordinator 釋放。
    @Observable
    final class Draft {

        /// 示範欄位，替換為實際要收集的資料並改寫此說明。
        var example = ""
    }
}

// MARK: - Internal Method

extension __NAME__Coordinator {

    /// 完成某一步後前進，下一步依已填的資料決定。
    ///
    /// - Parameter step: 剛完成的步驟。
    /// - Note: 最後一步不呼叫本方法，改由該步驟的 ViewModel 呼叫 `finish(with:)`。
    func proceed(from step: Route) {
        guard let next = nextStep(after: step) else {
            assertionFailure("\(step) 已是最後一步，請改呼叫 finish(with:)")
            return
        }
        path.append(next)
    }

    /// 回到上一步；已在第一步時不動作。
    func pop() {
        _ = path.popLast()
    }

    /// 彈出視窗。
    ///
    /// - Parameter sheet: 要彈出的視窗。
    func present(_ sheet: Sheet) {
        self.sheet = sheet
    }

    /// 關閉目前的彈出視窗；沒有視窗時不動作。
    func dismissSheet() {
        sheet = nil
    }

    /// 結束整個流程並把結果交給父層；畫面的關閉由父層負責。
    ///
    /// - Parameter result: 完成的產出或取消。
    func finish(with result: Result) {
        onFinish(result)
    }

    /// 中途放棄流程，等同以「取消」結束。
    func cancel() {
        finish(with: .cancelled)
    }
}

// MARK: - Destinations

extension __NAME__Coordinator {

    /// 每個步驟對應要顯示的畫面。
    ///
    /// - Parameter route: 要顯示的步驟。
    /// - Returns: 該步驟的畫面。
    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .stepOne:
            Text("stepOne")
        case .stepTwo:
            Text("stepTwo")
        }
    }

    /// 每個彈出視窗對應要顯示的畫面。
    ///
    /// - Parameter sheet: 要顯示的視窗。
    /// - Returns: 該視窗的畫面。
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

    /// 某一步完成後該去哪一步；可依已填的資料跳步或分支。
    ///
    /// - Parameter step: 剛完成的步驟。
    /// - Returns: 下一步；已是最後一步時為 nil。
    /// - Note: 這是唯一允許 Coordinator 讀 draft 的地方，只做步驟排序，業務驗證仍在各步驟的 ViewModel。
    func nextStep(after step: Route) -> Route? {
        switch step {
        case .stepOne:
            .stepTwo
        case .stepTwo:
            nil
        }
    }
}
