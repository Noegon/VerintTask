//
//  CoreError.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import Foundation


public protocol CoreError: Error {
    
    var code: Int { get }
    
    var debugDescription: String { get }
    
    var underlyingError: Error? { get }
}

public extension CoreError {
    
    var underlyingError: Error? {
        return nil
    }
    
    /// Stack of underlying errors codes
    /// - Returns: array that represents error's codes stack. The top item is the last called error.
    func codesStack() -> [Int] {
        var stack: [Int] = (underlyingError as? CoreError)?.codesStack() ?? []
        stack.insert(code, at: 0)
        return stack
    }
    
    /// Stack of underlying errors
    /// - Returns: array that represents errors stack. The top item is the last called error.
    func errorStack() -> [CoreError] {
        var stack: [CoreError] = (underlyingError as? CoreError)?.errorStack() ?? []
        stack.insert(self, at: 0)
        return stack
    }
    
    /// Detailed user description for error begins from last error in call stack.
    /// Previous error's descriptions are mentoined as reasons of each other.
    /// - Returns: error description for developer
    func fullDebugDescription() -> String {
        let underluingErrorDescription: String = ((underlyingError as? CoreError)?.fullDebugDescription() ?? underlyingError?.systemDebugDescription) ?? ""
        return "[\(type(of: self))]: \(debugDescription)\(!underluingErrorDescription.isEmpty ? "\n\t-> Reason:" : "")\(underluingErrorDescription)"
    }
}

public extension Error {
    /// Retrieve the localized description for this error.
    var systemDebugDescription: String {
        return NSError(domain: _domain, code: _code, userInfo: nil).localizedDescription
    }
}
