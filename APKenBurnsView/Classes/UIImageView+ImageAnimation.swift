//
// Created by Nickolay Sheika on 6/11/16.
//

import Foundation
import UIKit
import CoreFoundation

extension UIImageView {

    // MARK: - Public

    func animateWithImageAnimation(animation: ImageAnimation, completion: (() -> ())? = nil) {
        let imageStartTransform = transformForImageState(animation.startState)
        let imageEndTransform = transformForImageState(animation.endState)

        UIView.animateKeyframesWithDuration(animation.duration, delay: 0.0, options: .CalculationModeCubic, animations: {
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0) {
                self.transform = imageStartTransform
            }
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1.0) {
                self.transform = imageEndTransform
            }
        }, completion: {
            finished in

            completion?()
        })
    }

    // MARK: - Helpers

    private func transformForImageState(imageState: ImageState) -> CGAffineTransform {
        let scaleTransform = CGAffineTransformMakeScale(imageState.scale, imageState.scale)
        let translationTransform = CGAffineTransformMakeTranslation(imageState.position.x, imageState.position.y)
        let transform = CGAffineTransformConcat(scaleTransform, translationTransform)
        return transform
    }
}