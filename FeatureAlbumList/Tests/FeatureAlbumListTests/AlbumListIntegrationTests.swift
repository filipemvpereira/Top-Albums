//
//  AlbumListIntegrationTests.swift
//  FeatureAlbumListTests
//
//  Created by Filipe Pereira on 09/12/2025.
//

import CoreResources
import Network
import XCTest

@testable import CoreAlbums
@testable import FeatureAlbumList

@MainActor
final class AlbumListIntegrationTests: XCTestCase {

    private var viewModel: AlbumListViewModel!
    private var mockNetworkService: MockNetworkService!

    override func setUp() async throws {
        try await super.setUp()

        // Setup real components (not mocks)
        mockNetworkService = MockNetworkService()
        let repository = DefaultAlbumRepository(networkService: mockNetworkService)
        let useCase = DefaultGetTopAlbumsUseCase(repository: repository)
        let resources = MockLocalizedResourcesRepository()

        viewModel = AlbumListViewModel(
            useCase: useCase,
            resources: resources
        )
    }

    override func tearDown() async throws {
        viewModel = nil
        mockNetworkService = nil
        try await super.tearDown()
    }

    // MARK: - Integration Tests

    func testFullFlow_Success_LoadsAndDisplaysAlbums() async throws {
        // Given - Mock network returns valid JSON response
        let jsonResponse = createValidAlbumResponseJSON()
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonResponse)

        // When - Initialize the ViewModel (full flow: ViewModel -> UseCase -> Repository -> Network)
        await viewModel.initialize()

        // Then - Verify the entire chain worked
        guard case .loaded(let items) = viewModel.state.content else {
            XCTFail("Expected loaded state, got: \(viewModel.state.content)")
            return
        }

