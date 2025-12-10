//
//  NetworkError.swift
//  Network
//
//  Created by Filipe Pereira on 03/12/2025.
//

import Foundation

public enum NetworkError: Error {

    case unknown
    case invalidStatusCode
    case noDataReceived
    case bodyParametersSerializationFailed
    case errorResponse(Error)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred"
        case .invalidStatusCode:
            return "Invalid response from server"
        case .noDataReceived:
            return "No data received from server"
        case .bodyParametersSerializationFailed:
            return "Failed to process request"
        case .errorResponse(let error):
            return error.localizedDescription
        }
    }
}
