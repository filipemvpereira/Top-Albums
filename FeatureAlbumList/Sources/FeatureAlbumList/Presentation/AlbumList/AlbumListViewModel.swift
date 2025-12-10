//
//  AlbumListViewModel.swift
//  FeatureAlbumList
//
//  Created by Filipe Pereira on 05/12/2025.
//

import Combine
import CoreAlbums
import CoreResources
import Foundation

@MainActor
class AlbumListViewModel: ObservableObject {

    @Published private(set) var state: AlbumListViewState = AlbumListViewState(title: "", content: .loading(""))

    private nonisolated(unsafe) let useCase: GetTopAlbumsUseCase
    private nonisolated(unsafe) let resources: LocalizedResourcesRepository
    private let title: String

    nonisolated init(
        useCase: GetTopAlbumsUseCase,
        resources: LocalizedResourcesRepository
    ) {
        self.useCase = useCase
        self.resources = resources
        self.title = resources.getString(key: "album_list_title") ?? ""
    }

    func initialize() async {
        if case .loaded = state.content {
            return
        }

        await fetchAlbums()
    }

    func refresh() async {
        await fetchAlbums()
    }

    func retry() async {
        await fetchAlbums()
    }

    private func fetchAlbums() async {
        let loadingText = resources.getString(key: "album_list_loading") ?? ""
        state = AlbumListViewState(title: title, content: .loading(loadingText))

        do {
            let fetchedAlbums = try await useCase.execute(limit: 100)
            let items = fetchedAlbums
                .map { mapToListItem($0) }
                .sorted { $0.title < $1.title }
            state = AlbumListViewState(title: title, content: .loaded(items))
        } catch {
            let errorMessage = resources.getString(key: "album_list_error") ?? ""
            let retryText = resources.getString(key: "album_list_retry") ?? ""
            state = AlbumListViewState(title: title, content: .error(errorMessage, retryText: retryText))
        }
    }

    private func mapToListItem(_ album: Album) -> AlbumListViewState.Item {
        AlbumListViewState.Item(
            id: album.id,
            title: album.name,
            subtitle: album.artistName,
            imageUrl: album.artworkUrl
        )
    }
}
