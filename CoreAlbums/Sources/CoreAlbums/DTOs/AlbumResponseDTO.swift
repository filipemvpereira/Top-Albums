//
//  AlbumResponseDTO.swift
//  CoreAlbums
//
//  Created by Filipe Pereira on 05/12/2025.
//

import Foundation

struct AlbumResponse: Decodable {

    let feed: Feed

    struct Feed: Decodable {

        let entry: [AlbumEntryDTO]
    }
}

struct AlbumEntryDTO: Decodable {

    let name: Label
    let images: [Image]
    let itemCount: Label
    let price: Price
    let rights: Label
    let artist: Artist
    let category: Category
    let releaseDate: ReleaseDate
    let id: Id
    let link: Link

    enum CodingKeys: String, CodingKey {

        case name = "im:name"
        case images = "im:image"
        case itemCount = "im:itemCount"
        case price = "im:price"
        case rights
        case artist = "im:artist"
        case category
        case releaseDate = "im:releaseDate"
        case id
        case link
    }

    struct Label: Decodable {

        let label: String
    }

    struct Image: Decodable {

        let label: String
        let attributes: Attributes

        struct Attributes: Decodable {

            let height: String
        }
    }

    struct Price: Decodable {

        let label: String
        let attributes: Attributes

        struct Attributes: Decodable {

            let amount: String
            let currency: String
        }
    }

    struct Artist: Decodable {

        let label: String
    }

    struct Category: Decodable {

        let attributes: Attributes

        struct Attributes: Decodable {

            let label: String
        }
    }

    struct ReleaseDate: Decodable {

        let label: String
        let attributes: Attributes

        struct Attributes: Decodable {

            let label: String
        }
    }

    struct Id: Decodable {

        let attributes: Attributes

        struct Attributes: Decodable {

            let id: String

            enum CodingKeys: String, CodingKey {

                case id = "im:id"
            }
        }
    }

    struct Link: Decodable {

        let attributes: Attributes

        struct Attributes: Decodable {

            let href: String
        }
    }
}

// MARK: - Mapper
extension AlbumEntryDTO {
    func toDomain() -> Album {
        let smallImage = images.first { $0.attributes.height == "55" }?.label ?? ""
        let mediumImage = images.first { $0.attributes.height == "60" }?.label ?? ""
        let largeImage = images.first { $0.attributes.height == "170" }?.label ?? ""

        return Album(
            id: id.attributes.id,
            name: name.label,
            artistName: artist.label,
            artworkUrl: mediumImage,
            artworkUrlSmall: smallImage,
            artworkUrlLarge: largeImage,
            price: price.label,
            priceAmount: Double(price.attributes.amount),
            currency: price.attributes.currency,
            genre: category.attributes.label,
            releaseDate: releaseDate.label,
            releaseDateFormatted: releaseDate.attributes.label,
            itemCount: Int(itemCount.label) ?? 0,
            copyright: rights.label,
            itunesUrl: link.attributes.href
        )
    }
}
