//
// Created by Nickolay Sheika on 6/10/16.
//

import Foundation


protocol RandomGeneratorProtocol {

    func randomBool() -> Bool
    func randomCGFloat(min: CGFloat, max: CGFloat) -> CGFloat
    func randomFloat(min: Float, max: Float) -> Float
    func randomDouble(min: Double, max: Double) -> Double
    func randomInt(min: Int, max: Int) -> Int
}


class RandomGenerator: RandomGeneratorProtocol {

    // MARK: - Public

    func randomBool() -> Bool {
        return Bool.random()
    }

    func randomCGFloat(min: CGFloat = 0.0, max: CGFloat) -> CGFloat {
        return CGFloat.random(min: min, max: max)
    }

    func randomFloat(min: Float = 0.0, max: Float) -> Float {
        return Float.random(min: min, max: max)
    }

    func randomDouble(min: Double = 0.0, max: Double) -> Double {
        return Double.random(min: min, max: max)
    }

    func randomInt(min: Int  = 0, max: Int) -> Int {
        return Int.random(min: min, max: max)
    }
}
