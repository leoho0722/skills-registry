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

    // MARK: - Init

    init() {

    }
}

// MARK: - Nested Types

extension __NAME__Coordinator {

    enum Route: Hashable {

        case example
    }

    enum Sheet: Identifiable {

        case example

        var id: Self { self }
    }
}

// MARK: - Internal Method

extension __NAME__Coordinator {

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func present(_ sheet: Sheet) {
        self.sheet = sheet
    }

    func dismissSheet() {
        sheet = nil
    }
}

// MARK: - Destinations

extension __NAME__Coordinator {

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .example:
            Text("example")
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

}
