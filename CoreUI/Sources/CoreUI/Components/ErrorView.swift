//
//  ErrorView.swift
//  CoreUI
//
//  Created by Filipe Pereira on 08/12/2025.
//

import SwiftUI

public struct ErrorView: View {

    let message: String
    let retryText: String
    let onRetry: () -> Void

    public init(
        message: String,
        retryText: String,
        onRetry: @escaping () -> Void
    ) {
        self.message = message
        self.retryText = retryText
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.red)

                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Button {
                    onRetry()
                } label: {
                    Text(retryText)
                        .fontWeight(.semibold)
                        .frame(minWidth: 120)
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ErrorView(
        message: "Failed to load data. Please try again.",
        retryText: "Retry",
        onRetry: {}
    )
}
