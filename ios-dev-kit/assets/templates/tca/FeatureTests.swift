//
//  __FILE_NAME__
//  __PROJECT__Tests
//
//  Created by __AUTHOR__ on __DATE__.
//

import ComposableArchitecture
import Testing

@testable import __PROJECT__

/// `__NAME__Feature` 的單元測試，以 TestStore 逐步驗證每個 Action 造成的狀態變化與後續 Action。
@MainActor
struct __NAME__FeatureTests {

    // MARK: - Properties

    // MARK: - Tests

    /// 示範測試，替換為實際案例並依「行為_情境_預期」命名。
    @Test
    func task_serviceSucceeds_notifiesFinished() async {
        // Given
        let service = Mock__SERVICE__Service()
        let store = TestStore(initialState: __NAME__Feature.State()) {
            __NAME__Feature()
        } withDependencies: {
            $0.__SERVICE_LOWER_CAMEL__Service = service
        }

        // When
        await store.send(.view(.task)) {
            $0.isLoading = true
        }

        // Then
        await store.receive(\.exampleResponse.success) {
            $0.isLoading = false
            $0.text = "stub"
        }
        await store.receive(\.delegate.finished)
        #expect(service.exampleCallCount == 1)
    }
}
