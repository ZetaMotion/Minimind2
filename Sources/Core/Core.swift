//
//  core.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/14/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

public typealias FloatType = ExpressibleByFloatLiteral & FloatingPoint
public typealias IntType = SignedInteger
public typealias IndexType = Int 

//MARK: Can ScalaType be SignedNumber ?

//public typealias HasComparisonOps = Comparable & Equatable
public typealias ScalarType = HasSign & HasZero & HasOne & HasArithmeticOps & HasComparisonOps & HasNaN // SignedNumeric //
public typealias FloatingPointScalarType = ScalarType & BinaryFloatingPoint

public protocol HasNaN {
    var isNaN: Bool {get}
}

public protocol HasSign {
    prefix static func -(x: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func abs(_ x: Self) -> Self
}

public protocol HasZero {
    static var zero: Self {get}
}

public protocol HasOne {
    static var one: Self {get}
}

public protocol HasArithmeticOps {
    static func +(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
}

extension HasArithmeticOps{
    static func +=(lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    static func *=(lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    static func /=(lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
}

extension HasArithmeticOps where Self: HasSign {
    static func -=(lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
}

public protocol HasComparisonOps: Comparable {
    
}
//public protocol HasComparisonOps {
//    static func > (lhs: Self, rhs: Self) -> Bool
//    static func < (lhs: Self, rhs: Self) -> Bool
//    static func >= (lhs: Self, rhs: Self) -> Bool
//    static func <= (lhs: Self, rhs: Self) -> Bool
//    static func == (lhs: Self, rhs: Self) -> Bool
//}

//extension ScalarType where Self: BinaryFloatingPoint {
//    
//}

extension BinaryFloatingPoint where Self: ScalarType {

    public static var zero: Self {
        get {
            return 0.0
        }
    }
    
    public static var one: Self {
        get {
            return 1.0
        }
    }
}

extension Float: ScalarType  {
    public static func abs(_ x: Float) -> Float {
        if x < 0 {
            return x * -1
        } else {
            return x
        }
    }
    
    public static var zero: Float {
        get {
            return Float(0.0)
        }
    }
    
    public static var one: Float {
        get {
            return Float(1.0)
        }
    }
    
}

extension Double: ScalarType {
    public static func abs(_ x: Double) -> Double {
        if x < 0 {
            return x * -1
        } else {
            return x
        }
    }
    
    public static var zero: Double {
        get {
            return Double(0.0)
        }
    }
    public static var one: Double {
        get {
            return Double(1.0)
        }
    }
}

extension Int: ScalarType {
    //TODO: very inappropriate for now
    public var isNaN: Bool {
        return self == Int.min
    }

    public static func abs(_ x: Int) -> Int {
        if x < 0 {
            return x * -1
        } else {
            return x
        }
    }

    public static var zero: Int {
        get {
            return 0
        }
    }
    public static var one: Int {
        get {
            return 1
        }
    }
}

extension Int8: ScalarType {
    public var isNaN: Bool {
        return self == Int8.min
    }

    public static func abs(_ x: Int8) -> Int8 {
        if x < 0 {
            return x * -1
        } else {
            return x
        }
    }

    public static var zero: Int8 {
        get {
            return 0
        }
    }
    public static var one: Int8 {
        get {
            return 1
        }
    }
}

extension Bool: ScalarType {
    public static func *= (lhs: inout Bool, rhs: Bool) {
        lhs = lhs * rhs
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        if source == 0 {
            self = true
        } else {
            self = false
        }
    }
    
    public var magnitude: Int8 {
        if self == true {
            return 1
        } else {
            return 0
        }
    }
    
    public init(integerLiteral value: Int8) {
        if value == 0 {
            self = true
        } else {
            self = false
        }
    }
    
    public typealias Magnitude = Int8
    
    public typealias IntegerLiteralType = Int8
    
    public var isNaN: Bool {
        return false
    }

    public static func abs(_ x: Bool) -> Bool {
        return x
    }
    
    public prefix static func -(x: Bool) -> Bool {
        return !x
    }

    public static func /(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && rhs
    }

    public static func <=(lhs: Bool, rhs: Bool) -> Bool {
        return (lhs < rhs) || (lhs == rhs)
    }

    public static func >=(lhs: Bool, rhs: Bool) -> Bool {
        return (lhs > rhs) || (rhs == lhs)
    }

    public static func >(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && !rhs
    }

    public static func <(lhs: Bool, rhs: Bool) -> Bool {
        return !lhs && rhs
    }

    public static var zero: Bool {
        get {
            return false
        }
    }
    
    public static var one: Bool {
        get {
            return true
        }
    }
    
    public static func +(lhs: Bool, rhs: Bool) -> Bool {
        return lhs || rhs
    }
    
    public static func -(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && (!rhs)
    }
    
    public static func *(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && rhs
    }
}

//MARK: Scalar operators
public func close<T: FloatingPointScalarType>(_ a: T, _ b: T, _ tol: T=1e-4) -> Bool {
    return abs(a - b) < tol
}

