//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import SwiftUI

@MainActor
@Observable
final class __NAME__Coordinator {

    // MARK: - Properties

    var path: [Route] = []

    var sheet: Sheet?

    let draft = Draft()

    @ObservationIgnored
    private let onFinish: (Result) -> Void

    // MARK: - Init

    init(onFinish: @escaping (Result) -> Void) {
        self.onFinish = onFinish
    }
}

// MARK: - Nested Types

extension __NAME__Coordinator {

    /// 依步驟順序排列。
    enum Route: Hashable {

        case stepOne

        case stepTwo
    }

    enum Sheet: Identifiable {

        case example

        var id: Self { self }
    }

    enum Result {

        case completed(__OUTPUT_TYPE__)

        case cancelled
    }

    /// 跨步驟累積的資料，流程結束時隨 Coordinator 釋放。
    @Observable
    final class Draft {

        var example = ""
    }
}

// MARK: - Internal Method

extension __NAME__Coordinator {

    /// 完成某一步，由 Coordinator 依 draft 決定下一步；最後一步應改呼叫 `finish(with:)`。
    func proceed(from step: Route) {
        guard let next = nextStep(after: step) else {
            assertionFailure("\(step) 已是最後一步，請改呼叫 finish(with:)")
            return
        }
        path.append(next)
    }

    func pop() {
        _ = path.popLast()
    }

    func present(_ sheet: Sheet) {
        self.sheet = sheet
    }

    func dismissSheet() {
        sheet = nil
    }

    func finish(with result: Result) {
        onFinish(result)
    }

    func cancel() {
        finish(with: .cancelled)
    }
}

// MARK: - Destinations

extension __NAME__Coordinator {

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .stepOne:
            Text("stepOne")
        case .stepTwo:
            Text("stepTwo")
        }
    }

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

    /// 步驟排序是導航邏輯，允許讀 draft 決定跳步或分支；業務驗證仍在各步驟的 ViewModel。
    func nextStep(after step: Route) -> Route? {
        switch step {
        case .stepOne:
            .stepTwo
        case .stepTwo:
            nil
        }
    }
}
