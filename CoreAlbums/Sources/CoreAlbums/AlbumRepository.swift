//
//  AlbumRepository.swift
//  CoreAlbums
//
//  Created by Filipe Pereira on 05/12/2025.
//

import Foundation

public protocol AlbumRepository {

    func getAlbums(limit: Int) async throws -> [Album]
    func getAlbumDetail(id: String) async throws -> Album
}

public enum AlbumRepositoryError: Error {

    case albumNotFound
}
