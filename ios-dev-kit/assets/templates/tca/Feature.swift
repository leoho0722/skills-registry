//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import ComposableArchitecture
import Foundation

/// __NAME__ 畫面要顯示什麼、事件發生後做什麼，都由它決定；替換時改寫此說明。
@Reducer
struct __NAME__Feature {

    // MARK: - State

    /// 畫面的全部狀態，View 只讀它、不另外持有狀態。
    @ObservableState
    struct State: Equatable {

        /// 示範狀態：是否正在載入，替換為實際內容。
        var isLoading = false

        /// 示範狀態：載入完成後的內容，替換為實際內容。
        var text = ""
    }

    // MARK: - Action

    /// 畫面會發生的所有事件，依來源分成使用者操作、交給父層的結果與內部回應。
    enum Action {

        /// 使用者在畫面上的操作，View 只能送這一組。
        ///
        /// - Parameter action: 實際的操作。
        case view(View)

        /// 交給父 reducer 處理的結果，本 reducer 收到後不做事。
        ///
        /// - Parameter action: 要交給父層的結果。
        case delegate(Delegate)

        /// 示範內部回應：Service 完成後的結果，替換為實際內容。
        ///
        /// - Parameter result: 成功或失敗。
        case exampleResponse(Result<String, any Error>)

        /// 使用者在畫面上的操作，以「發生了什麼」命名，不用命令式。
        @CasePathable
        enum View {

            /// 畫面出現，由 `.task` 觸發；離開畫面時這裡啟動的 Effect 會自動取消。
            case task
        }

        /// 交給父 reducer 的結果。
        @CasePathable
        enum Delegate: Equatable {

            /// 示範：本畫面的工作完成，替換為實際內容。
            case finished
        }
    }

    // MARK: - Dependencies

    /// 示範依賴：本畫面用到的 Service，由 TCA 依賴系統提供，替換為實際內容。
    @Dependency(\.__SERVICE_LOWER_CAMEL__Service)
    private var service

    // MARK: - Body

    /// 只負責組合 reducer，本畫面自己的邏輯在 `core(state:action:)`。
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
}

// MARK: - Nested Types

extension __NAME__Feature {

}

// MARK: - Private Method

private extension __NAME__Feature {

    /// 依收到的 Action 更新 State，並回傳要執行的 Effect。
    ///
    /// - Parameters:
    ///   - state: 目前的畫面狀態，直接就地修改。
    ///   - action: 這次收到的事件。
    /// - Returns: 接下來要執行的 Effect，沒有就回 `.none`。
    func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .view(.task):
            state.isLoading = true
            return .run { send in
                do {
                    let value = try await service.example()
                    await send(.exampleResponse(.success(value)))
                } catch {
                    await send(.exampleResponse(.failure(error)))
                }
            }

        case let .exampleResponse(.success(value)):
            state.isLoading = false
            state.text = value
            return .send(.delegate(.finished))

        case .exampleResponse(.failure):
            state.isLoading = false
            return .none

        case .delegate:
            return .none
        }
    }
}
