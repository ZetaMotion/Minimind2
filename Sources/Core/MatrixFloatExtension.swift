//
//  matrix_float_extension.swift
//  Minimind2
//
//  Created by Phan Quoc Huy on 6/10/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Accelerate

public extension Matrix where T == Float {
    var t: Matrix {
        get {
            let newmat = self
            return Minimind2.transpose(newmat)
        }
    }

    func mean(axis: Int) -> Matrix {
        return apply(Minimind2.mean, axis)
    }
    
    func std(axis: Int) -> Matrix {
        return apply(Minimind2.std, axis)
    }
    
    func sum(axis: Int = -1) -> Matrix {
        return apply(Minimind2.sum, axis)
    }
    
    func mean() -> Element {
        return Minimind2.mean(grid)
    }
    
    func std() -> Element {
        return Minimind2.std(grid)
    }
    
    func sum() -> Element {
        return Minimind2.sum(grid)
    }
    
    func cumsum(axis: Int = -1) -> Matrix {
        return apply(Minimind2.cumsum, axis)
    }
}

//MARK: ARITHMETIC
public func add(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with addition")
    
    var results = y
    cblas_saxpy(Int32(x.grid.count), 1.0, x.grid, 1, &(results.grid), 1)
    
    return results
}

public func mul(_ alpha: Float, x: Matrix<Float>) -> Matrix<Float> {
    var results = x
    cblas_sscal(Int32(x.grid.count), alpha, &(results.grid), 1)
    
    return results
}

public func mul(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    precondition(x.columns == y.rows, "Matrix dimensions not compatible with multiplication")
    
    var results = Matrix<Float>(rows: x.rows, columns: y.columns, repeatedValue: 0.0)
    cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(x.rows), Int32(y.columns), Int32(x.columns), 1.0, x.grid, Int32(x.columns), y.grid, Int32(y.columns), 0.0, &(results.grid), Int32(results.columns))
    
    return results
}

public func elmul(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    precondition(x.rows == y.rows && x.columns == y.columns, "Matrix must have the same dimensions")
    var result = Matrix<Float>(rows: x.rows, columns: x.columns, repeatedValue: 0.0)
    result.grid = x.grid * y.grid
    return result
}


public func div(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    let yInv = inv(y)
    precondition(x.columns == yInv.rows, "Matrix dimensions not compatible")
    return mul(x, y: yInv)
}

public func pow(_ x: Matrix<Float>, _ y: Float) -> Matrix<Float> {
    var result = Matrix<Float>(rows: x.rows, columns: x.columns, repeatedValue: 0.0)
    result.grid = pow(x.grid, y)
    return result
}

public func exp(_ x: Matrix<Float>) -> Matrix<Float> {
    var result = Matrix<Float>(rows: x.rows, columns: x.columns, repeatedValue: 0.0)
    result.grid = exp(x.grid)
    return result
}

public func + (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return add(lhs, y: rhs)
}

public func -(lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return lhs + (-rhs)
}

public func * (lhs: Float, rhs: Matrix<Float>) -> Matrix<Float> {
    return mul(lhs, x: rhs)
}

public func * (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return mul(lhs, y: rhs)
}

public func / (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return div(lhs, y: rhs)
}

public func += (lhs: inout Matrix<Float>, rhs: Matrix<Float>) {
    lhs = lhs + rhs
}

public func -= (lhs: inout Matrix<Float>, rhs: Matrix<Float>) {
    lhs = lhs - rhs
}

public func /= (lhs: inout Matrix<Float>, rhs: Matrix<Float>) {
    lhs = lhs / rhs
}

public func *= (lhs: inout Matrix<Float>, rhs: Matrix<Float>) {
    lhs = lhs * rhs
}

public func += (lhs: inout Matrix<Float>, rhs: Float) {
    lhs = lhs + rhs
}

public func -= (lhs: inout Matrix<Float>, rhs: Float) {
    lhs = lhs + (-rhs)
}

public func /= (lhs: inout Matrix<Float>, rhs: Float) {
    lhs = lhs / rhs
}

public func *= (lhs: inout Matrix<Float>, rhs: Float) {
    lhs = lhs * rhs
}

public prefix func -(mat: Matrix<Float>) -> Matrix<Float> {
    return -1.0 * mat
}

public func +(lhs: Matrix<Float>, rhs: Float) -> Matrix<Float> {
    var mat = lhs
    mat.grid = mat.grid + rhs
    return mat
}

// Entry-wise product
public func ∘ (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    var newmat = lhs
    newmat.grid = mul(lhs.grid , y: rhs.grid)
    return newmat
}

//MARK: LINEAR ALGEBRA
public func inv(_ x : Matrix<Float>) -> Matrix<Float> {
    precondition(x.rows == x.columns, "Matrix must be square")
    
    var results = x
    
    var ipiv = [__CLPK_integer](repeating: 0, count: x.rows * x.rows)
    var lwork = __CLPK_integer(x.columns * x.columns)
    var work = [CFloat](repeating: 0.0, count: Int(lwork))
    var error: __CLPK_integer = 0
    var nc = __CLPK_integer(x.columns)
    withUnsafeMutablePointer(to: &nc) {
        sgetrf_($0, $0, &(results.grid), $0, &ipiv, &error)
        sgetri_($0, &(results.grid), $0, &ipiv, &work, &lwork, &error)
    }
    assert(error == 0, "Matrix not invertible")
    
    return results
}