        // Verify albums are loaded and sorted
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].title, "Album A")
        XCTAssertEqual(items[0].id, "1")
        XCTAssertEqual(items[1].title, "Album B")
        XCTAssertEqual(items[1].id, "2")

        // Verify title is set
        XCTAssertEqual(viewModel.state.title, "Top Albums")
    }

    func testFullFlow_NetworkError_DisplaysError() async {
        // Given - Network fails
        mockNetworkService.mockError = NetworkError.noDataReceived

        // When
        await viewModel.initialize()

        // Then - Error propagates through all layers
        guard case .error(let message, let retryText) = viewModel.state.content else {
            XCTFail("Expected error state")
            return
        }

        XCTAssertEqual(message, "Failed to load albums")
        XCTAssertEqual(retryText, "Retry")
    }

    func testFullFlow_InvalidJSON_DisplaysError() async {
        // Given - Network returns invalid JSON
        let invalidJSON = Data("{ invalid json }".utf8)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: invalidJSON)

        // When
        await viewModel.initialize()

        // Then - Decoding error is caught and displayed
        guard case .error = viewModel.state.content else {
            XCTFail("Expected error state")
            return
        }
    }

    func testFullFlow_EmptyResponse_DisplaysEmptyList() async throws {
        // Given - Network returns empty album list
        let emptyJSON = createEmptyAlbumResponseJSON()
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: emptyJSON)

        // When
        await viewModel.initialize()

        // Then
        guard case .loaded(let items) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertTrue(items.isEmpty)
    }

    func testFullFlow_RefreshAfterError_RecoversSuccessfully() async throws {
        // Given - Initial error
        mockNetworkService.mockError = NetworkError.noDataReceived
        await viewModel.initialize()

        // When - Refresh with valid data
        let jsonResponse = createValidAlbumResponseJSON()
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonResponse)
        mockNetworkService.mockError = nil
        await viewModel.refresh()

        // Then - Successfully recovered
        guard case .loaded(let items) = viewModel.state.content else {
            XCTFail("Expected loaded state after recovery")
            return
        }

        XCTAssertEqual(items.count, 2)
    }

    func testFullFlow_CachingBehavior_SecondLoadUsesCache() async throws {
        // Given - First successful load
        let jsonResponse = createValidAlbumResponseJSON()
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonResponse)
        await viewModel.initialize()

        // When - Try to initialize again
        mockNetworkService.callCount = 0
        await viewModel.initialize()

        // Then - Should not make network call (uses cached state)
        XCTAssertEqual(mockNetworkService.callCount, 0)
    }

    func testFullFlow_DataMapping_CorrectlyMapsFromDTOToDomain() async throws {
        // Given - Network returns data with specific fields
        let jsonResponse = """
        {
          "feed": {
            "entry": [{
              "im:name": { "label": "Test Album" },
              "im:image": [
                { "label": "http://small.jpg", "attributes": { "height": "55" } },
                { "label": "http://medium.jpg", "attributes": { "height": "60" } },
                { "label": "http://large.jpg", "attributes": { "height": "170" } }
              ],
              "im:itemCount": { "label": "15" },
              "im:price": {
                "label": "$12.99",
                "attributes": { "amount": "12.99", "currency": "USD" }
              },
              "rights": { "label": "© 2024 Test Records" },
              "im:artist": { "label": "Test Artist" },
              "category": { "attributes": { "label": "Rock" } },
              "im:releaseDate": {
                "label": "2024-12-01",
                "attributes": { "label": "Dec 1, 2024" }
              },
              "id": { "attributes": { "im:id": "123" } },
              "link": { "attributes": { "href": "https://itunes.com/123" } }
            }]
          }
        }
        """
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: Data(jsonResponse.utf8))

        // When
        await viewModel.initialize()

        // Then - Verify complete data mapping
        guard case .loaded(let items) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        let item = items[0]
        XCTAssertEqual(item.id, "123")
        XCTAssertEqual(item.title, "Test Album")
        XCTAssertEqual(item.subtitle, "Test Artist")
        XCTAssertEqual(item.imageUrl, "http://medium.jpg")
    }

    // MARK: - Helper Methods

    private func createValidAlbumResponseJSON() -> Data {
        let json = """
        {
          "feed": {
            "entry": [
              {
                "im:name": { "label": "Album B" },
                "im:image": [
                  { "label": "http://example.com/small.jpg", "attributes": { "height": "55" } },
                  { "label": "http://example.com/medium.jpg", "attributes": { "height": "60" } },
                  { "label": "http://example.com/large.jpg", "attributes": { "height": "170" } }
                ],
                "im:itemCount": { "label": "10" },
                "im:price": {
                  "label": "$9.99",
                  "attributes": { "amount": "9.99", "currency": "USD" }
                },
                "rights": { "label": "© 2024" },
                "im:artist": { "label": "Artist B" },
                "category": { "attributes": { "label": "Pop" } },
                "im:releaseDate": {
                  "label": "2024-01-01",
                  "attributes": { "label": "Jan 1, 2024" }
                },
                "id": { "attributes": { "im:id": "2" } },
                "link": { "attributes": { "href": "https://itunes.com/2" } }
              },
              {
                "im:name": { "label": "Album A" },
                "im:image": [
                  { "label": "http://example.com/small2.jpg", "attributes": { "height": "55" } },
                  { "label": "http://example.com/medium2.jpg", "attributes": { "height": "60" } },
                  { "label": "http://example.com/large2.jpg", "attributes": { "height": "170" } }
                ],
                "im:itemCount": { "label": "12" },
                "im:price": {
                  "label": "$10.99",
                  "attributes": { "amount": "10.99", "currency": "USD" }
                },
                "rights": { "label": "© 2024" },
                "im:artist": { "label": "Artist A" },
                "category": { "attributes": { "label": "Rock" } },
                "im:releaseDate": {
                  "label": "2024-02-01",
                  "attributes": { "label": "Feb 1, 2024" }
                },
                "id": { "attributes": { "im:id": "1" } },
                "link": { "attributes": { "href": "https://itunes.com/1" } }
              }
            ]
          }
        }
        """
        return Data(json.utf8)
    }

    private func createEmptyAlbumResponseJSON() -> Data {
        let json = """
        {
          "feed": {
            "entry": []
          }
        }
        """
        return Data(json.utf8)
    }
}

// MARK: - Mock Network Service

private class MockNetworkService: NetworkService {

    var mockResponse: NetworkResponse?
    var mockError: Error?
    var callCount = 0

    func data(request: NetworkRequest) async throws -> NetworkResponse {
        callCount += 1

        if let error = mockError {
            throw error
        }

        guard let response = mockResponse else {
            throw NetworkError.noDataReceived
        }

        return response
    }
}

// MARK: - Mock LocalizedResourcesRepository

private class MockLocalizedResourcesRepository: LocalizedResourcesRepository {

    private let strings: [String: String] = [
        "album_list_title": "Top Albums",
        "album_list_loading": "Loading albums...",
        "album_list_error": "Failed to load albums",
        "album_list_retry": "Retry",
    ]

    func getString(key: String) -> String? {
        return strings[key]
    }

    func getString(key: String, arguments: [CVarArg]) -> String? {
        fatalError("getString(key:arguments:) not implemented in mock")
    }
}
