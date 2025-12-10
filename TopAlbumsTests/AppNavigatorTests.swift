//
//  AppNavigatorTests.swift
//  TopAlbumsTests
//
//  Created by Filipe Pereira on 10/12/2025.
//

import CoreUI
import SwiftUI
import XCTest

@testable import TopAlbums

@MainActor
final class AppNavigatorTests: XCTestCase {

    private var navigator: AppNavigator!

    override func setUp() {
        super.setUp()
        navigator = AppNavigator()
    }

    override func tearDown() {
        navigator = nil
        super.tearDown()
    }

    func testInitialState_PathIsEmpty() {
        XCTAssertEqual(navigator.path.count, 0)
    }

    func testNavigate_AddsRouteToPath() {
        navigator.navigate(to: .albumDetail(id: "123"))

        XCTAssertEqual(navigator.path.count, 1)
    }

    func testNavigate_MultipleRoutes_AddsAllToPath() {
        navigator.navigate(to: .albumDetail(id: "123"))
        navigator.navigate(to: .albumDetail(id: "456"))

        XCTAssertEqual(navigator.path.count, 2)
    }

    func testPop_RemovesLastRoute() {
        navigator.navigate(to: .albumDetail(id: "123"))
        navigator.navigate(to: .albumDetail(id: "456"))

        navigator.pop()

        XCTAssertEqual(navigator.path.count, 1)
    }

    func testPop_OnEmptyPath_DoesNotCrash() {
        navigator.pop()

        XCTAssertEqual(navigator.path.count, 0)
    }

    func testPopToRoot_ClearsAllRoutes() {
        navigator.navigate(to: .albumDetail(id: "123"))
        navigator.navigate(to: .albumDetail(id: "456"))
        navigator.navigate(to: .albumDetail(id: "789"))

        navigator.popToRoot()

        XCTAssertEqual(navigator.path.count, 0)
    }

    func testPopToRoot_OnEmptyPath_DoesNotCrash() {
        navigator.popToRoot()

        XCTAssertEqual(navigator.path.count, 0)
    }

    func testNavigate_ThenPopToRoot_ResetsState() {
        navigator.navigate(to: .albumDetail(id: "123"))
        XCTAssertEqual(navigator.path.count, 1)

        navigator.popToRoot()
        XCTAssertEqual(navigator.path.count, 0)

        navigator.navigate(to: .albumDetail(id: "456"))
        XCTAssertEqual(navigator.path.count, 1)
    }
}

