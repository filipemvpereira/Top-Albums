//
//  AlbumDetailViewModel.swift
//  FeatureAlbumDetail
//
//  Created by Filipe Pereira on 05/12/2025.
//

import Combine
import CoreAlbums
import CoreResources
import Foundation

@MainActor
final class AlbumDetailViewModel: ObservableObject {

    @Published private(set) var state: AlbumDetailViewState = AlbumDetailViewState(title: "", content: .loading(""))

    private let albumId: String
    nonisolated(unsafe) private let getAlbumDetailUseCase: GetAlbumDetailUseCase
    nonisolated(unsafe) private let resources: LocalizedResourcesRepository
    private let title: String

    nonisolated init(
        albumId: String,
        getAlbumDetailUseCase: GetAlbumDetailUseCase,
        resources: LocalizedResourcesRepository
    ) {
        self.albumId = albumId
        self.getAlbumDetailUseCase = getAlbumDetailUseCase
        self.resources = resources
        self.title = resources.getString(key: "album_detail_title") ?? ""
    }

    func loadAlbumDetail() async {
        let loadingText = resources.getString(key: "album_detail_loading") ?? ""
        state = AlbumDetailViewState(title: title, content: .loading(loadingText))

        do {
            let album = try await getAlbumDetailUseCase.execute(albumId: albumId)
            state = AlbumDetailViewState(title: title, content: .loaded(mapToViewState(album)))
        } catch {
            let errorMessage = resources.getString(key: "album_detail_error") ?? ""
            let retryText = resources.getString(key: "album_detail_retry") ?? ""
            state = AlbumDetailViewState(title: title, content: .error(errorMessage, retryText: retryText))
        }
    }

    func retry() async {
        await loadAlbumDetail()
    }

    private func mapToViewState(_ album: Album) -> AlbumDetailViewState.AlbumDetail {
        return AlbumDetailViewState.AlbumDetail(
            id: album.id,
            name: album.name,
            artistName: album.artistName,
            artworkUrl: album.artworkUrlLarge,
            releaseDate: album.releaseDateFormatted,
            genres: album.genre,
            trackCount: album.itemCount,
            price: album.price
        )
    }
}
