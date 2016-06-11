//
// Created by Nickolay Sheika on 6/8/16.
//

import Foundation
import UIKit
import QuartzCore

class BiggestFaceAnimationDataSource: AnimationDataSource {

    // MARK: - Variables

    let animationCalculator: ImageAnimationCalculatorProtocol
    let backupAnimationDataSource: AnimationDataSource
    // will be used for animation if no faces found

    // MARK: - Init

    init(animationCalculator: ImageAnimationCalculatorProtocol, backupAnimationDataSource: AnimationDataSource) {
        self.animationCalculator = animationCalculator
        self.backupAnimationDataSource = backupAnimationDataSource
    }

    convenience init(animationDependencies: ImageAnimationDependencies, backupAnimationDataSource: AnimationDataSource) {
        self.init(animationCalculator: ImageAnimationCalculator(animationDependencies: animationDependencies),
                  backupAnimationDataSource: backupAnimationDataSource)
    }

    // MARK: - Public

    func buildAnimationForImage(image: UIImage, forViewPortSize viewPortSize: CGSize) -> ImageAnimation? {
        guard let biggestFaceRect = image.biggestFaceRect() else {
            return backupAnimationDataSource.buildAnimationForImage(image, forViewPortSize: viewPortSize)
        }

        let imageSize = image.size

        let startScale: CGFloat = animationCalculator.buildRandomScale(imageSize: imageSize, viewPortSize: viewPortSize)
        let endScale: CGFloat = animationCalculator.buildRandomScale(imageSize: imageSize, viewPortSize: viewPortSize)



        let scaledImageSize = image.size.scaledSize(startScale)

        let imageCenter = CGPointMake(viewPortSize.width / 2, viewPortSize.height / 2)
        let imageFrameScaled = CGRect(center: imageCenter, size: scaledImageSize)

        let faceRectScaled = CGRectApplyAffineTransform(biggestFaceRect, CGAffineTransformMakeScale(startScale, startScale))

        let faceRectConvertedX: CGFloat = imageFrameScaled.origin.x + faceRectScaled.origin.x
        let faceRectConvertedY: CGFloat = imageFrameScaled.origin.y + faceRectScaled.origin.y
        let faceRectConverted = CGRectIntegral(CGRectMake(faceRectConvertedX,
                                                          faceRectConvertedY,
                                                          faceRectScaled.size.width,
                                                          faceRectScaled.size.height))



        let startFromFace = true //Bool.random()
        var imageStartPosition: CGPoint = CGPointZero
        if startFromFace {
            let centerOfFaceRect = faceRectConverted.center()
            imageStartPosition = CGPointMake(-(centerOfFaceRect.x - viewPortSize.width / 2),
                                             -(centerOfFaceRect.y - viewPortSize.height / 2))
        } else {
            imageStartPosition = animationCalculator.buildPinnedToEdgesPosition(imageSize: scaledImageSize,
                                                                                viewPortSize: viewPortSize)
        }

//        let imageEndPosition = imageStartPosition
        let imageEndPosition = animationCalculator.buildOppositeAnglePosition(startPosition: imageStartPosition,
                                                                              imageSize: scaledImageSize,
                                                                              viewPortSize: viewPortSize)

        let duration = animationCalculator.buildAnimationDuration()

        let imageStartState = ImageState(scale: startScale, position: imageStartPosition)
        let imageEndState = ImageState(scale: endScale, position: imageEndPosition)
        let imageTransition = ImageAnimation(startState: imageStartState, endState: imageEndState, duration: duration)

        return imageTransition
    }

    // MARK: - Private

    private func translateToImageCoordinates(point point: CGPoint, imageSize: CGSize, viewPortSize: CGSize) -> CGPoint {
        let x = imageSize.width / 2 - viewPortSize.width / 2 - point.x
        let y = imageSize.height / 2 - viewPortSize.height / 2 - point.y
        let position = CGPointMake(x, y)
        return position
    }

}


extension CGRect {
    func scaledRect(scale: CGFloat) -> CGRect {
        return CGRectMake(origin.x * scale, origin.y * scale, width * scale, height * scale)
    }

    func center() -> CGPoint {
        return CGPointMake(origin.x + (size.width / 2), origin.y + (size.height / 2))
    }

    init(center: CGPoint, size: CGSize) {
        self = CGRectMake(center.x - (size.width / 2), center.y - (size.height / 2), size.width, size.height)
    }
}

