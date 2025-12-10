//
//  NetworkResponse.swift
//  Network
//
//  Created by Filipe Pereira on 03/12/2025.
//

import Foundation

public class NetworkResponse {

    public let statusCode: Int
    public let body: Data

    public init(statusCode: Int, body: Data) {
        self.statusCode = statusCode
        self.body = body
    }
}
