//
// Created by Nickolay Sheika on 6/8/16.
//

import Foundation
import CoreGraphics

extension Int {
    /**
     Returns random Int between 0 and max-1
     */
    static func random(max max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }

    /**
     Returns random integer between min and max
     */
    static func random(min min: Int = 0, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max - min + 1))) + min
    }
}

extension Double {
    /**
     Returns random Double
     */
    static func random(min min: Double = 0.0, max: Double) -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
}

extension Float {
    /**
     Returns random Float
     */
    static func random(min min: Float = 0.0, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
}

extension CGFloat {
    /**
     Returns random CGFloat
     */
    static func random(min min: CGFloat = 0.0, max: CGFloat) -> CGFloat {
        return CGFloat(Double.random(min: Double(min), max: Double(max)))
    }
}

