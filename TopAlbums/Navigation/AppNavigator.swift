//
//  AppNavigator.swift
//  TopAlbums
//
//  Created by Filipe Pereira on 05/12/2025.
//

import Combine
import CoreUI
import FeatureAlbumList
import SwiftUI

@MainActor
final class AppNavigator: Navigator {

    @Published var path = NavigationPath()

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }

    @ViewBuilder
    func build(route: AppRoute) -> some View {
        switch route {
        case .albumList:
            AppDI.albumListView(navigator: self)

        case .albumDetail(let id):
            AppDI.albumDetailView(id: id)
        }
    }
}
