//
//  BackendAPIRequest.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import Foundation

public typealias Headers = [String: String]

public protocol BackendAPIRequest {
    
    var endpoint: String { get }
    var method: HTTPMethod { get }
    var bodyParams: Parameters? { get }
    var requestParams: Parameters? { get }
    var headers: Headers? { get }
}

public extension BackendAPIRequest {
    
    func defaultJSONHeaders() -> [String: String] {
        return ["Content-Type": "application/json"]
    }
}
