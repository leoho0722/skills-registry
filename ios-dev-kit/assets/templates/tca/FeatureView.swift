//
//  __FILE_NAME__
//  __PROJECT__
//
//  Created by __AUTHOR__ on __DATE__.
//

import ComposableArchitecture
import SwiftUI

/// __NAME__ 畫面，替換時改寫成這個畫面給使用者看什麼、做什麼。
struct __NAME__View: View {

    // MARK: - Properties

    /// 畫面的狀態與事件來源，由父層或 App 進入點建立後傳入。
    @Bindable var store: StoreOf<__NAME__Feature>

    // MARK: - Body

    /// 畫面骨架，只放容器與子畫面，內容一律抽到 Private Views。
    var body: some View {
        Text("__NAME__")
            .task {
                await store.send(.view(.task)).finish()
            }
    }
}

// MARK: - Private Views

private extension __NAME__View {

}

// MARK: - Nested Types

extension __NAME__View {

}

// MARK: - Private Method

private extension __NAME__View {

}

// MARK: - Preview

#Preview {
    __NAME__View(
        store: Store(initialState: __NAME__Feature.State()) {
            __NAME__Feature()
        }
    )
}
