//
//  AlbumListAssembly.swift
//  FeatureAlbumList
//
//  Created by Filipe Pereira on 05/12/2025.
//

import CoreAlbums
import CoreResources
import CoreUI
import Swinject

public class AlbumListAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(GetTopAlbumsUseCase.self) { resolver in
            return DefaultGetTopAlbumsUseCase(
                repository: resolver.resolve(AlbumRepository.self)!
            )
        }

        container.register(AlbumListViewModel.self) { resolver in
            return AlbumListViewModel(
                useCase: resolver.resolve(GetTopAlbumsUseCase.self)!,
                resources: resolver.resolve(LocalizedResourcesRepository.self)!
            )
        }

        container.register(AlbumListView.self) { (resolver, navigator: Navigator) in
            return AlbumListView(
                viewModel: resolver.resolve(AlbumListViewModel.self)!,
                navigator: navigator)
        }
    }
}
