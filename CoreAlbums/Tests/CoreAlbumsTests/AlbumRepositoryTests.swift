//
//  AlbumRepositoryTests.swift
//  CoreAlbumsTests
//
//  Created by Filipe Pereira on 09/12/2025.
//

import Network
import XCTest

@testable import CoreAlbums

final class AlbumRepositoryTests: XCTestCase {

    private var repository: DefaultAlbumRepository!
    private var mockNetworkService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        repository = DefaultAlbumRepository(networkService: mockNetworkService)
    }

    override func tearDown() {
        repository = nil
        mockNetworkService = nil
        super.tearDown()
    }

    // MARK: - getAlbums() Tests

    func testGetAlbums_Success_ReturnsAlbums() async throws {
        // Given
        let expectedAlbums = [
            createMockAlbum(id: "1", name: "Album 1"),
            createMockAlbum(id: "2", name: "Album 2"),
        ]
        let jsonData = createMockAlbumResponseJSON(albums: expectedAlbums)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        // When
        let albums = try await repository.getAlbums(limit: 10)

        // Then
        XCTAssertEqual(albums.count, 2)
        XCTAssertEqual(albums[0].id, "1")
        XCTAssertEqual(albums[0].name, "Album 1")
        XCTAssertEqual(albums[1].id, "2")
        XCTAssertEqual(albums[1].name, "Album 2")
    }

    func testGetAlbums_Success_CachesAlbums() async throws {
        // Given
        let expectedAlbums = [createMockAlbum(id: "1", name: "Album 1")]
        let jsonData = createMockAlbumResponseJSON(albums: expectedAlbums)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        // When
        _ = try await repository.getAlbums(limit: 10)

        // Then - Verify album is cached by calling getAlbumDetail (which checks cache first)
        mockNetworkService.callCount = 0  // Reset call count
        let cachedAlbum = try await repository.getAlbumDetail(id: "1")

        // Should return cached album without making network call
        XCTAssertEqual(mockNetworkService.callCount, 0)
        XCTAssertEqual(cachedAlbum.id, "1")
    }

    func testGetAlbums_EmptyResponse_ReturnsEmptyArray() async throws {
        // Given
        let jsonData = createMockAlbumResponseJSON(albums: [])
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        // When
        let albums = try await repository.getAlbums(limit: 10)

        // Then
        XCTAssertTrue(albums.isEmpty)
    }

    func testGetAlbums_NetworkError_ThrowsError() async {
        // Given
        mockNetworkService.mockError = NetworkError.noDataReceived

        // When/Then
        do {
            _ = try await repository.getAlbums(limit: 10)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    func testGetAlbums_InvalidJSON_ThrowsDecodingError() async {
        // Given
        let invalidJSON = Data("invalid json".utf8)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: invalidJSON)

        // When/Then
        do {
            _ = try await repository.getAlbums(limit: 10)
            XCTFail("Expected decoding error to be thrown")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testGetAlbums_LimitParameter_PassedToURL() async throws {
        // Given
        let expectedAlbums = [createMockAlbum(id: "1", name: "Album 1")]
        let jsonData = createMockAlbumResponseJSON(albums: expectedAlbums)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        // When
        _ = try await repository.getAlbums(limit: 50)

        // Then
        XCTAssertEqual(mockNetworkService.lastRequest?.url, "https://itunes.apple.com/us/rss/topalbums/limit=50/json")
    }

    // MARK: - getAlbumDetail() Tests

    func testGetAlbumDetail_CacheHit_ReturnsAlbumWithoutNetworkCall() async throws {
        // Given - First populate the cache
        let expectedAlbums = [createMockAlbum(id: "123", name: "Cached Album")]
        let jsonData = createMockAlbumResponseJSON(albums: expectedAlbums)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)
        _ = try await repository.getAlbums(limit: 10)

        // When - Get album detail (should use cache)
        mockNetworkService.callCount = 0
        let album = try await repository.getAlbumDetail(id: "123")

        // Then
        XCTAssertEqual(mockNetworkService.callCount, 0, "Should not make network call for cached album")
        XCTAssertEqual(album.id, "123")
        XCTAssertEqual(album.name, "Cached Album")
    }

    func testGetAlbumDetail_CacheMissAndFound_FetchesAndReturnsAlbum() async throws {
        // Given
        let expectedAlbums = [
            createMockAlbum(id: "1", name: "Album 1"),
            createMockAlbum(id: "2", name: "Album 2"),
        ]
        let jsonData = createMockAlbumResponseJSON(albums: expectedAlbums)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        // When
        let album = try await repository.getAlbumDetail(id: "2")

        // Then
        XCTAssertEqual(mockNetworkService.callCount, 1, "Should make network call when not cached")
        XCTAssertEqual(album.id, "2")
        XCTAssertEqual(album.name, "Album 2")
    }

    func testGetAlbumDetail_CacheMissAndNotFound_ThrowsAlbumNotFoundError() async {
        // Given
        let expectedAlbums = [createMockAlbum(id: "1", name: "Album 1")]
        let jsonData = createMockAlbumResponseJSON(albums: expectedAlbums)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        // When/Then
        do {
            _ = try await repository.getAlbumDetail(id: "999")
            XCTFail("Expected albumNotFound error to be thrown")
        } catch let error as AlbumRepositoryError {
            XCTAssertEqual(error, AlbumRepositoryError.albumNotFound)
        } catch {
            XCTFail("Expected AlbumRepositoryError.albumNotFound, got \(error)")
        }
    }

    func testGetAlbumDetail_NetworkErrorOnCacheMiss_PropagatesError() async {
        // Given
        mockNetworkService.mockError = NetworkError.invalidStatusCode

        // When/Then
        do {
            _ = try await repository.getAlbumDetail(id: "123")
            XCTFail("Expected network error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    // MARK: - Cache Integration Tests

    func testCache_MultipleGetAlbumDetailCalls_UseCachedDataFromGetAlbums() async throws {
        // Given - Populate cache with multiple albums
        let expectedAlbums = [
            createMockAlbum(id: "1", name: "Album 1"),
            createMockAlbum(id: "2", name: "Album 2"),
            createMockAlbum(id: "3", name: "Album 3"),
        ]
        let jsonData = createMockAlbumResponseJSON(albums: expectedAlbums)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)
        _ = try await repository.getAlbums(limit: 10)

        // When - Get multiple album details
        mockNetworkService.callCount = 0
        let album1 = try await repository.getAlbumDetail(id: "1")
        let album2 = try await repository.getAlbumDetail(id: "2")
        let album3 = try await repository.getAlbumDetail(id: "3")

        // Then - All should come from cache without network calls
        XCTAssertEqual(mockNetworkService.callCount, 0)
        XCTAssertEqual(album1.id, "1")
        XCTAssertEqual(album2.id, "2")
        XCTAssertEqual(album3.id, "3")
    }

    func testCache_DifferentLimits_CanFetchWithDifferentParameters() async throws {
        // Given
        let smallSet = [createMockAlbum(id: "1", name: "Album 1")]
        let largeSet = [
            createMockAlbum(id: "1", name: "Album 1"),
            createMockAlbum(id: "2", name: "Album 2"),
        ]

        // When - Fetch with limit 1
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: createMockAlbumResponseJSON(albums: smallSet))
        let albums1 = try await repository.getAlbums(limit: 1)

        // When - Fetch with limit 2
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: createMockAlbumResponseJSON(albums: largeSet))
        let albums2 = try await repository.getAlbums(limit: 2)

        // Then
        XCTAssertEqual(albums1.count, 1)
        XCTAssertEqual(albums2.count, 2)
        XCTAssertEqual(mockNetworkService.callCount, 2)
    }

    // MARK: - Helper Methods

    private func createMockAlbum(id: String, name: String) -> Album {
        Album(
            id: id,
            name: name,
            artistName: "Test Artist",
            artworkUrl: "https://example.com/artwork.jpg",
            artworkUrlSmall: "https://example.com/artwork_small.jpg",
            artworkUrlLarge: "https://example.com/artwork_large.jpg",
            price: "$9.99",
            priceAmount: 9.99,
            currency: "USD",
            genre: "Pop",
            releaseDate: "2024-01-01",
            releaseDateFormatted: "Jan 1, 2024",
            itemCount: 12,
            copyright: "© 2024 Test Records",
            itunesUrl: "https://itunes.apple.com/album/\(id)"
        )
    }

    private func createMockAlbumResponseJSON(albums: [Album]) -> Data {
        let entries = albums.map { album in
            """
            {
              "im:name": { "label": "\(album.name)" },
              "im:image": [
                { "label": "\(album.artworkUrlSmall)", "attributes": { "height": "55" } },
                { "label": "\(album.artworkUrl)", "attributes": { "height": "60" } },
                { "label": "\(album.artworkUrlLarge)", "attributes": { "height": "170" } }
              ],
              "im:itemCount": { "label": "\(album.itemCount)" },
              "im:price": {
                "label": "\(album.price)",
                "attributes": { "amount": "\(album.priceAmount ?? 0.0)", "currency": "\(album.currency ?? "USD")" }
              },
              "rights": { "label": "\(album.copyright)" },
              "im:artist": { "label": "\(album.artistName)" },
              "category": { "attributes": { "label": "\(album.genre)" } },
              "im:releaseDate": {
                "label": "\(album.releaseDate)",
                "attributes": { "label": "\(album.releaseDateFormatted)" }
              },
              "id": { "attributes": { "im:id": "\(album.id)" } },
              "link": { "attributes": { "href": "\(album.itunesUrl)" } }
            }
            """
        }.joined(separator: ",")

        let json = """
        {
          "feed": {
            "entry": [\(entries)]
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
    var lastRequest: NetworkRequest?

    func data(request: NetworkRequest) async throws -> NetworkResponse {
        callCount += 1
        lastRequest = request

        if let error = mockError {
            throw error
        }

        guard let response = mockResponse else {
            throw NetworkError.noDataReceived
        }

        return response
    }
}
