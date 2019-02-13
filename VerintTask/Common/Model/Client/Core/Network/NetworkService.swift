//
//  NetworkService.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import Foundation


internal enum NetworkServiceError {
    
    case noInternetConnection(underlyingError: Error?)
    case incorrectRequest(underlyingError: Error?, responseStatusCode: Int)
    case noResponseFromServer(underlyingError: Error?)
    case serverFailure(underlyingError: Error?, responseStatusCode: Int) // http code 500
}

extension NetworkServiceError: CoreError {
    var code: Int {
        switch self {
        case .noInternetConnection(_):
            return 101
        case .incorrectRequest(_, _):
            return 102
        case .noResponseFromServer(_):
            return 103
        case .serverFailure(_, _):
            return 104
        }
    }
    
    var debugDescription: String {
        switch self {
        case .noInternetConnection(_):
            return "Internet connection problem found!"
        case .incorrectRequest(_, let responseStatusCode):
            return "Request failed with code: \(responseStatusCode)."
        case .noResponseFromServer(_):
            return "No response was received from server! Perhaps request timeout occured!"
        case .serverFailure(_, let responseStatusCode):
            return "Request failed with code: \(responseStatusCode). Wrong handling logic, wrong endpoing mapping or backend bug."
        }
    }
    
    var underlyingError: Error? {
        switch self {
        case .noInternetConnection(let error),
             .incorrectRequest(let error, _),
             .noResponseFromServer(let error),
             .serverFailure(let error, _):
            return error
        }
    }
}


/// Main HTTP methods that used for RESTful API creation
///
/// - GET
/// - POST
/// - PUT
/// - DELETE
public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

public typealias Parameters = [String: Any]

/**
 Class allows to perform URLRequest with given parameters and execute it as prepared URLSessionDataTask.
 Class provides closures to handle successful and fail request results.
 */
class NetworkService {
    
    private var task: URLSessionDataTask?
    private var successCodes: CountableRange<Int> = 200..<299
    private var failureCodes: CountableRange<Int> = 400..<499
    
    private var isTaskRejected: Bool = false
    
    /**
     Performs URLRequest by using URLSession with given parameters.
     - Parameter url: given remote resource base URL
     - Parameter method: one of four HTTP methods (`GET`, `POST`, `PUT` or `DELETE`)
     - Parameter sessionConfiguration: URLSessionConfiguration object (set as `.default` if parameter is `nil`)
     - Parameter bodyParams: Dictionary that represents covered parameters (key and value) which are located inside request body and are not visible from outside.
     - Parameter requestParams: Dictionary that represents simple parameters (key and value) which are used inline, mostly for `GET` requests because these parameters are visible.
     - Parameter headers: additional HTTP request headers (key/value).
     - Parameter SSLPinningCertificatesFileNames: names of SSL certificates. Each URL could be associated with more than one certificate.
     - Parameter success: closure that only performs if request was successful.
     - Parameter failure: closure that only performs if request was unsuccessful.
     */
    func performRequest(for url: URL,
                        method: HTTPMethod,
                        sessionConfiguration: URLSessionConfiguration? = nil,
                        bodyParams: Parameters? = nil,
                        requestParams: Parameters? = nil,
                        headers: [String: String]? = nil,
                        SSLPinningCertificatesFileNames certificateFileNames: Set<String>? = nil,
                        onSuccess: ((Data?, _ response: HTTPURLResponse) -> Void)? = nil,
                        onFailure: ((_ data: Data?, _ error: CoreError?, _ response: HTTPURLResponse?) -> Void)? = nil) {
        
        // If task was cancelled in other thread before it was initiated - it will not started at all.
        if isTaskRejected {
            return
        }
        
        var mutableRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        
        // Adding body parameters as JSON data
        if let bodyParams = bodyParams {
            mutableRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyParams, options: [])
        }
        
        // Adding additional request parameters to request string
        if let requestParams = requestParams {
            
            var components = url.absoluteString
            
            components.append(convert(params: requestParams))
            
            if let newUrl = URL(string: components) {
                mutableRequest.url = newUrl
            }
        }

        mutableRequest.allHTTPHeaderFields = headers
        mutableRequest.httpMethod = method.rawValue
        
        let sessionDelegate: URLSessionDelegate? = URLSessionPinningDelegate.init(withURL: url, certificateFileNames: certificateFileNames)
        let session = URLSession.init(configuration: sessionConfiguration ?? .default, delegate: sessionDelegate,
                                      delegateQueue: URLSessionPinningDelegateQueue.shared.queue)
        
        task = session.dataTask(with: mutableRequest as URLRequest, completionHandler: { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else { // If some problems occured while internet connection and there is no any response at all
                let err = NetworkServiceError.noResponseFromServer(underlyingError: nil)
                onFailure?(data, err, nil)
                return
            }
            
            if let err = error {
                // Request failed, might be internet disconnection while request performing
                let err = NetworkServiceError.noInternetConnection(underlyingError: err)
                onFailure?(data, err, httpResponse)
                return
            }
            
            if self.successCodes.contains(httpResponse.statusCode) {
                onSuccess?(data, httpResponse)
            } else if self.failureCodes.contains(httpResponse.statusCode) { // Client errors handling (codes 400 - 499)
                let err = NetworkServiceError.incorrectRequest(underlyingError: nil, responseStatusCode: httpResponse.statusCode)
                onFailure?(data, err, httpResponse)
            } else { // Server errors and redirection handling (codes 500 - 599 & 300 - 399)
                let err = NetworkServiceError.serverFailure(underlyingError: nil, responseStatusCode: httpResponse.statusCode)
                onFailure?(data, err, httpResponse)
            }
        })
        
        // Check for task rejection once again because of multithreading operation! If task was cancelled in other thread before it was initiated - it will be cancelled on this step.
        if isTaskRejected {
            cancel()
        }
        
        task?.resume()
    }
    
    func cancel() {
        isTaskRejected = true
        task?.cancel() // Try to cancel current task. If cancellation performed in other thread, task could be nil, so task rejection should be
    }
}

// MARK: Helpers
fileprivate extension NetworkService {
    
    /**
     Convert a `Parameters` list in an URL query. Used for request additional visible parameters.
     - Parameter params: The list of inline `Parameters` (key/value)
     - Returns: The string that represents an URL query
     */
    private func convert(params: Parameters?) -> String {
        guard let params = params else {
            return ""
        }
        
        var query = ""
        
        params.forEach { key, value in
            let valueString = "\(value)"
            query = query + "\(key)=\(valueString.encode())&"
        }
        
        if query.last == "&" {
            query.removeLast()
        }
        
        return "?" + query
    }
}

fileprivate extension String {
    
    func htmlContentToString() -> String {
        return self.replacingOccurrences(of:"<[^>]+>", with: "" , options: .regularExpression, range: nil).trimmingCharacters(in: .whitespaces)
    }
    
    func encode() -> String {
        let customAllowedSet =  CharacterSet(charactersIn: "+\"#%/<>?@\\^`{|}").inverted
        if let encodedString = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet) {
            return encodedString
        }
        return self
    }
}
