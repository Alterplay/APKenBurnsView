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

    func buildAnimationForImage(image: UIImage, forViewPortSize viewPortSize: CGSize) -> ImageAnimation {
        guard let biggestFaceRect = image.biggestFaceRect() else {
            return backupAnimationDataSource.buildAnimationForImage(image, forViewPortSize: viewPortSize)
        }

        let imageSize = image.size

        let startScale: CGFloat = animationCalculator.buildRandomScale(imageSize: imageSize, viewPortSize: viewPortSize)
        let endScale: CGFloat = animationCalculator.buildRandomScale(imageSize: imageSize, viewPortSize: viewPortSize)

        let scaledStartImageSize = imageSize.scaledSize(startScale)
        let scaledEndImageSize = imageSize.scaledSize(endScale)

        let startFromFace = Bool.random()

        var imageStartPosition: CGPoint = CGPointZero
        if startFromFace {
            let faceRectScaled = CGRectApplyAffineTransform(biggestFaceRect, CGAffineTransformMakeScale(startScale, startScale))
            imageStartPosition = animationCalculator.buildFacePosition(faceRect: faceRectScaled,
                                                                       imageSize: scaledStartImageSize,
                                                                       viewPortSize: viewPortSize)
        } else {
            imageStartPosition = animationCalculator.buildPinnedToEdgesPosition(imageSize: scaledStartImageSize,
                                                                                viewPortSize: viewPortSize)
        }


        var imageEndPosition: CGPoint = CGPointZero
        if !startFromFace {
            let faceRectScaled = CGRectApplyAffineTransform(biggestFaceRect, CGAffineTransformMakeScale(endScale, endScale))
            imageEndPosition = animationCalculator.buildFacePosition(faceRect: faceRectScaled,
                                                                     imageSize: scaledEndImageSize,
                                                                     viewPortSize: viewPortSize)
        } else {
            imageEndPosition = animationCalculator.buildOppositeAnglePosition(startPosition: imageStartPosition,
                                                                              imageSize: scaledEndImageSize,
                                                                              viewPortSize: viewPortSize)
        }

        let duration = animationCalculator.buildAnimationDuration()

        let imageStartState = ImageState(scale: startScale, position: imageStartPosition)
        let imageEndState = ImageState(scale: endScale, position: imageEndPosition)
        let imageTransition = ImageAnimation(startState: imageStartState, endState: imageEndState, duration: duration)

        return imageTransition
    }
}