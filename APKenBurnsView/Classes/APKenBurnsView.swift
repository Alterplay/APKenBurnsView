//
// Created by Nickolay Sheika on 4/25/16.
//

import Foundation
import UIKit
import QuartzCore

public protocol APKenBurnsViewDataSource: class {
    func nextImageForKenBurnsView(kenBurnsView: APKenBurnsView) -> UIImage?
}


public protocol APKenBurnsViewDelegate: class {

}

public enum APKenBurnsViewFaceRecognitionMode {
    case None
    case BiggestFace
}




extension UIImageView {

    // MARK: - Public

    func animateWithImageAnimation(animation: ImageAnimation) {
        let imageStartTransform = transformForImageState(animation.startState)
        let imageEndTransform = transformForImageState(animation.endState)

        self.transform = imageStartTransform

        UIView.animateWithDuration(animation.duration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                       self.transform = imageEndTransform
                                   },
                                   completion: nil)
    }

    // MARK: - Helpers

    private func transformForImageState(imageState: ImageState) -> CGAffineTransform {
        let scaleTransform = CGAffineTransformMakeScale(imageState.scale, imageState.scale)
        let translationTransform = CGAffineTransformMakeTranslation(imageState.position.x, imageState.position.y)
        let transform = CGAffineTransformConcat(scaleTransform, translationTransform)
        return transform
    }
}








public class APKenBurnsView: UIView {

    // MARK: -
    public weak var dataSource: APKenBurnsViewDataSource?
    public weak var delegate: APKenBurnsViewDelegate?

    // MARK: - Setup
    public var faceRecognitionMode: APKenBurnsViewFaceRecognitionMode = .None

    public var scaleFactorDeviation: Float = 0.5

    public var imageAnimationDuration: Double = 5.0
    public var imageAnimationDurationDeviation: Double = 0.0

    public var transitionAnimationDuration: Double = 2.0
    public var transitionAnimationDurationDeviation: Double = 0.0

    // MARK: - Private Variables

    private lazy var firstImageView: UIImageView = {
        return self.buildDefaultImageView()
    }()

    private lazy var secondImageView: UIImageView = {
        return self.buildDefaultImageView()
    }()

    private var animationDataSource: AnimationDataSource!

    // MARK: - Public

    public func startAnimations() {
        animationDataSource = buildAnimationDataSource()

        startAnimating()
    }

    public func pauseAnimations() {
//        pauseLayer(firstImageView.layer)
//        pauseLayer(secondImageView.layer)
    }

    public func resumeAnimations() {
//        resumeLayer(firstImageView.layer)
//        resumeLayer(secondImageView.layer)
    }

    public func stopAnimations() {
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Private

    private func setup() {

    }

    private func buildAnimationDataSource() -> AnimationDataSource {
        let animationDependencies = ImageAnimationDependencies(scaleFactorDeviation: scaleFactorDeviation,
                                                               imageAnimationDuration: imageAnimationDuration,
                                                               imageAnimationDurationDeviation: imageAnimationDurationDeviation)
        let animationDataSourceFactory = AnimationDataSourceFactory(animationDependencies: animationDependencies,
                                                                    faceRecognitionMode: faceRecognitionMode)
        return animationDataSourceFactory.buildAnimationDataSource()
    }

    private func startAnimating() {
        firstImageView.alpha = 1.0
        secondImageView.alpha = 0.0

        let image = dataSource?.nextImageForKenBurnsView(self)
        startTransitionWithImage(image!, imageView: firstImageView, nextImageView: secondImageView)
    }

    private func startTransitionWithImage(image: UIImage, imageView: UIImageView, nextImageView: UIImageView) {
        let imageTransition = animationDataSource.buildAnimationForImage(image, forAnimationRect: bounds)

        imageView.image = image
        imageView.animateWithImageAnimation(imageTransition!)

        var durationDeviation = 0.0
        if (transitionAnimationDuration > 0.0) {
            durationDeviation = Double.random(min: -transitionAnimationDuration, max: transitionAnimationDuration)
        }
        let duration = transitionAnimationDuration + durationDeviation
        let delay = imageTransition!.duration - duration / 2

        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            UIView.animateWithDuration(duration,
                                       delay: 0.0,
                                       options: UIViewAnimationOptions.CurveEaseInOut,
                                       animations: {
                                           imageView.alpha = 0.0
                                           nextImageView.alpha = 1.0
                                       },
                                       completion: {
                                           finished in


                                       })


            var nextImage = self.dataSource?.nextImageForKenBurnsView(self)
            if nextImage == nil {
                nextImage = image
            }

            self.startTransitionWithImage(nextImage!, imageView: nextImageView, nextImageView: imageView)
        }
    }

    private func buildDefaultImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIViewContentMode.Center
        self.addSubview(imageView)

        let views = [
                "imageView": imageView,
                "containerView": self,
        ]

        let vertical = NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|[imageView]|",
        options: [],
        metrics: nil,
        views: views)

        let horizontal = NSLayoutConstraint.constraintsWithVisualFormat(
        "H:|[imageView]|",
        options: [],
        metrics: nil,
        views: views)

        NSLayoutConstraint.activateConstraints(vertical + horizontal)

        return imageView
    }
}


// TODO
//private func pauseLayer(layer: CALayer) {
//    let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
//    layer.speed = 0.0
//    layer.timeOffset = pausedTime
//}
//
//private func resumeLayer(layer: CALayer) {
//    let pausedTime: CFTimeInterval = layer.timeOffset
//    layer.speed = 1.0
//    layer.timeOffset = 0.0
//    layer.beginTime = 0.0
//    let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
//    layer.beginTime = timeSincePause
//}
