//
//  UIView+Constraints.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import UIKit

extension UIView {
    
    public func addConstraintsToView(attribute: NSLayoutConstraint.Attribute, relatedBy: NSLayoutConstraint.Relation, secondItem: UIView?, secondAttribute: NSLayoutConstraint.Attribute, offset: CGFloat) {
        
        NSLayoutConstraint(item: self,
                           attribute: attribute,
                           relatedBy: relatedBy,
                           toItem: secondItem,
                           attribute: secondAttribute,
                           multiplier: 1,
                           constant: offset).isActive = true
    }
    
    public func addConstraintsToSuperview(offset: CGFloat, attribute: NSLayoutConstraint.Attribute) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: attribute,
                           relatedBy: .equal,
                           toItem: self.superview,
                           attribute: attribute,
                           multiplier: 1,
                           constant: offset).isActive = true
    }
    
    // for all edges
    public func addConstraintsToSuperview(ofsset: CGFloat) {
        addConstraintsToSuperview(offset: ofsset, attribute: .leading)
        addConstraintsToSuperview(offset: ofsset, attribute: .trailing)
        addConstraintsToSuperview(offset: ofsset, attribute: .top)
        addConstraintsToSuperview(offset: ofsset, attribute: .bottom)
    }
    
    public func addConstraints(height: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: height).isActive = true
    }
    
    public func addConstaints(width: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: width).isActive = true
    }
    
    public func addConstraints(height: CGFloat, width: CGFloat) {
        addConstaints(width: width)
        addConstraints(height: height)
    }
    
    public func addConstraintsXanchor(toView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .centerX,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    public func addConstraintsYanchor(toView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .centerY,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    public func addConstraintsCentered(toView view: UIView) {
        addConstraintsXanchor(toView: view)
        addConstraintsYanchor(toView: view)
    }
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem as Any, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

