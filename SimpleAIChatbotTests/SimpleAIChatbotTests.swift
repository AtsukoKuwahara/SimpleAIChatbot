//
//  SimpleAIChatbotTests.swift
//  SimpleAIChatbotTests
//
//  Created by Atsuko Kuwahara on 2024-11-19.
//

import XCTest
@testable import SimpleAIChatbot

final class SimpleAIChatbotTests: XCTestCase {

    override func setUpWithError() throws {
        // Setup code, called before each test method is invoked.
    }

    override func tearDownWithError() throws {
        // Cleanup code, called after each test method is invoked.
    }

    func testExample() throws {
        // Example of a functional test.
        let expectedValue = true
        let actualValue = true
        XCTAssertEqual(expectedValue, actualValue, "Expected value should match the actual value.")
    }

    func testPerformanceExample() throws {
        self.measure {
            // Code you want to measure the time of.
        }
    }
}
