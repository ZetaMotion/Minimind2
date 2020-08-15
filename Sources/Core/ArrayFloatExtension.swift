//
//  array_float_extension.swift
//  Minimind2
//
//  Created by Phan Quoc Huy on 6/12/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Accelerate

//MARK: Array extensions

public extension Array where Element == Float {
    func mean() -> Element {
        return Minimind2.mean(self)
    }
    
    func std() -> Element {
        return Minimind2.std(self)
    }
    
    func sum() -> Element {
        return Minimind2.sum(self)
    }
    
    func norm() -> Element {
        return sqrt((self * self).sum())
    }
    
    func cumsum() -> [Element] {
        return Minimind2.cumsum(self)
    }
}

//MARK: ARITHMETIC

public func std(_ arr: [Float]) -> Float {
    var m: Float = 0.0
    var s: Float = 0.0
    vDSP_normalize(arr, 1, nil, 1, &m, &s, vDSP_Length(arr.count) )
    return s
}

