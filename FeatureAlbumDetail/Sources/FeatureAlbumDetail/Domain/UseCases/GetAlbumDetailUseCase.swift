//
//  GetAlbumDetailUseCase.swift
//  FeatureAlbumDetail
//
//  Created by Filipe Pereira on 05/12/2025.
//

import CoreAlbums
import Foundation

protocol GetAlbumDetailUseCase {
    func execute(albumId: String) async throws -> Album
}

final class GetAlbumDetailUseCaseImpl: GetAlbumDetailUseCase {

    private let repository: AlbumRepository

    init(repository: AlbumRepository) {
        self.repository = repository
    }

    func execute(albumId: String) async throws -> Album {
        return try await repository.getAlbumDetail(id: albumId)
    }
}
