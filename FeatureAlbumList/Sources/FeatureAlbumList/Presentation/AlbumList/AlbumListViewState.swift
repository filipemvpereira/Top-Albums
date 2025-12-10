//
//  AlbumListViewState.swift
//  FeatureAlbumList
//
//  Created by Filipe Pereira on 05/12/2025.
//

import Foundation

struct AlbumListViewState: Equatable {

    let title: String
    let content: Content

    enum Content: Equatable {

        case loading(String)
        case loaded([Item])
        case error(String, retryText: String)
    }

    struct Item: Identifiable, Equatable {

        let id: String
        let title: String
        let subtitle: String
        let imageUrl: String
    }
}
