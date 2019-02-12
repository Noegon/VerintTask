///  Copyright © 2018 Intervale JSC. All rights reserved.

import Foundation
import UIKit

protocol StoryboardInstantiatable {
    static var storyboardName: String { get }
}

extension StoryboardInstantiatable {
    
    static var storyboardName: String { return String(describing: Self.self) }
    
    static func instance() -> Self {
        return instance(withName: storyboardName)
    }
    
    static func instance(withName name: String) -> Self {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? Self else{
            fatalError("failed to load \(name) storyboard file.")
        }
        return vc
    }
}
