//
//  AlbumDetailView.swift
//  FeatureAlbumDetail
//
//  Created by Filipe Pereira on 05/12/2025.
//

import CoreUI
import SwiftUI

public struct AlbumDetailView: View {

    @StateObject var viewModel: AlbumDetailViewModel

    public var body: some View {
        AlbumDetailScreen(
            state: viewModel.state,
            onRetry: {
                Task {
                    await viewModel.retry()
                }
            }
        )
        .navigationTitle(viewModel.state.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.loadAlbumDetail()
            }
        }
    }
}

struct AlbumDetailScreen: View {

    let state: AlbumDetailViewState
    let onRetry: () -> Void

    var body: some View {
        Group {
            switch state.content {
            case .loading(let message):
                LoadingView(message: message)
            case .loaded(let album):
                albumDetailView(album: album)
            case .error(let message, let retryText):
                ErrorView(message: message, retryText: retryText, onRetry: onRetry)
            }
        }
        .accessibilityIdentifier("AlbumDetailView")
    }

    private func albumDetailView(album: AlbumDetailViewState.AlbumDetail) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                AsyncImage(url: URL(string: album.artworkUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 250, height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 10)
                    case .failure:
                        placeholderImage
                    case .empty:
                        ProgressView()
                            .frame(width: 250, height: 250)
                    @unknown default:
                        placeholderImage
                    }
                }
                .frame(width: 250, height: 250)

                VStack(spacing: 8) {
                    Text(album.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(album.artistName)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(icon: "calendar", label: "Released", value: album.releaseDate)
                    DetailRow(icon: "music.note", label: "Genre", value: album.genres)
                    DetailRow(icon: "opticaldisc", label: "Tracks", value: "\(album.trackCount)")

                    if let price = album.price {
                        DetailRow(icon: "dollarsign.circle", label: "Price", value: price)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical, 24)
        }
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .frame(width: 250, height: 250)
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
            )
    }
}

struct DetailRow: View {

    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }

            Spacer()
        }
    }
}

#Preview("Loaded") {
    AlbumDetailScreen(
        state: AlbumDetailViewState(
            title: "Album Details",
            content: .loaded(
                AlbumDetailViewState.AlbumDetail(
                    id: "1",
                    name: "Wicked: For Good – The Soundtrack",
                    artistName: "Wicked Movie Cast, Cynthia Erivo & Ariana Grande",
                    artworkUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/e8/77/90/e87790f8-1dd6-d64b-3d5d-6083552aca7f/25UM1IM45249.rgb.jpg/200x200bb.png",
                    releaseDate: "Nov 22, 2024",
                    genres: "Soundtrack, Music",
                    trackCount: 12,
                    price: "$9.99"
                )
            )
        ),
        onRetry: {}
    )
}

#Preview("Loading") {
    AlbumDetailScreen(
        state: AlbumDetailViewState(
            title: "Album Details",
            content: .loading("Loading album details...")
        ),
        onRetry: {}
    )
}

#Preview("Error") {
    AlbumDetailScreen(
        state: AlbumDetailViewState(
            title: "Album Details",
            content: .error("Failed to load album details", retryText: "Retry")
        ),
        onRetry: {}
    )
}
