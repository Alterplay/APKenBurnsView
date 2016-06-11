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

        UIView.animateKeyframesWithDuration(animation.duration, delay: 0, options: .CalculationModeCubic, animations: {
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0) {
                self.transform = imageStartTransform
            }
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1.0) {
                self.transform = imageEndTransform
            }
        }, completion: nil)
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

    // MARK: - Animation Setup
    public var faceRecognitionMode: APKenBurnsViewFaceRecognitionMode = .None

    public var scaleFactorDeviation: Float = 0.5

    public var imageAnimationDuration: Double = 5.0
    public var imageAnimationDurationDeviation: Double = 0.0

    public var transitionAnimationDuration: Double = 2.0
    public var transitionAnimationDurationDeviation: Double = 0.0

    public var showFaceRectangles: Bool = false

    // MARK: - Private Variables

    var firstImageView: UIImageView!
    var secondImageView: UIImageView!

    private var animationDataSource: AnimationDataSource!
    private var facesDrawer: FacesDrawerProtocol!

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        firstImageView = buildDefaultImageView()
        secondImageView = buildDefaultImageView()
        facesDrawer = FacesDrawer()
    }

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


    // MARK: - Private

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
        let animation = animationDataSource.buildAnimationForImage(image, forViewPortSize: bounds.size)

        imageView.image = image
        imageView.animateWithImageAnimation(animation!)

        if showFaceRectangles {
            facesDrawer.drawFacesInView(imageView, image: image)
        }

        var durationDeviation = 0.0
        if (transitionAnimationDuration > 0.0) {
            durationDeviation = Double.random(min: -transitionAnimationDuration, max: transitionAnimationDuration)
        }
        let duration = transitionAnimationDuration + durationDeviation
        let delay = animation!.duration - duration / 2

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

                                           self.facesDrawer.cleanUpForView(imageView)
                                       })

            var nextImage = self.dataSource?.nextImageForKenBurnsView(self)
            if nextImage == nil {
                nextImage = image
            }

            self.startTransitionWithImage(nextImage!, imageView: nextImageView, nextImageView: imageView)
        }
    }

    private func buildDefaultImageView() -> UIImageView {
        let imageView = UIImageView(frame: bounds)
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
