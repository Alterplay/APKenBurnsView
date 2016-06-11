//
// Created by Nickolay Sheika on 6/10/16.
//

import Foundation


protocol ImageAnimationCalculatorProtocol {
    func buildPinnedToEdgesPosition(imageSize imageSize: CGSize, viewPortSize: CGSize) -> CGPoint
    func buildOppositeAnglePosition(startPosition startPosition: CGPoint, imageSize: CGSize, viewPortSize: CGSize) -> CGPoint
    func buildAnimationDuration() -> Double
    func buildRandomScale(imageSize imageSize: CGSize, viewPortSize: CGSize) -> CGFloat
}



class ImageAnimationCalculator: ImageAnimationCalculatorProtocol {

    // MARK: - Variables

    private let randomGenerator: RandomGeneratorProtocol
    private let animationDependencies: ImageAnimationDependencies

    // MARK: - Init

    init(randomGenerator: RandomGeneratorProtocol = RandomGenerator(), animationDependencies: ImageAnimationDependencies) {
        self.randomGenerator = randomGenerator
        self.animationDependencies = animationDependencies
    }

    // MARK: - Public

    func buildPinnedToEdgesPosition(imageSize imageSize: CGSize, viewPortSize: CGSize) -> CGPoint {
        let imageXDeviation = imageSize.width / 2 - viewPortSize.width / 2
        let imageYDeviation = imageSize.height / 2 - viewPortSize.height / 2

        let isXPinned = randomGenerator.randomBool()

        var imagePositionX: CGFloat = 0.0
        var imagePositionY: CGFloat = 0.0
        if isXPinned {
            imagePositionX = randomGenerator.randomBool() ? -imageXDeviation : imageXDeviation
            imagePositionY = randomGenerator.randomCGFloat(min: -imageYDeviation, max: imageYDeviation)
        } else {
            imagePositionX = randomGenerator.randomCGFloat(min: -imageXDeviation, max: imageXDeviation)
            imagePositionY = randomGenerator.randomBool() ? -imageYDeviation : imageYDeviation
        }

        let imagePosition = CGPointMake(imagePositionX, imagePositionY)
        return imagePosition
    }

    func buildOppositeAnglePosition(startPosition startPosition: CGPoint, imageSize: CGSize, viewPortSize: CGSize) -> CGPoint {
        let imageXDeviation = imageSize.width / 2 - viewPortSize.width / 2
        let imageYDeviation = imageSize.height / 2 - viewPortSize.height / 2

        var imagePositionX: CGFloat = 0.0
        if startPosition.x < 0 {
            imagePositionX = randomGenerator.randomCGFloat(min: 0.0, max: imageXDeviation)
        } else {
            imagePositionX = randomGenerator.randomCGFloat(min: -imageXDeviation, max: 0.0)
        }

        var imagePositionY: CGFloat = 0.0
        if startPosition.y < 0 {
            imagePositionY = randomGenerator.randomCGFloat(min: 0.0, max: imageYDeviation)
        } else {
            imagePositionY = randomGenerator.randomCGFloat(min: -imageYDeviation, max: 0.0)
        }

        let imageEndPosition = CGPointMake(imagePositionX, imagePositionY)

        return imageEndPosition
    }

    func buildAnimationDuration() -> Double {
        let imageAnimationDuration = animationDependencies.imageAnimationDuration
        let imageAnimationDurationDeviation = animationDependencies.imageAnimationDurationDeviation

        var durationDeviation = 0.0
        if imageAnimationDurationDeviation > 0.0 {
            durationDeviation = randomGenerator.randomDouble(min: -imageAnimationDurationDeviation,
                                                             max: imageAnimationDurationDeviation)
        }
        let duration = imageAnimationDuration + durationDeviation
        return duration
    }

    func buildRandomScale(imageSize imageSize: CGSize, viewPortSize: CGSize) -> CGFloat {
        let scaleFactorDeviation = animationDependencies.scaleFactorDeviation
        let scaleForAspectFill = imageScaleForAspectFill(imageSize: imageSize, viewPortSize: viewPortSize)
        let scaleDeviation = randomGenerator.randomCGFloat(min: 0.0, max: CGFloat(scaleFactorDeviation))
        let scale = scaleForAspectFill + scaleDeviation
        return scale
    }

    // MARK: - Private

    private func imageScaleForAspectFill(imageSize imageSize: CGSize, viewPortSize: CGSize) -> CGFloat {
        let widthScale = viewPortSize.width / imageSize.width
        let heightScale = viewPortSize.height / imageSize.height
        let scaleForAspectFill = max(heightScale, widthScale)
        return scaleForAspectFill
    }
}
