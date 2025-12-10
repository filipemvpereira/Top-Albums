//
//  LocalizedResourcesRepository.swift
//  CoreResources
//
//  Created by Filipe Pereira on 08/12/2025.
//

import Foundation

public protocol LocalizedResourcesRepository {

    func getString(key: String) -> String?
    func getString(key: String, arguments: [CVarArg]) -> String?
}

final class DefaultLocalizedResourcesRepository: LocalizedResourcesRepository {

    func getString(key: String) -> String? {
        return Bundle.module.localizedString(forKey: key, value: nil, table: "Localizable_en")
    }

    func getString(key: String, arguments: [CVarArg]) -> String? {
        guard let format = getString(key: key) else { return nil }
        return String(format: format, arguments: arguments)
    }
}
