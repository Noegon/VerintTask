//
//  Collection+CollectionExtensions.swift
//  VerintTask
//
//  Created by astafeev on 2/13/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

public extension Collection {
    
    public subscript(safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
