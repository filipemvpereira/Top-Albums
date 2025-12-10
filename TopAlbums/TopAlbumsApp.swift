//
//  TopAlbums.swift
//  TopAlbums
//
//  Created by Filipe Pereira on 03/12/2025.
//

import SwiftUI

@main
struct TopAlbumsApp: App {

    init() {
        AppDI.setup()
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
        }
    }
}
