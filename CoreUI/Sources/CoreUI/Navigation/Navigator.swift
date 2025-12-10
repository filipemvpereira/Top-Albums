//
//  Navigator.swift
//  CoreUI
//
//  Created by Filipe Pereira on 05/12/2025.
//

import Combine
import SwiftUI

@MainActor
public protocol Navigator: ObservableObject, Sendable {

    var path: NavigationPath { get set }

    func navigate(to route: AppRoute)
    func pop()
    func popToRoot()
}
