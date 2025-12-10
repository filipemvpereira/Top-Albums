//
//  AppDI.swift
//  TopAlbums
//
//  Created by Filipe Pereira on 05/12/2025.
//

import CoreAlbums
import CoreResources
import CoreUI
import FeatureAlbumDetail
import FeatureAlbumList
import Network
import Swinject
import SwiftUI

class AppDI {

    private static let shared = AppDI()

    private var assembler: Assembler!

    private init() {}

    static func setup() {
        shared.assembler = Assembler([
            NetworkAssembly(),
            CoreAlbumsAssembly(),
            CoreResourcesAssembly(),
            AlbumListAssembly(),
            AlbumDetailAssembly()
        ])
    }

    static func albumListView(navigator: any Navigator) -> AlbumListView {
        shared.assembler.resolver.resolve(AlbumListView.self, argument: navigator)!
    }

    static func albumDetailView(id: String) -> AlbumDetailView {
        shared.assembler.resolver.resolve(AlbumDetailView.self, argument: id)!
    }
}
