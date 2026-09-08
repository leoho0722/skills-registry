//
//  __FILE_NAME__
//  __PROJECT__UITests
//
//  Created by __AUTHOR__ on __DATE__.
//

import XCTest

final class __NAME__UITests: XCTestCase {

    // MARK: - Properties

    private var app: XCUIApplication!

    // MARK: - Lifecycle

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func testExample() throws {
        // Given

        // When

        // Then
    }
}
