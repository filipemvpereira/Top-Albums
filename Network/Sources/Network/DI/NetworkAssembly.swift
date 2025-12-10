//
//  NetworkAssembly.swift
//  Network
//
//  Created by Filipe Pereira on 03/12/2025.
//

import Alamofire
import Swinject

public class NetworkAssembly: Assembly {

    public init() {}
    
    public func assemble(container: Container) {
        container.register(NetworkService.self) { _ in
            DefaultNetworkService(session: Alamofire.Session.default)
        }.inObjectScope(.container)
    }
}
