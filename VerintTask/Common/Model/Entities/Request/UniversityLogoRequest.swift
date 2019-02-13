//
//  UniversityLogoRequest.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import Foundation

internal class UniversityLogoRequest: BackendAPIRequest {
    
    private let universityDomain: String
    
    var endpoint: String { return "/\(universityDomain)" }
    
    var method: HTTPMethod { return .GET }
    
    var bodyParams: Parameters? {
        return nil
    }
    
    var requestParams: Parameters? {
        return nil
    }
    
    var headers: Headers? {
        return defaultJSONHeaders()
    }
    
    init(universityDomain: String) {
        self.universityDomain = universityDomain
    }
}
