//
//  UniversitySearchRequest.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import Foundation

private extension UniversitySearchRequest {
    struct Const {
        static let universityNameKey = "name"
    }
}

internal class UniversitySearchRequest: BackendAPIRequest {
    
    private let universityName: String
    
    var endpoint: String { return "/search" }
    
    var method: HTTPMethod { return .GET }
    
    var bodyParams: Parameters? {
        return nil
    }
    
    var requestParams: Parameters? {
        let dict: Parameters = [
            Const.universityNameKey: universityName
        ]
        return dict
    }
    
    var headers: Headers? {
        return defaultJSONHeaders()
    }
    
    init(universityName: String) {
        self.universityName = universityName
    }
}
