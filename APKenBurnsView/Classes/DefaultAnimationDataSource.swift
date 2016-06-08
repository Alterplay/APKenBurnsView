//
// Created by Nickolay Sheika on 6/8/16.
//

import Foundation
import UIKit


class DefaultAnimationDataSource: AnimationDataSource {

    // MARK: - Variables

    let animationDependencies: ImageAnimationDependencies

    // MARK: - Init

    init(animationDependencies: ImageAnimationDependencies) {
        self.animationDependencies = animationDependencies
    }

    // MARK: - Public

    func buildAnimationForImage(image: UIImage, forAnimationRect animationRect: CGRect) -> ImageAnimation? {
        let imageSize = image.size

        let startScale = buildRandomScale(imageSize: imageSize, forAnimationRect: animationRect)
        let endScale = buildRandomScale(imageSize: imageSize, forAnimationRect: animationRect)

        let imageStartPosition = buildImageStartPosition(imageSize: imageSize,
                                                         forAnimationRect: animationRect,
                                                         scale: startScale)
        let imageEndPosition = buildImageEndPosition(startPosition: imageStartPosition,
                                                     imageSize: imageSize,
                                                     forAnimationRect: animationRect,
                                                     scale: endScale)

        let duration = buildAnimationDuration()

        let imageStartState = ImageState(scale: startScale, position: imageStartPosition)
        let imageEndState = ImageState(scale: endScale, position: imageEndPosition)
        let imageTransition = ImageAnimation(startState: imageStartState, endState: imageEndState, duration: duration)

        return imageTransition
    }

    // MARK: - Private

    private func buildAnimationDuration() -> Double {
        let imageAnimationDuration = animationDependencies.imageAnimationDuration
        let imageAnimationDurationDeviation = animationDependencies.imageAnimationDurationDeviation

        var durationDeviation = 0.0
        if (imageAnimationDurationDeviation > 0.0) {
            durationDeviation = Double.random(min: -imageAnimationDurationDeviation, max: imageAnimationDurationDeviation)
        }
        let duration = imageAnimationDuration + durationDeviation
        return duration
    }

    private func buildRandomScale(imageSize imageSize: CGSize, forAnimationRect animationRect: CGRect) -> CGFloat {
        let scaleFactorDeviation = animationDependencies.scaleFactorDeviation
        let scaleForAspectFill = imageScaleForAspectFill(imageSize: imageSize, bounds: animationRect)
        let scaleDeviation = CGFloat.random(max: CGFloat(scaleFactorDeviation))
        let scale = scaleForAspectFill + scaleDeviation
        return scale
    }

    private func buildImageStartPosition(imageSize imageSize: CGSize, forAnimationRect animationRect: CGRect, scale: CGFloat) -> CGPoint {
        let imageStartSize = imageSize.scaledSize(scale)

        let imageStartXDeviation = imageStartSize.width / 2 - animationRect.size.width / 2
        let imageStartYDeviation = imageStartSize.height / 2 - animationRect.size.height / 2

        let imageStartPositionX = CGFloat.random(min: -imageStartXDeviation, max: imageStartXDeviation)
        let imageStartPositionY = CGFloat.random(min: -imageStartYDeviation, max: imageStartYDeviation)
        let imageStartPosition = CGPointMake(imageStartPositionX, imageStartPositionY)

        return imageStartPosition
    }

    private func buildImageEndPosition(startPosition startPosition: CGPoint, imageSize: CGSize, forAnimationRect animationRect: CGRect, scale: CGFloat) -> CGPoint {
        let imageEndSize = imageSize.scaledSize(scale)

        let imageEndXDeviation = imageEndSize.width / 2 - animationRect.size.width / 2
        let imageEndYDeviation = imageEndSize.height / 2 - animationRect.size.height / 2

        var imageEndPositionX: CGFloat = 0.0
        if startPosition.x < 0 {
            imageEndPositionX = CGFloat.random(min: 0.0, max: imageEndXDeviation)
        } else {
            imageEndPositionX = CGFloat.random(min: -imageEndXDeviation, max: 0.0)
        }

        var imageEndPositionY: CGFloat = 0.0
        if startPosition.y < 0 {
            imageEndPositionY = CGFloat.random(min: 0.0, max: imageEndYDeviation)
        } else {
            imageEndPositionY = CGFloat.random(min: -imageEndYDeviation, max: 0.0)
        }

        let imageEndPosition = CGPointMake(imageEndPositionX, imageEndPositionY)

        return imageEndPosition
    }

    private func imageScaleForAspectFill(imageSize imageSize: CGSize, bounds: CGRect) -> CGFloat {
        let heightScale = bounds.height / imageSize.height
        let widthScale = bounds.width / imageSize.width
        let scaleForAspectFill = max(heightScale, widthScale)
        return scaleForAspectFill
    }
}


extension CGSize {
    func scaledSize(scale: CGFloat) -> CGSize {
        return CGSizeMake(self.width * scale, self.height * scale)
    }
}