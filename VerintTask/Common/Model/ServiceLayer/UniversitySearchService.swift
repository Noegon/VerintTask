//
//  UniversitySearchService.swift
//  VerintTask
//
//  Created by astafeev on 2/13/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import Foundation
import UIKit

internal enum UniversitySearchServiceError {
    case unparsibleData(underlyingError: Error?, serverData: Data)
    case invalidImageCreation(underlyingError: Error?)
}

extension UniversitySearchServiceError: CoreError {
    
    var code: Int {
        switch self {
        case .unparsibleData(_, _):
            return 301
        case .invalidImageCreation(_):
            return 302
        }
    }
    
    var debugDescription: String {
        switch self {
        case .unparsibleData(_, _):
            return "Cannot parse data came from server!"
        case .invalidImageCreation(_):
            return "Cannot create image from data!"
        }
    }
    
    var underlyingError: Error? {
        switch self {
        case .unparsibleData(let error, _),
             .invalidImageCreation(let error):
            return error
        }
    }
}

private extension UniversitySearchService {
    struct Const {
        static let universityBaseURL = "http://universities.hipolabs.com"
        static let logoBaseURL = "https://logo.clearbit.com"
    }
}

protocol UniversitySearchServiceProtocol {
    func searchUniversities(byPartialName name: String,
                            onSuccess: @escaping (_ result: [University]) -> (),
                            onFailure: @escaping (_ error: Error) -> ())
    
    func obtainLogo(byUniversityDomain domain: String,
                    onSuccess: @escaping (_ result: UIImage) -> (),
                    onFailure: @escaping (_ error: Error) -> ())
    
    func cancelUniversitySearchRequest()
    
    func cancelLogoObtainRequest()
}

class UniversitySearchService: UniversitySearchServiceProtocol {
    
    var universityObtainingService: BaseBackendService
    var logoObtainingService: BaseBackendService
    
    let universityBaseURL: URL = URL(string: Const.universityBaseURL)!
    let logoBaseURL: URL = URL(string: Const.logoBaseURL)!
    
    init() {
        universityObtainingService = BaseBackendService(universityBaseURL)
        logoObtainingService = BaseBackendService(logoBaseURL)
    }
    
    func searchUniversities(byPartialName name: String,
                            onSuccess: @escaping (_ result: [University]) -> (),
                            onFailure: @escaping (_ error: Error) -> ()) {
        
        universityObtainingService = BaseBackendService(universityBaseURL)
        
        universityObtainingService.performRequest(UniversitySearchRequest.init(universityName: name), success: { (data) in
            guard let _data = data else {
                DispatchQueue.main.async {
                    onFailure(UniversitySearchServiceError.unparsibleData(underlyingError: nil, serverData: data ?? Data()))
                }
                return
            }
            
            let list: [UniversitySearchResponse] = (try? JSONDecoder().decode([UniversitySearchResponse].self, from: _data)) ?? []
            
            let universities = list.map({ (response) -> University in
                return University.init(webPages: response.webPages,
                                       alphaTwoCode: response.alphaTwoCode,
                                       country: response.country,
                                       domains: response.domains,
                                       name: response.name)
            })
            
            DispatchQueue.main.async {
                onSuccess(universities)
            }
        }) { (error) in
            DispatchQueue.main.async {
                onFailure(error)
            }
        }
    }
    
    func obtainLogo(byUniversityDomain domain: String,
                    onSuccess: @escaping (_ result: UIImage) -> (),
                    onFailure: @escaping (_ error: Error) -> ()) {
        
        logoObtainingService = BaseBackendService(logoBaseURL)
        
        logoObtainingService.performRequest(UniversityLogoRequest.init(universityDomain: domain), success: { (data) in
            guard let _data = data else {
                DispatchQueue.main.async {
                    onFailure(UniversitySearchServiceError.unparsibleData(underlyingError: nil, serverData: data ?? Data()))
                }
                return
            }
            
            guard let uiimage = UIImage.init(data: _data) else {
                DispatchQueue.main.async {
                    onFailure(UniversitySearchServiceError.invalidImageCreation(underlyingError: nil))
                }
                return
            }
            
            DispatchQueue.main.async {
                onSuccess(uiimage)
            }
        }) { (error) in
            DispatchQueue.main.async {
                onFailure(error)
            }
        }
    }
    
    func cancelUniversitySearchRequest() {
        universityObtainingService.cancel()
    }
    
    func cancelLogoObtainRequest() {
        logoObtainingService.cancel()
    }
}
