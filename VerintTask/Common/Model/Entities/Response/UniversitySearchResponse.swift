//
//  UniversitySearchResponse.swift
//  VerintTask
//
//  Created by astafeev on 2/13/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import Foundation

internal struct UniversitySearchResponse: ResponseParsedItem {
    
    let webPages: [String]
    let alphaTwoCode: String
    let country: String
    let domains: [String]
    let name: String
    
    init(webPages: [String], alphaTwoCode: String, country: String, domains: [String], name: String) { // default struct initializer
        self.webPages = webPages
        self.alphaTwoCode = alphaTwoCode
        self.country = country
        self.domains = domains
        self.name = name
    }
}

extension UniversitySearchResponse {
    
    private enum ParsedErrorKeys: String, CodingKey { // declaring our keys
        case webPages = "web_pages"
        case alphaTwoCode = "alpha_two_code"
        case country
        case domains
        case name
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: ParsedErrorKeys.self) // defining our (keyed) container
        
        let webPages: [String] = try container.decode([String].self, forKey: .webPages)
        let alphaTwoCode: String = try container.decode(String.self, forKey: .alphaTwoCode)
        let country: String = try container.decode(String.self, forKey: .country)
        let domains: [String] = try container.decode([String].self, forKey: .domains)
        let name: String = try container.decode(String.self, forKey: .name)
        
        self.init(webPages: webPages,
                  alphaTwoCode: alphaTwoCode,
                  country: country,
                  domains: domains,
                  name: name)
    }
}