public func inv(_ mat: Matrix<Float>, _ uplo: String) -> Matrix<Float> {
    
    if uplo == "N" {
        return inv(mat)
    } else if (uplo == "U" || uplo == "L")  {
        var A = mat
        var uplo: Int8 = ascii(uplo)
        var dia: Int8 = ascii("N")
        var n: __CLPK_integer = __CLPK_integer(A.rows)
        var info: __CLPK_integer = __CLPK_integer(0)
        withUnsafeMutablePointer(to: &n) {
            strtri_(&uplo, &dia, $0, &(A.grid), $0, &info)
        }
        return A
    } else {
        return mat
    }
}

public func cholesky(_ mat: Matrix<Float>, _ uplo: String = "U") throws -> Matrix<Float> {
    precondition(mat.rows == mat.columns, "Matrix must be square")
    var L = mat
    var _uplo: Int8 = ascii(uplo)
    var n = __CLPK_integer(mat.rows)
    var info: __CLPK_integer = 0
    
    withUnsafeMutablePointer(to: &n) {
        spotrf_(&_uplo, $0, &(L.grid), $0, &info )
    }
    
//    assert(info == 0, "Cholesky failed: " + String(info) )
    if info != 0 {
        throw MatrixError.notPSD
    }
    
    switch uplo {
    case "L":
        return triu(L).t
    case "U":
        return tril(L).t
    default:
        return triu(L).t
    }
}

public func ldlt(_ mat: Matrix<Float>, _ uplo: String = "L") -> Matrix<Float> {
    var L = mat
    var _uplo: Int8 = ascii(uplo)
    var n: __CLPK_integer = __CLPK_integer(mat.rows)
    var info: __CLPK_integer = 0
    var lwork = __CLPK_integer(mat.columns * mat.columns)
    var work = [CFloat](repeating: 0.0, count: Int(lwork))
    var ipiv: [__CLPK_integer] = [__CLPK_integer](repeating: 0, count: Int(n))
    withUnsafeMutablePointer(to: &n) {
        ssytrf_(&_uplo, $0, &(L.grid), $0, &ipiv, &work, &lwork, &info)
    }
    assert(info == 0, "LDLT failed")
    return L
}

public func svd(_ mat: Matrix<Float>, _ jobu: String = "A", _ jobv: String = "A", _ ldu: Int = 1, _ ldvt: Int = 1) -> (Matrix<Float>, Matrix<Float>, Matrix<Float>) {
    //    SGESVD
    var A = mat
    var m: __CLPK_integer = __CLPK_integer(mat.rows)
    var n: __CLPK_integer = __CLPK_integer(mat.columns)
    var _jobu = ascii(jobu)
    var _jobv = ascii(jobv)
    var s: Matrix<Float> = zeros(1, Int(min(m, n)))
    
    var _ldu = __CLPK_integer(ldu)
    if jobu == "A" || jobu == "S" {
        _ldu = m
    }
    
    var u: Matrix<Float> = Matrix()
    if jobu == "A" {
        u = zeros(Int(_ldu), Int(m))
    }
    else if jobu == "S" {
        u = zeros(Int(_ldu), Int(min(m,n)))
    }
    
    var _ldvt = __CLPK_integer(ldvt)
    if jobv == "A" {
        _ldvt = n
    } else if jobv == "S" {
        _ldvt = min(m, n)
    }
    
    var vt: Matrix<Float> = zeros(Int(_ldvt), Int(n))
    
    var info: __CLPK_integer = 0
    
    let (v1, v2) = (3 * min(m,n) + max(m,n), 5 * min(m,n))
    var lwork = __CLPK_integer(max(max(v1, v2), 1)) // __CLPK_integer(mat.columns * mat.columns)
    var work = [CFloat](repeating: 0.0, count: Int(lwork))
    
    withUnsafeMutablePointer(to: &m) {
    sgesvd_(&_jobu, &_jobv, $0, &n, &(A.grid), $0, &(s.grid), &(u.grid), &_ldu, &(vt.grid), &_ldvt, &work, &lwork, &info)
    }
    assert(info == 0, "SVD failed")
    
    return (u, s, vt)
}


public func logdet(_ mat: Matrix<Float>) -> Float {
    let L = try! cholesky(mat, "L")
    return (2.0 * reduce_sum(log(diag(L))))[0,0]
}

public func det(_ mat: Matrix<Float>) -> Float {
    let L = try! cholesky(mat, "L")
    return  powf(reduce_prod(diag(L))[0, 0], 2.0)
}

