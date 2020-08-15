//
//  arrayTests.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/15/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import XCTest
@testable import Minimind2

class arrayTests: XCTestCase {
    var a: [Float] = [0.0, 1.0, 2.0, 3.0]
    var b: [Float] = [4.0, 3.0, 2.0, 1.0]

    var da: [Double] = [0.0, 1.0, 2.0, 3.0]
    var db: [Double] = [4.0, 3.0, 2.0, 1.0]
    
    var ba: [Int] = [0, 1, 2, 3]
    var bb: [Int] = [4, 3, 2, 1]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testArrangeFloat() {
        let v: [Float] = arange(-2.0, 2.1, 2.0 / 3.0)
        XCTAssertEqual(v, [-2.0, -1.3333333, -0.6666666, 0.0, 0.66666675, 1.3333335, 2.000])
    }
    
    func testArrangeDouble() {
        let v: [Double] = arange(-2.0, 2.1, 2.0 / 3.0)
        XCTAssertTrue(allclose(v, [-2.0, -1.3333333, -0.6666666, 0.0, 0.66666675, 1.3333335, 2.000], atol: 0.001, rtol: 1.0))
    }
    
    func testAddFloat() {
        let c: [Float] = Minimind2.add(a, y: b)
        XCTAssertTrue(all(c == [4.0, 4.0, 4.0, 4.0]))
    }
    
    func testAddDouble() {
        let c: [Double] = Minimind2.add(da, y: db)
        XCTAssertTrue(all(c == [4.0, 4.0, 4.0, 4.0]))
    }
    
    func testAddInt() {
        let c: [Int] = Minimind2.add(ba, y: bb)
        XCTAssertTrue(all(c == [4, 4, 4, 4]))
    }
    
    func testComparisonInt() {
        let x: [Int] = [1,3,4,5]
        let y: [Int] = [1,3,4,4]
        
        XCTAssertEqual(x == y, [true, true, true, false])
    }

    func testAddInt8() {
        let ia: [Int8] = [0, 1, 2, 3]
        let ib: [Int8] = [4, 3, 2, 1]
        
        let c: [Int8] = Minimind2.add(ia, y: ib)
        XCTAssertTrue(all(c == [4, 4, 4, 4]))
    }
    
    func testMath() {
        XCTAssert(all(a.cumsum() == [0.0, 1.0, 3.0, 6.0]))
        XCTAssert(a.sum() == 6.0)
        XCTAssert(a.max() == 3.0)
        XCTAssert(a.min() == 0.0)
    }
    
    func testAlgorithms() {
        let b = [5, 3, 1 , 2, 10, 11, 9]
        let (sortedB, ids) = quicksort(b)
//        print(sortedB, ids)
        XCTAssertFalse(all([true, false, true]))
        XCTAssert(all([true, true, true]))
        XCTAssert(all(sortedB == b.sorted()))
        XCTAssert(all(ids == [2, 3, 1, 0, 6, 4, 5]))
        XCTAssert(argmax(b) == 5)
        XCTAssert(argmin(b) == 2)
        XCTAssert(max(b) == 11)
        XCTAssert(min(b) == 1)
    }

    func testPerformanceAddInt() {
        // This is an example of a performance test case.
        let x: [Int] = arange(0, 11, 1)
        let y: [Int] = arange(300, 300 + 11, 1)
        

        self.measure {
            // Put the code you want to measure the time of here.
            Minimind2.add(x, y: y)
        }

    }
    
    func testPerformanceAddFloat() {
        let fx: [Float] = arange(0.0, 11.0, 1.0)
        let fy: [Float] = arange(300.0, 300 + 11.0, 1.0)

        self.measure {
            // Put the code you want to measure the time of here.
            Minimind2.add(fx, y: fy)
        }
    }

}
