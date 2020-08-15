<p align="center">
   <img width="200" src="https://raw.githubusercontent.com/SvenTiigi/SwiftKit/gh-pages/readMeAssets/SwiftKitLogo.png" alt="Minimind2 Logo">
</p>

<p align="center">
   <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
   </a>
   <a href="http://cocoapods.org/pods/Minimind2">
      <img src="https://img.shields.io/cocoapods/v/Minimind2.svg?style=flat" alt="Version">
   </a>
   <a href="http://cocoapods.org/pods/Minimind2">
      <img src="https://img.shields.io/cocoapods/p/Minimind2.svg?style=flat" alt="Platform">
   </a>
   <a href="https://github.com/Carthage/Carthage">
      <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage Compatible">
   </a>
   <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">
   </a>
</p>

# Minimind2

# ![minimind](https://github.com/fqhuy/minimind/blob/master/doc/images/minimind128.png) minimind: A Minimalist Machine Learning Library written in Swift

The main focus of this library is **dimensionality reduction**, **manifold learning** and **multi-output regression**. Minimind allows fast mobile app prototyping by providing a friendly numpy-like interface and native performance on iOS and MacOS. See playground files for examples. Some wrapper functions for Accelerate were borrowed from [Surge](https://github.com/mattt/Surge).

## Learning A Predictive Distribution
![Predictive](https://github.com/fqhuy/minimind/blob/master/doc/images/regression.png)

```swift
        let X = Matrix<Float>([[-1.50983293], [-1.11726642], [-0.89303372], [ 0.07971517], [ 0.29116607], [ 0.7494249 ], [ 0.93321463], [ 1.46661229]])
        
        let Y = Matrix<Float>([[ 0.04964821,  0.0866106,  0.16055375,  0.58936555,  0.71558366,  1.00004714,  1.08412273,  1.42418915]]).t
        
        // start with large variance and lengthscale
        let kern = RBF(variance: 300.0, lengthscale: 1000.0)
        
        let gp = GaussianProcessRegressor<Float, RBF>(kernel: kern, alpha: 1.0)
        gp.fit(X, Y, maxiters: 500)
        
        print(gp.kernel.get_params())
        
        let Xstar = Matrix<Float>(-1, 1, arange(-1.5, 1.5, 0.1))
        let (Mu, Sigma) = gp.predict(Xstar)

        // plot variance 
        _ = graph.plot(x: Xstar.grid.cgFloat, y: (Mu + diag(Sigma)).grid.cgFloat , c: UIColor.blue, s: 1.0)
        _ = graph.plot(x: Xstar.grid.cgFloat, y: (Mu - diag(Sigma)).grid.cgFloat, c: UIColor.blue, s: 1.0)
        
        // plot mean
        _ = graph.plot(x: Xstar.grid.cgFloat, y: Mu.grid.cgFloat, c: UIColor.red, s: 3.0)

        // plot training data
        _ = graph.scatter(x: X.grid.cgFloat, y: Y.grid.cgFloat, c: UIColor.green, s: 10.0)
        
        graph.autoscale()
```
## Matrix Operations, side-by-side with numpy
```swift
import Foundation
import Surge
import minimind

// random matrix
let m: Matrix<Float> = randMatrix(3, 3)
let a = Matrix<Float>([[1.2, 0.2, 0.3],
                       [0.5, 1.5, 0.2],
                       [0.1, 0.2, 2.0]])

let subM = m[0∷2, 0∷2] // matrix slicing
let cmean = m.mean(0) // mean accross columns
let b = (m * a + a) ∘ m.t // linear math
let (u, s, v) = svd(a) // Singular values & vectors
let l = cholesky(a, "L") // Cholesky & LDLT
let (evals, evecs) = eigh(a, "L") // Eigen decom.
```
```python
import numpy as np

# random matrix
m = np.random.rand(3, 3)
a = np.array([[1.2, 0.2, 0.3],
              [0.5, 1.5, 0.2],
              [0.1, 0.2, 2.0]])
              
subM = m[0::2, 0::2]
cmean = m.mean(0)

b = (m.dot(a) + a) * m.T

u, s, v = np.linalg.svd(a)
l = np.linalg.cholesky(a)
evals, evecs = np.linalg.eigh(a)
```

## Sampling from a GP prior

![Sampling](https://github.com/fqhuy/minimind/blob/master/doc/images/sampling.png)

## Internal Design Philosophy
To maximise code reusability, Swift extensions are used extensively. For instance, Matrix is generically defined as ```Matrix<T>```, with no constraints on T. This basically means that Matrix can contain any data types like Float, Double, Int, Bool and even String. ```Matrix<T>``` can be specialised to deal with a certain group of data such as ScalarType (Similar to Swift Numeric type, which will comes with XCode 9). Accelerations are used whenever possible by further specialising Matrix (e.g to ```Matrix<Float>```, ```Matrix<Double>```).


## Example

The example application is the best way to see `Minimind2` in action. Simply open the `Minimind2.xcodeproj` and run the `Example` scheme.

## Installation

### CocoaPods

Minimind2 is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```bash
pod 'Minimind2'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

To integrate Minimind2 into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "HuyPhan/Minimind2"
```

Run `carthage update` to build the framework and drag the built `Minimind2.framework` into your Xcode project. 

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase” and add the Framework path as mentioned in [Carthage Getting started Step 4, 5 and 6](https://github.com/Carthage/Carthage/blob/master/README.md#if-youre-building-for-ios-tvos-or-watchos)

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/HuyPhan/Minimind2.git", from: "1.0.0")
]
```

Alternatively navigate to your Xcode project, select `Swift Packages` and click the `+` icon to search for `Minimind2`.

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate Minimind2 into your project manually. Simply drag the `Sources` Folder into your Xcode project.

## Usage

ℹ️ Describe the usage of your Kit

## Contributing
Contributions are very welcome 🙌

## License

```
Minimind2
Copyright (c) 2020 Zeta Motion LTD phan@zetamotion.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
