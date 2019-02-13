//
//  BaseBackendService.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import Foundation


public protocol BackendService {
    
    func performRequest(_ request: BackendAPIRequest,
                        configuration: URLSessionConfiguration,
                        certificates: Set<String>,
                        success: ((Data?) -> Void)?,
                        failure: ((CoreError) -> Void)?)
    
    func cancel()
}

internal enum BackendServiceError {
    
    case incorrectRequestWithServerData(underlyingError: Error?, serverData: Data)
    case notAllowedNetworkAction(underlyingError: Error?)
}

extension BackendServiceError: CoreError {
    
    var code: Int {
        switch self {
        case .incorrectRequestWithServerData(_, _):
            return 201
        case .notAllowedNetworkAction(_):
            return 202
        }
    }
    
    var debugDescription: String {
        switch self {
        case .incorrectRequestWithServerData(_, _):
            return "Invalid data was sent to server!"
        case .notAllowedNetworkAction(_):
            return "Not allowed network action performed!"
        }
    }
    
    var underlyingError: Error? {
        switch self {
        case .incorrectRequestWithServerData(let error, _),
             .notAllowedNetworkAction(let error):
            return error
        }
    }
}


class BaseBackendService: BackendService {
    
    private let baseURL: URL
    private let networkService = NetworkService()
    
    init(_ baseURL: URL) {
        self.baseURL = baseURL
    }
    
    public func performRequest(_ request: BackendAPIRequest,
                               configuration: URLSessionConfiguration = .default,
                               certificates: Set<String> = [],
                               success: ((Data?) -> Void)? = nil,
                               failure: ((CoreError) -> Void)? = nil) {
        
        let url = baseURL.appendingPathComponent(request.endpoint)
        
        let config = configuration
        
        let certificates = certificates
        
        let headers = request.headers
        
        printInMainThread("Start executing request: [\(request.self)]")
        printInMainThread("URL: \(url)")
        printInMainThread("Headers: \(String.beautifiedJSONString(with: headers, defaultValue: "no headers"))")
        printInMainThread("Body params: \(String.beautifiedJSONString(with: request.bodyParams, defaultValue: "no body params"))\n")
        
        networkService.performRequest(for: url,
                                      method: request.method,
                                      sessionConfiguration: config,
                                      bodyParams: request.bodyParams,
                                      requestParams: request.requestParams,
                                      headers: headers,
                                      SSLPinningCertificatesFileNames: certificates,
                                      onSuccess:
            { (data, httpResponse) in
                printInMainThread("Request successful: [\(request.self)]")
                printInMainThread("ResponseCode: \(httpResponse.statusCode)")
                printInMainThread("URL: \(url)")
                printInMainThread("Response headers: [\(String.beautifiedJSONString(with: httpResponse.allHeaderFields as? [String: Any], defaultValue: "no headers"))]")
                printInMainThread("Response params: \(String.beautifiedJSONString(with: data, defaultValue: "no response params"))\n")
                
                success?(data)
            },
                                      onFailure:
            { (data, error, httpResponse) in
                printInMainThread("Request failed: [\(request.self)]")
                printInMainThread("ResponseCode: \(httpResponse?.statusCode ?? 500)")
                printInMainThread("URL: \(url)")
                printInMainThread("Response headers: [\(String.beautifiedJSONString(with: httpResponse?.allHeaderFields as? [String: Any], defaultValue: "no headers"))]")
                
                if let data = data {
                    
                    // If sever send json with error parameters, added raw additional info to handle this error on upper level
                    let error: CoreError = BackendServiceError.incorrectRequestWithServerData(underlyingError: error, serverData: data)
                    printInMainThread("Error params: \(String.beautifiedJSONString(with: data, defaultValue: "no error params"))\n")
                    failure?(error)
                } else {
                    
                    // If there if some error - it goes further, and if it isn't - new Unknown error creates
                    let error: CoreError = BackendServiceError.notAllowedNetworkAction(underlyingError: error)
                    printInMainThread("No error params received\n")
                    failure?(error)
                }
            })
    }
    
    func cancel() {
        networkService.cancel()
    }
}

// MARK: - Network logging helper
fileprivate extension String {
    
    static func beautifiedJSONString(with dictionary: [String: Any]?, defaultValue: String? = nil) -> String {
        var result: String?
        if let jsonObject = dictionary {
            
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            
            if let jsonData = jsonData {
                result = String(data: jsonData, encoding: .utf8) ?? defaultValue
            }
        }
        
        return result ?? defaultValue ?? ""
    }
    
    static func beautifiedJSONString(with data: Data?, defaultValue: String? = nil) -> String {
        
        guard let data = data else {
            return defaultValue ?? ""
        }
        
        guard let rawJSONObject = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) else {
            return defaultValue ?? ""
        }
        
        if let jsonObject = rawJSONObject as? [String: Any] {
            return String.beautifiedJSONString(with: jsonObject)
        }
        
        if let jsonArray = rawJSONObject as? [Any] {
            return String.beautifiedJSONString(with: ["objects": jsonArray])
        }
        
        return defaultValue ?? ""
    }
}

fileprivate func printInMainThread(_ string: String) -> Void {
    DispatchQueue.main.async {
        print(string)
    }
}
