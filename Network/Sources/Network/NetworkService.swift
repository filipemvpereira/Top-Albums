//
//  NetworkService.swift
//  Network
//
//  Created by Filipe Pereira on 03/02/2025.
//

import Alamofire
import Foundation

public protocol NetworkService {

    func data(request: NetworkRequest) async throws -> NetworkResponse
}

final class DefaultNetworkService: NetworkService {

    private let session: Alamofire.Session

    init(session: Alamofire.Session) {
        self.session = session
    }

    func data(request: NetworkRequest) async throws -> NetworkResponse {
        print("[Network] Starting request to: \(request.url)")
        let parameters = try buildParameters(from: request.body)

        let dataRequest = session.request(
            request.url,
            method: convertHttpMethod(httpMethod: request.method),
            parameters: parameters,
            encoding: request.method == .get ? URLEncoding.default : JSONEncoding.default
        )
        .cacheResponse(using: .cache)
        .validate()
        .cURLDescription { description in
            print("[Network] Request: \(description)")
        }

        print("[Network] Awaiting response...")
        let response = await dataRequest.serializingData().response

        print("[Network] Response status code: \(response.response?.statusCode ?? -1)")
        print("[Network] Response result: \(response.result)")

        guard let statusCode = response.response?.statusCode else {
            print("[Network] Error: Invalid status code")
            throw NetworkError.invalidStatusCode
        }

        switch response.result {
        case .success(let data):
            print("[Network] Success: Received \(data.count) bytes")
            return NetworkResponse(
                statusCode: statusCode,
                body: data
            )

        case .failure(let error):
            print("[Network] Error: \(error.localizedDescription)")
            throw NetworkError.errorResponse(error)
        }
    }

    private func buildParameters(from body: Data?) throws -> Parameters {
        guard let body = body else {
            return [:]
        }

        guard let json = try JSONSerialization.jsonObject(with: body, options: []) as? Parameters else {
            throw NetworkError.bodyParametersSerializationFailed
        }

        return json
    }

    private func convertHttpMethod(httpMethod: NetworkRequest.HttpMethod) -> HTTPMethod {
        switch httpMethod {
        case .get:
            return .get
        case .post:
            return .post
        }
    }
}

