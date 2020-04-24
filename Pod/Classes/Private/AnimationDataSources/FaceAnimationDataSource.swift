//
// Created by Nickolay Sheika on 6/8/16.
//

import Foundation
import UIKit
import QuartzCore

enum FaceRecognitionMode {
    case Biggest
    case Group

    init(mode: APKenBurnsViewFaceRecognitionMode) {
        switch mode {
            case .None:
                fatalError("Unsupported mode!")
            case .Biggest:
                self = .Biggest
            case .Group:
                self = .Group
        }
    }
}


class FaceAnimationDataSource: AnimationDataSource {

    // MARK: - Variables

    let animationCalculator: ImageAnimationCalculatorProtocol

    // will be used for animation if no faces found
    let backupAnimationDataSource: AnimationDataSource

    let faceRecognitionMode: FaceRecognitionMode

    // MARK: - Init

    init(faceRecognitionMode: FaceRecognitionMode,
            animationCalculator: ImageAnimationCalculatorProtocol,
            backupAnimationDataSource: AnimationDataSource) {
        self.faceRecognitionMode = faceRecognitionMode
        self.animationCalculator = animationCalculator
        self.backupAnimationDataSource = backupAnimationDataSource
    }

    convenience init(faceRecognitionMode: FaceRecognitionMode,
            animationDependencies: ImageAnimationDependencies,
            backupAnimationDataSource: AnimationDataSource) {
        self.init(faceRecognitionMode: faceRecognitionMode,
                  animationCalculator: ImageAnimationCalculator(animationDependencies: animationDependencies),
                  backupAnimationDataSource: backupAnimationDataSource)
    }

    // MARK: - Public

    func buildAnimationForImage(image: UIImage, forViewPortSize viewPortSize: CGSize) -> ImageAnimation {
        guard let faceRect = findFaceRect(image: image) else {
            return backupAnimationDataSource.buildAnimationForImage(image: image, forViewPortSize: viewPortSize)
        }

        let imageSize = image.size

        let startScale: CGFloat = animationCalculator.buildRandomScale(imageSize: imageSize, viewPortSize: viewPortSize)
        let endScale: CGFloat = animationCalculator.buildRandomScale(imageSize: imageSize, viewPortSize: viewPortSize)

        let scaledStartImageSize = imageSize.scaledSize(scale: startScale)
        let scaledEndImageSize = imageSize.scaledSize(scale: endScale)

        let startFromFace = Bool.random()

        var imageStartPosition: CGPoint = CGPoint.zero
        if startFromFace {

            let faceRectScaled = faceRect.applying(CGAffineTransform(scaleX: startScale, y: startScale))
            imageStartPosition = animationCalculator.buildFacePosition(faceRect: faceRectScaled,
                                                                       imageSize: scaledStartImageSize,
                                                                       viewPortSize: viewPortSize)
        } else {
            imageStartPosition = animationCalculator.buildPinnedToEdgesPosition(imageSize: scaledStartImageSize,
                                                                                viewPortSize: viewPortSize)
        }


        var imageEndPosition: CGPoint = CGPoint.zero
        if !startFromFace {
            let faceRectScaled = faceRect.applying(CGAffineTransform(scaleX: endScale, y: endScale))
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

    // MARK: - Private

    private func findFaceRect(image: UIImage) -> CGRect? {
        switch faceRecognitionMode {
            case .Group:
                return image.groupFacesRect()
            case .Biggest:
                return image.biggestFaceRect()
        }
    }
}
