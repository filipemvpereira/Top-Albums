//
//  AlbumRowView.swift
//  FeatureAlbumList
//
//  Created by Filipe Pereira on 05/12/2025.
//

import SwiftUI

struct AlbumRowView: View {

    let item: AlbumListViewState.Item

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 60, height: 60)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 60)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    AlbumRowView(
        item: AlbumListViewState.Item(
            id: "1",
            title: "Wicked: For Good – The Soundtrack",
            subtitle: "Wicked Movie Cast, Cynthia Erivo & Ariana Grande",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/e8/77/90/e87790f8-1dd6-d64b-3d5d-6083552aca7f/25UM1IM45249.rgb.jpg/60x60bb.png"
        )
    )
    .previewLayout(.sizeThatFits)
    .padding()
}
