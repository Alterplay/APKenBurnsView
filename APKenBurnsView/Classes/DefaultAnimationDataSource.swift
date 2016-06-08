//
// Created by Nickolay Sheika on 6/8/16.
//

import Foundation


class DefaultAnimationDataSource: AnimationDataSource {
    let animationDependencies: ImageAnimationDependencies


    init(animationDependencies: ImageAnimationDependencies) {
        self.animationDependencies = animationDependencies
    }


    private func imageScaleForAspectFill(image: UIImage, bounds: CGRect) -> CGFloat {
        let heightScale = bounds.height / image.size.height
        let widthScale = bounds.width / image.size.width
        let scaleForAspectFill = max(heightScale, widthScale)
        return scaleForAspectFill
    }

    func buildAnimationForImage(image: UIImage, forAnimationRect animationRect: CGRect) -> ImageAnimation? {
        let scaleFactorDeviation = animationDependencies.scaleFactorDeviation
        let imageAnimationDuration = animationDependencies.imageAnimationDuration
        let imageAnimationDurationDeviation = animationDependencies.imageAnimationDurationDeviation

        let scaleForAspectFill = imageScaleForAspectFill(image, bounds: animationRect)

        let startScaleDeviation = CGFloat.random(max: CGFloat(scaleFactorDeviation))
        let endScaleDeviation = CGFloat.random(max: CGFloat(scaleFactorDeviation))

        let startScale = scaleForAspectFill + startScaleDeviation
        let endScale = scaleForAspectFill + endScaleDeviation

        let imageStartSize = CGSizeMake(image.size.width * startScale, image.size.height * startScale)
        let imageEndSize = CGSizeMake(image.size.width * endScale, image.size.height * endScale)

        let imageStartXDeviation = (imageStartSize.width / 2 - animationRect.size.width / 2)
        let imageStartYDeviation = (imageStartSize.height / 2 - animationRect.size.height / 2)
        let imageEndXDeviation = (imageEndSize.width / 2 - animationRect.size.width / 2)
        let imageEndYDeviation = (imageEndSize.height / 2 - animationRect.size.height / 2)

        let imageStartPositionX = CGFloat.random(min: -imageStartXDeviation, max: imageStartXDeviation)
        let imageStartPositionY = CGFloat.random(min: -imageStartYDeviation, max: imageStartYDeviation)
        let imageStartPosition = CGPointMake(imageStartPositionX, imageStartPositionY)

        var imageEndPositionX: CGFloat = 0.0
        if imageStartPositionX < 0 {
            imageEndPositionX = CGFloat.random(min: 0.0, max: imageEndXDeviation)
        } else {
            imageEndPositionX = CGFloat.random(min: -imageEndXDeviation, max: 0.0)
        }

        var imageEndPositionY: CGFloat = 0.0
        if imageStartPositionY < 0 {
            imageEndPositionY = CGFloat.random(min: 0.0, max: imageEndYDeviation)
        } else {
            imageEndPositionY = CGFloat.random(min: -imageEndYDeviation, max: 0.0)
        }
        let imageEndPosition = CGPointMake(imageEndPositionX, imageEndPositionY)


        var durationDeviation = 0.0
        if (imageAnimationDurationDeviation > 0.0) {
            durationDeviation = Double.random(min: -imageAnimationDurationDeviation, max: imageAnimationDurationDeviation)
        }
        let duration = imageAnimationDuration + durationDeviation

        let imageStartState = ImageState(scale: startScale, position: imageStartPosition)
        let imageEndState = ImageState(scale: endScale, position: imageEndPosition)
        let imageTransition = ImageAnimation(startState: imageStartState, endState: imageEndState, duration: duration)

        return imageTransition
    }
}