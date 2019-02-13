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

class UniversitySearchService {
    
    let universityObtainingService: BaseBackendService
    let logoObtainingService: BaseBackendService
    
    init() {
        let universityBaseURL: URL = URL(string: Const.universityBaseURL)!
        
        let logoBaseURL: URL = URL(string: Const.logoBaseURL)!

        self.universityObtainingService = BaseBackendService(universityBaseURL)
        self.logoObtainingService = BaseBackendService(logoBaseURL)
    }
    
    func searchUniversities(byParticialName name: String,
                            onSuccess: @escaping (_ result: [UniversitySearchResponse]) -> (),
                            onFailure: @escaping (_ error: Error) -> ()) {
        
        universityObtainingService.performRequest(UniversitySearchRequest.init(universityName: name), success: { (data) in
            guard let _data = data else {
                DispatchQueue.main.async {
                    onFailure(UniversitySearchServiceError.unparsibleData(underlyingError: nil, serverData: data ?? Data()))
                }
                return
            }
            
            let list: [UniversitySearchResponse] = (try? JSONDecoder().decode([UniversitySearchResponse].self, from: _data)) ?? []
            
            DispatchQueue.main.async {
                onSuccess(list)
            }
        }) { (error) in
            DispatchQueue.main.async {
                onFailure(error)
            }
        }
    }
    
    func obtainLogo(byUnivercityDomain domain: String,
                    onSuccess: @escaping (_ result: UIImage) -> (),
                    onFailure: @escaping (_ error: Error) -> ()) {
        
        universityObtainingService.performRequest(UniversityLogoRequest.init(universityDomain: domain), success: { (data) in
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
}
