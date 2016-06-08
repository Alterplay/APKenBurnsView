//
// Created by Nickolay Sheika on 6/8/16.
//

import Foundation


internal protocol AnimationDataSource {
    var animationDependencies: ImageAnimationDependencies { get }

    func buildAnimationForImage(image: UIImage, forAnimationRect animationRect: CGRect) -> ImageAnimation?  // TODO
}