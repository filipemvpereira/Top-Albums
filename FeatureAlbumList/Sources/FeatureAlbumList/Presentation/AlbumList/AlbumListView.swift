//
//  AlbumListView.swift
//  FeatureAlbumList
//
//  Created by Filipe Pereira on 05/12/2025.
//

import CoreAlbums
import CoreUI
import SwiftUI

public struct AlbumListView: View {

    @StateObject var viewModel: AlbumListViewModel
    let navigator: Navigator

    public var body: some View {
        AlbumListScreen(
            state: viewModel.state,
            onItemClick: { albumId in
                navigator.navigate(to: .albumDetail(id: albumId))
            },
            onRetry: {
                Task {
                    await viewModel.retry()
                }
            },
            onRefresh: {
                Task {
                    await viewModel.refresh()
                }
            }
        )
        .task {
            await viewModel.initialize()
        }
    }
}

struct AlbumListScreen: View {

    let state: AlbumListViewState
    let onItemClick: (String) -> Void
    let onRetry: () -> Void
    let onRefresh: () async -> Void

    var body: some View {
        Group {
            switch state.content {
            case .loading(let message):
                LoadingView(message: message)
            case .loaded(let items):
                albumListView(items: items)
            case .error(let message, let retryText):
                ErrorView(message: message, retryText: retryText, onRetry: onRetry)
            }
        }
        .navigationTitle(state.title)
        .navigationBarTitleDisplayMode(.large)
        .accessibilityIdentifier("AlbumListView")
    }

    private func albumListView(items: [AlbumListViewState.Item]) -> some View {
        List(items) { item in
            Button(action: {
                onItemClick(item.id)
            }) {
                AlbumRowView(item: item)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("AlbumRow_\(item.id)")
        }
        .listStyle(.plain)
        .refreshable {
            await onRefresh()
        }
        .accessibilityIdentifier("AlbumList")
    }
}

#Preview("Loaded") {
    AlbumListScreen(
        state: AlbumListViewState(
            title: "Top Albums",
            content: .loaded([
                AlbumListViewState.Item(
                    id: "1",
                    title: "Wicked: For Good – The Soundtrack",
                    subtitle: "Wicked Movie Cast, Cynthia Erivo & Ariana Grande",
                    imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/e8/77/90/e87790f8-1dd6-d64b-3d5d-6083552aca7f/25UM1IM45249.rgb.jpg/60x60bb.png"
                ),
                AlbumListViewState.Item(
                    id: "2",
                    title: "CHROMAKOPIA",
                    subtitle: "Tyler, The Creator",
                    imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/e8/77/90/e87790f8-1dd6-d64b-3d5d-6083552aca7f/25UM1IM45249.rgb.jpg/60x60bb.png"
                )
            ])
        ),
        onItemClick: { _ in },
        onRetry: {},
        onRefresh: {}
    )
}

#Preview("Loading") {
    AlbumListScreen(
        state: AlbumListViewState(
            title: "Top Albums",
            content: .loading("Loading albums...")
        ),
        onItemClick: { _ in },
        onRetry: {},
        onRefresh: {}
    )
}

#Preview("Error") {
    AlbumListScreen(
        state: AlbumListViewState(
            title: "Top Albums",
            content: .error("Failed to load albums", retryText: "Retry")
        ),
        onItemClick: { _ in },
        onRetry: {},
        onRefresh: {}
    )
}
