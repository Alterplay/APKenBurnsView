//
// Created by Nickolay Sheika on 6/8/16.
//

import Foundation
import UIKit


class DefaultAnimationDataSource: AnimationDataSource {

    // MARK: - Variables

    let animationCalculator: ImageAnimationCalculatorProtocol

    // MARK: - Init

    init(animationCalculator: ImageAnimationCalculatorProtocol) {
        self.animationCalculator = animationCalculator
    }

    convenience init(animationDependencies: ImageAnimationDependencies) {
        self.init(animationCalculator: ImageAnimationCalculator(animationDependencies: animationDependencies))
    }

    // MARK: - Public

    func buildAnimationForImage(image: UIImage, forViewPortSize viewPortSize: CGSize) -> ImageAnimation {
        let imageSize = image.size

        let startScale = animationCalculator.buildRandomScale(imageSize: imageSize, viewPortSize: viewPortSize)
        let endScale = animationCalculator.buildRandomScale(imageSize: imageSize, viewPortSize: viewPortSize)

        let scaledStartImageSize = imageSize.scaledSize(scale: startScale)
        let scaledEndImageSize = imageSize.scaledSize(scale: endScale)

        let imageStartPosition = animationCalculator.buildPinnedToEdgesPosition(imageSize: scaledStartImageSize,
                                                                                viewPortSize: viewPortSize)
        let imageEndPosition = animationCalculator.buildOppositeAnglePosition(startPosition: imageStartPosition,
                                                                              imageSize: scaledEndImageSize,
                                                                              viewPortSize: viewPortSize)

        let duration = animationCalculator.buildAnimationDuration()

        let imageStartState = ImageState(scale: startScale, position: imageStartPosition)
        let imageEndState = ImageState(scale: endScale, position: imageEndPosition)
        let imageTransition = ImageAnimation(startState: imageStartState, endState: imageEndState, duration: duration)

        return imageTransition
    }

    // MARK: - Private

    private func translateToImageCoordinates(point: CGPoint, imageSize: CGSize, viewPortSize: CGSize) -> CGPoint {
        let x = imageSize.width / 2 - viewPortSize.width / 2 - point.x
        let y = imageSize.height / 2 - viewPortSize.height / 2 - point.y
        let position = CGPoint(x: x, y: y)
        return position
    }
}
