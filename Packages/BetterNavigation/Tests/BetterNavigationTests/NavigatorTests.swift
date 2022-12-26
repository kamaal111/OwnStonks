//
//  NavigatorTests.swift
//  
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import XCTest
@testable import BetterNavigation

final class NavigatorTests: XCTestCase {
    func testInitializer() {
        let stack = Navigator(stack: [0, 1, 2])
        XCTAssertEqual(stack.currentScreen, 2)
    }

    func testEmptyStackInitializer() {
        let stack = Navigator(stack: [] as [Int])
        XCTAssertNil(stack.currentScreen)
    }

    func testNavigate() async {
        let stack = Navigator(stack: [0, 1, 2])
        await stack.navigate(to: 3)
        XCTAssertEqual(stack.currentScreen, 3)
        await stack.navigate(to: 420)
        XCTAssertEqual(stack.currentScreen, 420)
    }

    func testGoBack() async {
        let stack = Navigator(stack: [0, 1])
        await stack.goBack()
        XCTAssertEqual(stack.currentScreen, 0)
        await stack.goBack()
        XCTAssertNil(stack.currentScreen)
        await stack.goBack()
        XCTAssertNil(stack.currentScreen)
        await stack.navigate(to: 69)
        XCTAssertEqual(stack.currentScreen, 69)
    }
}
