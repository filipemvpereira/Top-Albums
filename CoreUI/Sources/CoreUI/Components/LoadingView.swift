//
//  LoadingView.swift
//  CoreUI
//
//  Created by Filipe Pereira on 08/12/2025.
//

import SwiftUI

public struct LoadingView: View {

    let message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                ProgressView()
                Text(message)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView(message: "Loading...")
}
