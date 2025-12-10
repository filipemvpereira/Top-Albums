//
//  GetTopAlbumsUseCase.swift
//  FeatureAlbumList
//
//  Created by Filipe Pereira on 05/12/2025.
//

import CoreAlbums
import Foundation

public protocol GetTopAlbumsUseCase {
    func execute(limit: Int) async throws -> [Album]
}

final class DefaultGetTopAlbumsUseCase: GetTopAlbumsUseCase {

    private let repository: AlbumRepository

    init(repository: AlbumRepository) {
        self.repository = repository
    }

    func execute(limit: Int) async throws -> [Album] {
        return try await repository.getAlbums(limit: limit)
    }
}
