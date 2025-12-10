//
//  AlbumDetailViewState.swift
//  FeatureAlbumDetail
//
//  Created by Filipe Pereira on 05/12/2025.
//

import Foundation

struct AlbumDetailViewState: Equatable {

    let title: String
    let content: Content

    enum Content: Equatable {

        case loading(String)
        case loaded(AlbumDetail)
        case error(String, retryText: String)
    }

    struct AlbumDetail: Equatable {

        let id: String
        let name: String
        let artistName: String
        let artworkUrl: String
        let releaseDate: String
        let genres: String
        let trackCount: Int
        let price: String?
    }
}
