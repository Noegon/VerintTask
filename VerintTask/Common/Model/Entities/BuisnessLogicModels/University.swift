//
//  University.swift
//  VerintTask
//
//  Created by astafeev on 2/13/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import Foundation

struct University: Hashable {
    
    var webPages: [String]
    var alphaTwoCode: String
    var country: String
    var domains: [String]
    var name: String
    var isFavourite: Bool
    var logotype: Data?
    
    init(webPages: [String],
         alphaTwoCode: String,
         country: String,
         domains: [String],
         name: String,
         isFavourite: Bool = false,
         logotype: Data? = nil) { // default struct initializer
        
        self.webPages = webPages
        self.alphaTwoCode = alphaTwoCode
        self.country = country
        self.domains = domains
        self.name = name
        self.isFavourite = isFavourite
        self.logotype = logotype
    }
    
    public var hashValue: Int {
        get {
            return "\(name)\(domains)\(country)\(alphaTwoCode)".hashValue
        }
    }
}

func == (lhs: University, rhs: University) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