public func solve_triangular(_ A: Matrix<Float>, _ b: Matrix<Float>, _  uplo: String = "L", _ trans: String = "N") -> Matrix<Float> {
    var aa = A
    var bb = b
    var uplo: Int8 = ascii(uplo)
    var trans: Int8 = ascii("N")
    var dia: Int8 = ascii("N")
    var n: __CLPK_integer = __CLPK_integer(A.rows)
    var nrhs: __CLPK_integer = __CLPK_integer(b.columns)
    var info: __CLPK_integer = __CLPK_integer(0)
    
    withUnsafeMutablePointer(to: &n) {
        strtrs_(&uplo, &trans, &dia, $0, &nrhs, &(aa.grid), $0, &(bb.grid), $0, &info)
    }
    assert(info == 0, "solve triangular failed")
    
    return bb
}

public func cho_solve(_ A: Matrix<Float>, _ b: Matrix<Float>, _  uplo: String = "L") -> Matrix<Float> {
    var aa = A
    var bb = b
    var _uplo: Int8 = ascii(uplo)
    var n: __CLPK_integer = __CLPK_integer(A.rows)
    var nrhs: __CLPK_integer = __CLPK_integer(b.columns)
    var info: __CLPK_integer = __CLPK_integer(0)
    
    withUnsafeMutablePointer(to: &n) {
        spotrs_(&_uplo, $0, &nrhs, &(aa.grid), $0, &(bb.grid), $0, &info)
    }
    
    assert(info == 0, "Cholesky solve failed")
    
    return bb
}

public func cho_factor(_ mat: Matrix<Float>, _ uplo: String = "L") -> Matrix<Float> {
    precondition(mat.rows == mat.columns, "Matrix must be square")
    var L = mat
    var _uplo: Int8 = ascii(uplo)
    var n: __CLPK_integer = __CLPK_integer(mat.rows)
    var info: __CLPK_integer = 0
    withUnsafeMutablePointer(to: &n) {
        spotrf_(&_uplo, $0, &(L.grid), $0, &info )
    }
    return L
}

public func eigh(_ mat: Matrix<Float>, _ uplo: String) -> (Matrix<Float>, Matrix<Float>) {
    var A = mat
    var uplo: Int8 = ascii(uplo)
    var n = __CLPK_integer(A.rows)
    var d = [CFloat](repeating: 0.0, count: A.rows)
    var e = [CFloat](repeating: 0.0, count: A.rows - 1)
    var tau = [CFloat](repeating: 0.0, count: A.rows - 1)
    // CHECK THIS
    var lwork = __CLPK_integer(mat.columns * mat.columns)
    var work = [CFloat](repeating: 0.0, count: Int(lwork))
    var info: __CLPK_integer = 0
    
    withUnsafeMutablePointer(to: &n) {
        ssytrd_(&uplo, $0, &(A.grid), $0, &d, &e, &tau, &work, &lwork, &info)
    }
    assert(info == 0, "QTQ failed")
    
    withUnsafeMutablePointer(to: &n) {
        sorgtr_(&uplo, $0, &(A.grid), $0, &tau, &work, &lwork, &info)
    }
    assert(info == 0, "Q computation failed")
    
    var compz: Int8 = ascii("V")
    withUnsafeMutablePointer(to: &n) {
        ssteqr_(&compz, $0, &d, &e, &(A.grid), $0, &work, &info)
    }
    
    assert(info == 0, "QR failed")
    
    return (Matrix<Float>(1, Int(n), d), A)
}

public func transpose(_ x: Matrix<Float>) -> Matrix<Float> {
    var results = Matrix<Float>(rows: x.columns, columns: x.rows, repeatedValue: 0.0)
    vDSP_mtrans(x.grid, 1, &(results.grid), 1, vDSP_Length(results.rows), vDSP_Length(results.columns))
    
    return results
}

postfix operator ′
public postfix func ′ (value: Matrix<Float>) -> Matrix<Float> {
    return transpose(value)
}

infix operator **
public func ** (_ mat: Matrix<Float>, _ e: Float) -> Matrix<Float> {
    let newgrid: [Float] = mat.grid.map{ powf($0, e) }
    return Matrix<Float>( mat.rows, mat.columns, newgrid)
}

//MARK: MATH FUNCTIONS

/// compute the norm of an matrix
/// Parameter mat: Matrix
/// Parameter ord: order of the norm, can be F, f, E, e for Frobenius, I, i for Infinity, M, m for Max
public func norm(_ mat: Matrix<Float>, _ ord: String) -> Float {
    var n = __CLPK_integer(mat.columns)
    var m = __CLPK_integer(mat.rows)
    var a = mat
    var norm = ascii(ord)
    var work = [__CLPK_real](repeatElement(0.0, count: Int(m)))
        
    var re: Double = 0
    withUnsafeMutablePointer(to: &m) {
        re = slange_(&norm, $0, &n, &(a.grid), $0, &work)
    }
    // let re = slange_(&norm, &m, &n, &(a.grid), &m, &work)
    return Float(re)
}

public func log(_ mat: Matrix<Float>) -> Matrix<Float> {
    return Matrix<Float>(mat.rows, mat.columns, log(mat.grid))
}

//MARK: CREATORS
public func randMatrix(_ rows: Int,_ columns: Int) -> Matrix<Float> {
    return Matrix<Float>(rows, columns, randArray(n: rows * columns))
}

