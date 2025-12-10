//
//  AlbumDetailAssembly.swift
//  FeatureAlbumDetail
//
//  Created by Filipe Pereira on 05/12/2025.
//

import CoreAlbums
import CoreResources
import Swinject

public class AlbumDetailAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(GetAlbumDetailUseCase.self) { resolver in
            return GetAlbumDetailUseCaseImpl(
                repository: resolver.resolve(AlbumRepository.self)!
            )
        }

        container.register(AlbumDetailViewModel.self) { (resolver, albumId: String) in
            AlbumDetailViewModel(
                albumId: albumId,
                getAlbumDetailUseCase: resolver.resolve(GetAlbumDetailUseCase.self)!,
                resources: resolver.resolve(LocalizedResourcesRepository.self)!
            )
        }

        container.register(AlbumDetailView.self) { (resolver, albumId: String) in
            AlbumDetailView(
                viewModel: resolver.resolve(AlbumDetailViewModel.self, argument: albumId)!
            )
        }
    }
}
