//
//  UniversitiesProvider.swift
//  VerintTask
//
//  Created by astafeev on 2/13/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import Foundation
import UIKit

internal enum UniversitySearchProviderError {
    case noSuchEntity(underlyingError: Error?)
}

extension UniversitySearchProviderError: CoreError {
    
    var code: Int {
        switch self {
        case .noSuchEntity(_):
            return 401
        }
    }
    
    var debugDescription: String {
        switch self {
        case .noSuchEntity(_):
            return "Cannot find target university!"
        }
    }
    
    var underlyingError: Error? {
        switch self {
        case .noSuchEntity(let error):
            return error
        }
    }
}

class UniversitySearchProvider {
    
    private let wrapperQueue: DispatchQueue = DispatchQueue.init(label: "provider.update", qos: DispatchQoS.utility,
                                                                 attributes: DispatchQueue.Attributes.concurrent)
    
    // Current cached search result
    private var __universities: Set<University> = [] // pseudo-storage
    private var _universities: Set<University> {
        get {
            return wrapperQueue.sync {
                return __universities
            }
        }
        set {
            wrapperQueue.async(flags: .barrier) { [weak self] in
                self?.__universities = newValue
            }
        }
    }
    
    var universities: [University] {
        let array = _universities.map { (university) -> University in
            return university
        }
        
        return array
    }
    
    let universitySearchService: UniversitySearchServiceProtocol
    
    init(withUniversityService service: UniversitySearchServiceProtocol) {
        universitySearchService = service
    }
    
    func university(byDomainName name: String) -> University? {
        let result = universities.filter { (university) -> Bool in
            return university.domains.contains(name)
        }
        
        return result[safe: 0]
    }
    
    func updateUniversities(withUniversities universities: [University]) {
        universities.forEach { (entity) in
            _universities.update(with: entity)
        }
    }
    
    func updateUniversities(withUniversity university: University) {
        _universities.update(with: university)
    }
    
    func searchUniversities(byParticialName name: String,
                            onSuccess: @escaping (_ result: [University]) -> (),
                            onFailure: @escaping (_ error: Error) -> ()) {
        
        // Try to obtain data from offline temporary storage
        func filteredentities(byParticialName name: String) -> [University] {
            let result = universities.filter({ (university) -> Bool in
                let words = university.name.split(separator: " ")
                return !(words.filter({ (word) -> Bool in
                    return word.hasPrefix(name)
                }).isEmpty)
            })
            
            return result
        }
        
        let result = filteredentities(byParticialName: name)
        if !result.isEmpty {
            onSuccess(result)
            return
        }
        
        // If there is no desired data - obtain data from server
        universitySearchService.cancelUniversitySearchRequest()
        
        // This logic also should be somewhere in interactor or presenter
        universitySearchService.searchUniversities(byPartialName: name,
                                                   onSuccess:
            { [weak self] (results) in
                self?._universities = self?._universities.union(results) ?? []
                let result = filteredentities(byParticialName: name)
                onSuccess(result)
            },
                                                   onFailure:
            { (error) in
                onFailure(error)
            })
    }
    
    func cancelUniversitySearchRequest() {
         universitySearchService.cancelUniversitySearchRequest()
    }
    
    func obtainLogo(byUniversityDomain domain: String,
                    onSuccess: @escaping (_ result: UIImage?) -> (),
                    onFailure: @escaping (_ error: Error) -> ()) {
        
        // Try to obtain data from offline temporary storage
        let result = university(byDomainName: domain)
        if let result = result, let data = result.logotype {
            onSuccess(UIImage(data: data))
            return
        }
        
        universitySearchService.obtainLogo(byUniversityDomain: domain,
                                           onSuccess:
            { [weak self] (image) in
                if var university = self?.university(byDomainName: domain) {
                    // caching image data inside buisness model
                    university.logotype = image.pngData()
                    // write updated entity back
                    self?._universities.update(with: university)
                    onSuccess(image)
                } else {
                    onFailure(UniversitySearchProviderError.noSuchEntity(underlyingError: nil))
                }
            },
                                           onFailure:
            { (error) in
                onFailure(error)
            })
    }
    
    func cancelLogoObtainRequest() {
        universitySearchService.cancelLogoObtainRequest()
    }
}
