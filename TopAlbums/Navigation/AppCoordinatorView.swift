//
//  AppCoordinatorView.swift
//  TopAlbums
//
//  Created by Filipe Pereira on 05/12/2025.
//

import CoreUI
import FeatureAlbumList
import SwiftUI

struct AppCoordinatorView: View {

    @StateObject private var navigator = AppNavigator()

    var body: some View {
        NavigationStack(path: $navigator.path) {
            navigator.build(route: .albumList)
                .navigationDestination(for: AppRoute.self) { route in
                    navigator.build(route: route)
                }
        }
    }
}
