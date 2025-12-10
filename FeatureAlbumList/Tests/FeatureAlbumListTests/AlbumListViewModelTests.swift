//
//  AlbumListViewModelTests.swift
//  FeatureAlbumListTests
//
//  Created by Filipe Pereira on 09/12/2025.
//

import Combine
import CoreAlbums
import CoreResources
import XCTest

@testable import FeatureAlbumList

@MainActor
final class AlbumListViewModelTests: XCTestCase {

    private var viewModel: AlbumListViewModel!
    private var mockUseCase: MockGetTopAlbumsUseCase!
    private var mockResources: MockLocalizedResourcesRepository!

    override func setUp() async throws {
        try await super.setUp()
        mockUseCase = MockGetTopAlbumsUseCase()
        mockResources = MockLocalizedResourcesRepository()
        viewModel = AlbumListViewModel(
            useCase: mockUseCase,
            resources: mockResources
        )
    }

    override func tearDown() async throws {
        viewModel = nil
        mockUseCase = nil
        mockResources = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInit_SetsInitialState() {
        // Then
        XCTAssertEqual(viewModel.state.title, "")
        if case .loading = viewModel.state.content {
            // Success - initial state is loading
        } else {
            XCTFail("Expected loading state on initialization")
        }
    }

    // MARK: - initialize() Tests

    func testInitialize_Success_UpdatesStateToLoaded() async {
        // Given
        let mockAlbums = [
            createMockAlbum(id: "2", name: "Album B"),
            createMockAlbum(id: "1", name: "Album A"),
        ]
        mockUseCase.mockResult = .success(mockAlbums)

        // When
        await viewModel.initialize()

        // Then
        XCTAssertEqual(viewModel.state.title, "Top Albums")
        guard case .loaded(let items) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].id, "1")
        XCTAssertEqual(items[0].title, "Album A")
        XCTAssertEqual(items[1].id, "2")
        XCTAssertEqual(items[1].title, "Album B")
    }

    func testInitialize_Success_MapsAlbumDataCorrectly() async {
        // Given
        let mockAlbum = Album(
            id: "123",
            name: "Test Album",
            artistName: "Test Artist",
            artworkUrl: "https://example.com/art.jpg",
            artworkUrlSmall: "https://example.com/art_small.jpg",
            artworkUrlLarge: "https://example.com/art_large.jpg",
            price: "$9.99",
            priceAmount: 9.99,
            currency: "USD",
            genre: "Pop",
            releaseDate: "2024-01-01",
            releaseDateFormatted: "Jan 1, 2024",
            itemCount: 12,
            copyright: "© 2024",
            itunesUrl: "https://itunes.com"
        )
        mockUseCase.mockResult = .success([mockAlbum])

        // When
        await viewModel.initialize()

        // Then
        guard case .loaded(let items) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(items[0].id, "123")
        XCTAssertEqual(items[0].title, "Test Album")
        XCTAssertEqual(items[0].subtitle, "Test Artist")
        XCTAssertEqual(items[0].imageUrl, "https://example.com/art.jpg")
    }

    func testInitialize_AlreadyLoaded_SkipsLoading() async {
        // Given - First load
        let mockAlbums = [createMockAlbum(id: "1", name: "Album 1")]
        mockUseCase.mockResult = .success(mockAlbums)
        await viewModel.initialize()

        // When - Second load
        mockUseCase.callCount = 0
        await viewModel.initialize()

        // Then - Should not call use case again
        XCTAssertEqual(mockUseCase.callCount, 0)
        guard case .loaded = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }
    }

    func testInitialize_Error_UpdatesStateToError() async {
        // Given
        mockUseCase.mockResult = .failure(NSError(domain: "test", code: -1))

        // When
        await viewModel.initialize()

        // Then
        XCTAssertEqual(viewModel.state.title, "Top Albums")
        guard case .error(let message, let retryText) = viewModel.state.content else {
            XCTFail("Expected error state")
            return
        }

        XCTAssertEqual(message, "Failed to load albums")
        XCTAssertEqual(retryText, "Retry")
    }

    func testInitialize_EmptyList_UpdatesStateToLoadedWithEmptyArray() async {
        // Given
        mockUseCase.mockResult = .success([])

        // When
        await viewModel.initialize()

        // Then
        guard case .loaded(let items) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertTrue(items.isEmpty)
    }

    func testInitialize_SetsLoadingStateFirst() async {
        // Given
        mockUseCase.mockResult = .success([createMockAlbum(id: "1", name: "Album 1")])

        // When - Capture state during loading
        let expectation = expectation(description: "Loading state")
        var capturedLoadingState = false

        Task {
            // Check state immediately after calling loadAlbums
            if case .loading = viewModel.state.content {
                capturedLoadingState = true
                expectation.fulfill()
            }
        }

        await viewModel.initialize()

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertTrue(capturedLoadingState)
    }

    // MARK: - refresh() Tests

    func testRefresh_Success_ReloadsData() async {
        // Given - Initial load
        mockUseCase.mockResult = .success([createMockAlbum(id: "1", name: "Album 1")])
        await viewModel.initialize()

        // When - Refresh with new data
        let newAlbums = [
            createMockAlbum(id: "2", name: "Album 2"),
            createMockAlbum(id: "3", name: "Album 3"),
        ]
        mockUseCase.mockResult = .success(newAlbums)
        await viewModel.refresh()

        // Then
        guard case .loaded(let items) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].id, "2")
        XCTAssertEqual(items[1].id, "3")
    }

    func testRefresh_AlwaysReloads_EvenWhenAlreadyLoaded() async {
        // Given - Initial load
        mockUseCase.mockResult = .success([createMockAlbum(id: "1", name: "Album 1")])
        await viewModel.initialize()

        // When - Refresh
        mockUseCase.callCount = 0
        await viewModel.refresh()

        // Then - Should make new network call
        XCTAssertEqual(mockUseCase.callCount, 1)
    }

    func testRefresh_Error_UpdatesStateToError() async {
        // Given - Initial successful load
        mockUseCase.mockResult = .success([createMockAlbum(id: "1", name: "Album 1")])
        await viewModel.initialize()

        // When - Refresh fails
        mockUseCase.mockResult = .failure(NSError(domain: "test", code: -1))
        await viewModel.refresh()

        // Then
        guard case .error = viewModel.state.content else {
            XCTFail("Expected error state")
            return
        }
    }

    // MARK: - retry() Tests

    func testRetry_Success_UpdatesStateToLoaded() async {
        // Given - Initial error state
        mockUseCase.mockResult = .failure(NSError(domain: "test", code: -1))
        await viewModel.initialize()

        // When - Retry succeeds
        let mockAlbums = [createMockAlbum(id: "1", name: "Album 1")]
        mockUseCase.mockResult = .success(mockAlbums)
        await viewModel.retry()

        // Then
        guard case .loaded(let items) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].id, "1")
    }

    func testRetry_Error_RemainsInErrorState() async {
        // Given - Initial error state
        mockUseCase.mockResult = .failure(NSError(domain: "test", code: -1))
        await viewModel.initialize()

        // When - Retry fails again
        await viewModel.retry()

        // Then
        guard case .error = viewModel.state.content else {
            XCTFail("Expected error state")
            return
        }
    }

    // MARK: - Sorting Tests

    func testInitialize_SortsAlbumsAlphabetically() async {
        // Given
        let mockAlbums = [
            createMockAlbum(id: "1", name: "Zebra Album"),
            createMockAlbum(id: "2", name: "Alpha Album"),
            createMockAlbum(id: "3", name: "Beta Album"),
        ]
        mockUseCase.mockResult = .success(mockAlbums)

        // When
        await viewModel.initialize()

        // Then
        guard case .loaded(let items) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(items[0].title, "Alpha Album")
        XCTAssertEqual(items[1].title, "Beta Album")
        XCTAssertEqual(items[2].title, "Zebra Album")
    }

    // MARK: - Localization Tests

    func testInit_UsesLocalizedTitle() async {
        // Given
        mockUseCase.mockResult = .success([])

        // When
        await viewModel.initialize()

        // Then - Title is set when loadAlbums is called
        XCTAssertEqual(viewModel.state.title, "Top Albums")
        XCTAssertEqual(mockResources.getStringCallCount["album_list_title"], 1)
    }

    func testInitialize_UsesLocalizedLoadingMessage() async {
        // Given
        mockUseCase.mockResult = .success([])

        // When
        await viewModel.initialize()

        // Then
        XCTAssertEqual(mockResources.getStringCallCount["album_list_loading"], 1)
    }

    func testInitialize_Error_UsesLocalizedErrorMessages() async {
        // Given
        mockUseCase.mockResult = .failure(NSError(domain: "test", code: -1))

        // When
        await viewModel.initialize()

        // Then
        XCTAssertEqual(mockResources.getStringCallCount["album_list_error"], 1)
        XCTAssertEqual(mockResources.getStringCallCount["album_list_retry"], 1)
    }

    // MARK: - Helper Methods

    private func createMockAlbum(id: String, name: String) -> Album {
        Album(
            id: id,
            name: name,
            artistName: "Test Artist",
            artworkUrl: "https://example.com/art.jpg",
            artworkUrlSmall: "https://example.com/art_small.jpg",
            artworkUrlLarge: "https://example.com/art_large.jpg",
            price: "$9.99",
            priceAmount: 9.99,
            currency: "USD",
            genre: "Pop",
            releaseDate: "2024-01-01",
            releaseDateFormatted: "Jan 1, 2024",
            itemCount: 12,
            copyright: "© 2024",
            itunesUrl: "https://itunes.com/\(id)"
        )
    }
}

// MARK: - Mock GetTopAlbumsUseCase

private class MockGetTopAlbumsUseCase: GetTopAlbumsUseCase {

    var mockResult: Result<[Album], Error> = .success([])
    var callCount = 0
    var lastLimit: Int?

    func execute(limit: Int) async throws -> [Album] {
        callCount += 1
        lastLimit = limit

        switch mockResult {
        case .success(let albums):
            return albums
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Mock LocalizedResourcesRepository

private class MockLocalizedResourcesRepository: LocalizedResourcesRepository {

    var getStringCallCount: [String: Int] = [:]

    private let strings: [String: String] = [
        "album_list_title": "Top Albums",
        "album_list_loading": "Loading albums...",
        "album_list_error": "Failed to load albums",
        "album_list_retry": "Retry",
    ]

    func getString(key: String) -> String? {
        getStringCallCount[key, default: 0] += 1
        return strings[key]
    }

    func getString(key: String, arguments: [CVarArg]) -> String? {
        fatalError("getString(key:arguments:) not implemented in mock")
    }
}
