//
//  Album.swift
//  CoreAlbums
//
//  Created by Filipe Pereira on 04/12/2025.
//

import Foundation

public struct Album: Identifiable, Equatable {

    public let id: String
    public let name: String
    public let artistName: String
    public let artworkUrl: String
    public let artworkUrlSmall: String
    public let artworkUrlLarge: String
    public let price: String
    public let priceAmount: Double?
    public let currency: String?
    public let genre: String
    public let releaseDate: String
    public let releaseDateFormatted: String
    public let itemCount: Int
    public let copyright: String
    public let itunesUrl: String

    public init(
        id: String,
        name: String,
        artistName: String,
        artworkUrl: String,
        artworkUrlSmall: String,
        artworkUrlLarge: String,
        price: String,
        priceAmount: Double?,
        currency: String?,
        genre: String,
        releaseDate: String,
        releaseDateFormatted: String,
        itemCount: Int,
        copyright: String,
        itunesUrl: String
    ) {
        self.id = id
        self.name = name
        self.artistName = artistName
        self.artworkUrl = artworkUrl
        self.artworkUrlSmall = artworkUrlSmall
        self.artworkUrlLarge = artworkUrlLarge
        self.price = price
        self.priceAmount = priceAmount
        self.currency = currency
        self.genre = genre
        self.releaseDate = releaseDate
        self.releaseDateFormatted = releaseDateFormatted
        self.itemCount = itemCount
        self.copyright = copyright
        self.itunesUrl = itunesUrl
    }
}
