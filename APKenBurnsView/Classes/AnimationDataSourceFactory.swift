//
// Created by Nickolay Sheika on 6/8/16.
//

import Foundation


protocol AnimationDataSourceFactoryProtocol {
    var faceRecognitionMode: APKenBurnsViewFaceRecognitionMode { get }
    var animationDependencies: ImageAnimationDependencies { get }

    func buildAnimationDataSource() -> AnimationDataSource
}

class AnimationDataSourceFactory: AnimationDataSourceFactoryProtocol {

    // MARK: - Public Variables

    let animationDependencies: ImageAnimationDependencies
    let faceRecognitionMode: APKenBurnsViewFaceRecognitionMode

    // MARK: - Init

    init(animationDependencies: ImageAnimationDependencies, faceRecognitionMode: APKenBurnsViewFaceRecognitionMode) {
        self.animationDependencies = animationDependencies
        self.faceRecognitionMode = faceRecognitionMode
    }

    // MARK: - Public

    func buildAnimationDataSource() -> AnimationDataSource {
        if faceRecognitionMode == .None {
            return DefaultAnimationDataSource(animationDependencies: animationDependencies)
        } else {
            let mode = FaceRecognitionMode(mode: faceRecognitionMode)
            let backupAnimationDataSource = DefaultAnimationDataSource(animationDependencies: animationDependencies)
            return FaceAnimationDataSource(faceRecognitionMode: mode,
                                           animationDependencies: animationDependencies,
                                           backupAnimationDataSource: backupAnimationDataSource)
        }
    }
}
