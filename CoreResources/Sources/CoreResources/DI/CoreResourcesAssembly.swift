//
//  CoreResourcesAssembly.swift
//  CoreResources
//
//  Created by Filipe Pereira on 08/12/2025.
//

import Swinject

public class CoreResourcesAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(LocalizedResourcesRepository.self) { _ in
            DefaultLocalizedResourcesRepository()
        }.inObjectScope(.container)
    }
}
