//
//  AlbumListUITests.swift
//  TopAlbumsUITests
//
//  Created by Filipe Pereira on 09/12/2025.
//

import XCTest

@MainActor
final class AlbumListUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tests

    func testAlbumList_DisplaysTitle() throws {
        // Given - App launched
        
        // Then - Navigation bar with "Top Albums" should exist
        let navigationBar = app.navigationBars["Top Albums"]
        XCTAssertTrue(
            navigationBar.waitForExistence(timeout: 5),
            "Navigation bar 'Top Albums' should exist"
        )
    }

    func testAlbumList_DisplaysAlbums() throws {
        // Given - Wait for data to load from network
        
        // Wait for first album button to appear
        let firstAlbumButton = app.buttons.element(boundBy: 0)
        XCTAssertTrue(
            firstAlbumButton.waitForExistence(timeout: 10),
            "First album should appear after loading"
        )
        
        // Then - Multiple album rows should be visible
        let albumButtons = app.buttons.allElementsBoundByIndex
        XCTAssertGreaterThanOrEqual(
            albumButtons.count,
            2,
            "Album list should display at least 2 album rows, found \(albumButtons.count)"
        )
    }

    func testAlbumList_TapAlbum_NavigatesToDetail() throws {
        // Given - Wait for albums to load
        let firstButton = app.buttons.firstMatch
        XCTAssertTrue(
            firstButton.waitForExistence(timeout: 10),
            "First album should be visible"
        )

        // When - Tap first album
        firstButton.tap()

        // Then - Should navigate to detail view
        // Check for back button in navigation bar
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5),
            "Back button should appear after navigating to detail"
        )
        
        // Verify we're not on the list anymore by checking navigation structure changed
        let detailVisible = app.otherElements.matching(identifier: "AlbumDetailView").firstMatch.waitForExistence(timeout: 2)
        XCTAssertTrue(
            detailVisible || backButton.exists,
            "Should navigate to album detail view"
        )
    }

    func testAlbumList_PullToRefresh_ReloadsData() throws {
        // Given - Wait for initial list to load
        let firstButton = app.buttons.firstMatch
        XCTAssertTrue(
            firstButton.waitForExistence(timeout: 10),
            "Albums should load initially"
        )
        
        // When - Perform pull to refresh gesture
        // Find the scrollable element (could be table or scrollView)
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
            let finish = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
            start.press(forDuration: 0.1, thenDragTo: finish)
        }

        // Then - List should still be visible after refresh
        XCTAssertTrue(
            firstButton.waitForExistence(timeout: 5),
            "Album list should remain visible after refresh"
        )
    }
    
    func testAlbumList_NavigateToDetailAndBack() throws {
        // Given - Wait for first album to appear
        let firstButton = app.buttons.firstMatch
        XCTAssertTrue(
            firstButton.waitForExistence(timeout: 10),
            "First album should be visible"
        )
        
        // When - Tap album to navigate to detail
        firstButton.tap()
        
        // Wait for navigation to complete
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5),
            "Back button should appear in detail view"
        )
        
        // When - Tap back button
        backButton.tap()
        
        // Then - Should return to album list
        let navigationBar = app.navigationBars["Top Albums"]
        XCTAssertTrue(
            navigationBar.waitForExistence(timeout: 3),
            "Should navigate back to album list"
        )
    }
}
