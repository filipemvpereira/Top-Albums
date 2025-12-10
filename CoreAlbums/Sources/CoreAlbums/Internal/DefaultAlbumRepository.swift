//
//  DefaultAlbumRepository.swift
//  CoreAlbums
//
//  Created by Filipe Pereira on 05/12/2025.
//

import Foundation
import Network

private let defaultLimit = 100

final class DefaultAlbumRepository: AlbumRepository {

    private let networkService: NetworkService
    private let baseUrl = "https://itunes.apple.com/us/rss/topalbums"

    private let albumsCache = NSCache<NSString, AlbumCacheWrapper>()

    init(networkService: NetworkService) {
        self.networkService = networkService
        configureCache()
    }

    func getAlbums(limit: Int) async throws -> [Album] {
        let url = "\(baseUrl)/limit=\(limit)/json"
        let request = NetworkRequest(method: .get, url: url)

        let response = try await networkService.data(request: request)

        let decoder = JSONDecoder()
        let feedResponse = try decoder.decode(AlbumResponse.self, from: response.body)

        let albums = feedResponse.feed.entry.map { $0.toDomain() }

        albums.forEach { album in
            let wrapper = AlbumCacheWrapper(album: album)
            albumsCache.setObject(wrapper, forKey: album.id as NSString)
        }

        return albums
    }

    func getAlbumDetail(id: String) async throws -> Album {
        if let cachedWrapper = albumsCache.object(forKey: id as NSString) {
            return cachedWrapper.album
        }

        let albums = try await getAlbums(limit: defaultLimit)

        guard let album = albums.first(where: { $0.id == id }) else {
            throw AlbumRepositoryError.albumNotFound
        }

        return album
    }

    private func configureCache() {
        albumsCache.countLimit = defaultLimit
        albumsCache.name = "com.topalbums.albums.cache"
    }
}

private final class AlbumCacheWrapper {

    let album: Album

    init(album: Album) {
        self.album = album
    }
}
