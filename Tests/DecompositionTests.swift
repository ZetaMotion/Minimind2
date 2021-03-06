//
//  decompositionTests.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/16/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import XCTest
@testable import Minimind2

class decompositionTests: XCTestCase {
    let N: Int = 20
    let D: Int = 10
    let Q: Int = 2
    
    var Y: Matrix<Float> = Matrix()
    var X: Matrix<Float> = Matrix()

    override func setUp() {
        super.setUp()
        self.Y = zeros(N, D)
        self.X = zeros(N, Q)
        
//        let cov = Matrix<Float>([[1.0, 0.1],[0.1, 1.0]])
//        let mean1 = Matrix<Float>([[-3, 0]])
//        let mean2 = Matrix<Float>([[3, 0]])
//        
//        let X1 = MultivariateNormal(mean: mean1, cov: cov).rvs(N / 2)
//        let X2 = MultivariateNormal(mean: mean2, cov: cov).rvs(N / 2)
//        let xx = vstack([X1, X2])
//        X = xx .- xx.mean(axis: 0)
//        X = X ./ X.std(axis: 0)
//        
//        let A: Matrix<Float> = randMatrix(Q, D)
//        Y = X * A + 0.01 * randMatrix(N, D)
        
        let u: [Float] = linspace(-3, 3, N)
        let s1 = Matrix([sin(u)])
        let s2 = Matrix([-cos(u) * cos(u)])
        
        let A: Matrix<Float> = randMatrix(1, Int(D / 2))
        
        let Y1 = s1.t * A + 0.01 * randMatrix(N, Int(D / 2))
        let Y2 = s2.t * A + 0.01 * randMatrix(N, Int(D / 2))
        
        let yy = hstack([Y1, Y2])
        Y = yy - yy.mean()
        Y = Y / Y.std()
        
        let xx = vstack([s1, s2]).t
        X = xx .- xx.mean(axis: 0)
        X = X ./ X.std(axis: 0)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testPCA() {
        let pca = PCA(nComponents: 2)
        pca.fit(Y)
        let X = pca.predict(Y)
        
        print(X)
    }
    
    func testGPLVM() {
        let pca = PCA(nComponents: Q)
        pca.fit(Y)
        let initX = pca.predict(Y)
        
        let kern = RBF(variance: 10.0, lengthscale: 10.0, X: initX, trainables: ["logVariance", "logLengthscale", "X"])
//        let gp = GaussianProcessRegressor<RBF>(kernel: kern, alpha: 0.8)
//        gp.fit(X, Y, maxiters: 1000)
        
        let gp = GPLVM(kernel: kern, alpha: 8.2)
        gp.fit(initX, Y)
        
        let Xpred = gp.kernel.X
        
        let (maxX, maxY) = tuple(max(Xpred, axis: 0).grid)
        let (minX, minY) = tuple(min(Xpred, axis: 0).grid)
        
        let Xs: Matrix<Float> = linspace(minX, maxX, 20)
        let Ys: Matrix<Float> = linspace(minY, maxY, 20)
        
        let XStar = vstack([Xs, Ys]).t
//        let (means, covs) = gp.predict(XStar[0])
        
        var ys = Y[[0], forall]
        ys[0, 1] = Float.nan
        ys[0, 3] = Float.nan
        
//        let xs = gp.predictX(ys, true)
        let xs = gp.kernel.X[0]
        let pys = gp.predict(xs)
        
        print(pys, Y[0])
        print(gp.kernel.variance, gp.kernel.lengthscale)
//        print(gp.kernel.X[column: 0])
//        print(gp.kernel.X[column: 1])
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
