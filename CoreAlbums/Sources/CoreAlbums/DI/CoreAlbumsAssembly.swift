//
//  CoreAlbumsAssembly.swift
//  CoreAlbums
//
//  Created by Filipe Pereira on 05/12/2025.
//

import Network
import Swinject

public class CoreAlbumsAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(AlbumRepository.self) { resolver in
            return DefaultAlbumRepository(
                networkService: resolver.resolve(NetworkService.self)!
            )
        }.inObjectScope(.container)
    }
}
