//
//  NibInstantiatable.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import Foundation
import UIKit

protocol NibInstantiatable {
    static var xibName: String { get }
}

extension NibInstantiatable {
    
    static var xibName: String { return String(describing: Self.self) }
    
    static func instance() -> Self {
        return instance(withName: xibName)
    }
    
    static func instance(withOwner owner: AnyObject?) -> Self {
        return instance(withName: xibName, owner: owner)
    }
    
    static func instance(withName name: String, owner: AnyObject? = nil) -> Self {
        let nib = UINib(nibName: name, bundle: nil)
        guard let view = nib.instantiate(withOwner: owner, options: nil).first as? Self else {
            fatalError("failed to load \(name) nib file")
        }
        return view
    }
}
