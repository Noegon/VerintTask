//
//  URLSessionPinningDelegate.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import Foundation
import Security


internal enum ServerSecurityValidation {
    case defaultBehavior
    case checkWithCertificate
}

class URLSessionPinningDelegateQueue {
    
    static let shared = URLSessionPinningDelegateQueue()
    
    let queue = OperationQueue()
    
    private let underlyingQueue: DispatchQueue
    
    private init() {
        
        queue.qualityOfService = .userInitiated
        queue.name = "com.network.session_pinning.queue"
        
        underlyingQueue = DispatchQueue.init(label: queue.name!,
                                             qos: DispatchQoS.userInitiated)
        queue.underlyingQueue = underlyingQueue
    }
}

class URLSessionPinningDelegate: NSObject, URLSessionTaskDelegate {
    
    private var stringURL: String
    
    private var certificateFileNames: Set<String>
    
    var taskWillPerformHTTPRedirection: ((URLSession, URLSessionTask, HTTPURLResponse, URLRequest) -> URLRequest?)?
    var taskDidReceiveChallenge: ((URLSession, URLSessionTask, URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))?
    var taskNeedNewBodyStream: ((URLSession, URLSessionTask) -> InputStream?)?
    var taskDidCompleteWithError: ((URLSession, URLSessionTask, Error?) -> Void)?
    
    init(withURL url: URL, certificateFileNames: Set<String>?) {
        self.stringURL = url.absoluteString
        self.certificateFileNames = certificateFileNames ?? []
    }
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
        var success: Bool = false
        
        var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
        var credential: URLCredential?
        
        if let serverTrust = challenge.protectionSpace.serverTrust {
            
            if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
                
                let host = challenge.protectionSpace.host
                
                if stringURL.contains(host) {
                    completionHandler(disposition, credential)
                    return
                }
                
                //Set policy to validate domain
                let policy: SecPolicy = SecPolicyCreateSSL(true, stringURL as CFString)
                let policies = NSArray.init(object: policy)
                SecTrustSetPolicies(serverTrust, policies)
                
                let certificateCount: CFIndex = SecTrustGetCertificateCount(serverTrust)
                
                if certificateCount > 0 {
                    
                    if let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        
                        let serverCertificateData = SecCertificateCopyData(certificate) as NSData
                        
                        //for loop over array which may contain expired + upcoming certificate
                        for filenameString: String in certificateFileNames {
                            
                            let filePath = Bundle.main.path(forResource: filenameString, ofType: "cer")
                            
                            if let file = filePath {
                                
                                if let localCertData = NSData(contentsOfFile: file) {
                                    
                                    //Set anchor cert to your own server
                                    if let localCert: SecCertificate = SecCertificateCreateWithData(nil, localCertData) {
                                        let certArray = [localCert] as CFArray
                                        SecTrustSetAnchorCertificates(serverTrust, certArray)
                                    }
                                    
                                    //validates a certificate by verifying its signature plus the signatures of the certificates in its certificate chain, up to the anchor certificate
                                    var result = SecTrustResultType.invalid
                                    SecTrustEvaluate(serverTrust, &result);
                                    let isValid: Bool = (result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed)
                                    
                                    if (isValid) {
                                        
                                        //Validate host certificate against pinned certificate.
                                        if serverCertificateData.isEqual(to: localCertData as Data) {
                                            success = true
                                            
                                            disposition = .useCredential
                                            credential = URLCredential(trust:serverTrust)
                                            break //found a successful certificate, don't need to continue looping
                                        } //end if serverCertificateData.isEqual(to: localCertData as Data)
                                    } //end if (isValid)
                                } //end if let localCertData = NSData(contentsOfFile: file)
                            } //end if let file = filePath
                        } //end for filenameString: String in certFilenames
                        
                    } //end if let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
                    
                } //end if certificateCount > 0
                
            } //end if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
            
        } //end if let serverTrust = challenge.protectionSpace.serverTrust
        
        if (success == false) {
            disposition = .cancelAuthenticationChallenge
        }
        
        completionHandler(disposition, credential)
    }
}
