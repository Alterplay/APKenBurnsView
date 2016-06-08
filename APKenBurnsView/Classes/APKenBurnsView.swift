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

enum TransitionEffect {
    case TransitionEffectCrossFade
}

struct Transition {
    let imageTransition: ImageAnimation

    let transitionEffect: TransitionEffect = .TransitionEffectCrossFade
    let transitionDuration: Double
}

struct ImageAnimation {
    let startState: ImageState
    let endState: ImageState

    let duration: Double
}

struct ImageState {
    let scale: CGFloat
    let position: CGPoint
}


public class APKenBurnsView: UIView {

    // MARK: -
    weak var dataSource: APKenBurnsViewDataSource?
    weak var delegate: APKenBurnsViewDelegate?

    // MARK: - Setup
    var repeatInLoop: Bool = true
    var faceRecognition: Bool = false

    var scaleFactorDeviation: Float = 0.5

    var imageAnimationDuration: Double = 5.0
    var imageAnimationDurationDeviation: Double = 0.0

    var transitionAnimationDuration: Double = 2.0
    var transitionAnimationDurationDeviation: Double = 0.0

    // MARK: - Private Variables

    lazy var firstImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = 1
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
    }()

    lazy var secondImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = 2
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
    }()

    // MARK: - Public

    public func animateWithDataSource(dataSource: APKenBurnsViewDataSource) {
        self.dataSource = dataSource

        startAnimating()
    }

    func stopAnimations() {

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

    private func randomFloat(lower: Float = 0.0, upper: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }

    private func randomDouble(lower: Double = 0.0, upper: Double) -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }

    private func startAnimating() {
        firstImageView.alpha = 1.0
        secondImageView.alpha = 0.0

        let image = dataSource?.nextImageForKenBurnsView(self)
        startTransitionWithImage(image!, imageView: firstImageView, nextImageView: secondImageView)
    }

    private func startTransitionWithImage(image: UIImage, imageView: UIImageView, nextImageView: UIImageView) {
        let imageTransition = buildRandomTransitionForImage(image)

        imageView.image = image
        animateImageView(imageView, withTransition: imageTransition)

        let durationDeviation = transitionAnimationDuration > 0.0 ? randomDouble(-transitionAnimationDuration, upper: transitionAnimationDuration) : 0.0
        let duration = transitionAnimationDuration + durationDeviation
        let delay = imageTransition.duration - duration / 2

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

    private func animateImageView(imageView: UIImageView, withTransition transition: ImageAnimation) {
        let imageStartTransform = transformForImageState(transition.startState)
        let imageEndTransform = transformForImageState(transition.endState)

        imageView.transform = imageStartTransform

        UIView.animateWithDuration(transition.duration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                       imageView.transform = imageEndTransform
                                   },
                                   completion: {
                                       finished in

                                       print(transition)
                                   })
    }


    private func transformForImageState(imageState: ImageState) -> CGAffineTransform {
        let scaleTransform = CGAffineTransformMakeScale(imageState.scale, imageState.scale)
        let translationTransform = CGAffineTransformMakeTranslation(imageState.position.x, imageState.position.y)
        let transform = CGAffineTransformConcat(scaleTransform, translationTransform)
        return transform
    }

    private func buildRandomTransitionForImage(image: UIImage) -> ImageAnimation {
        let scaleForAspectFill = imageScaleForAspectFill(image)

        let startScaleDeviation = CGFloat(randomFloat(upper: scaleFactorDeviation))
        let endScaleDeviation = CGFloat(randomFloat(upper: scaleFactorDeviation))

        let startScale = scaleForAspectFill + startScaleDeviation
        let endScale = scaleForAspectFill + endScaleDeviation

        let imageStartSize = CGSizeMake(image.size.width * startScale, image.size.height * startScale)
        let imageEndSize = CGSizeMake(image.size.width * endScale, image.size.height * endScale)

        let imageStartXDeviation = Float((imageStartSize.width / 2 - bounds.size.width / 2))
        let imageStartYDeviation = Float((imageStartSize.height / 2 - bounds.size.height / 2))
        let imageEndXDeviation = Float((imageEndSize.width / 2 - bounds.size.width / 2))
        let imageEndYDeviation = Float((imageEndSize.height / 2 - bounds.size.height / 2))

        let imageStartPositionX = CGFloat(randomFloat(-imageStartXDeviation, upper: imageStartXDeviation))
        let imageStartPositionY = CGFloat(randomFloat(-imageStartYDeviation, upper: imageStartYDeviation))
        let imageStartPosition = CGPointMake(imageStartPositionX, imageStartPositionY)


        var imageEndPositionX: CGFloat = 0.0
        if imageStartPositionX < 0 {
            imageEndPositionX = CGFloat(randomFloat(0.0, upper: imageEndXDeviation))
        } else {
            imageEndPositionX = CGFloat(randomFloat(-imageEndXDeviation, upper: 0.0))
        }

        var imageEndPositionY: CGFloat = 0.0
        if imageStartPositionY < 0 {
            imageEndPositionY = CGFloat(randomFloat(0.0, upper: imageEndYDeviation))
        } else {
            imageEndPositionY = CGFloat(randomFloat(-imageEndYDeviation, upper: 0.0))
        }
        let imageEndPosition = CGPointMake(imageEndPositionX, imageEndPositionY)


        let durationDeviation = imageAnimationDurationDeviation > 0.0 ? randomDouble(-imageAnimationDurationDeviation, upper: imageAnimationDurationDeviation) : 0.0
        let duration = imageAnimationDuration + durationDeviation

        let imageStartState = ImageState(scale: startScale, position: imageStartPosition)
        let imageEndState = ImageState(scale: endScale, position: imageEndPosition)
        let imageTransition = ImageAnimation(startState: imageStartState, endState: imageEndState, duration: duration)

        return imageTransition
    }

    private func imageScaleForAspectFill(image: UIImage) -> CGFloat {
        let heightScale = bounds.height / image.size.height
        let widthScale = bounds.width / image.size.width
        let scaleForAspectFill = max(heightScale, widthScale)
        return scaleForAspectFill
    }

    private func detectBiggestFaceRectInImage(image: UIImage) -> CGRect? {
        let faceDetector: CIDetector = CIDetector(ofType: CIDetectorTypeFace,
                                                  context: nil,
                                                  options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
        var ciImage = image.CIImage

        if ciImage == nil {
            ciImage = CIImage(CGImage: image.CGImage!)
        }

        let faces: NSArray = faceDetector.featuresInImage(ciImage!, options: nil)
        let biggestFaceRect = biggestFaceRectFromFaces(faces)
        return biggestFaceRect
    }

    private func biggestFaceRectFromFaces(faces: NSArray) -> CGRect? {
        var biggestArea: Double = 0.0
        var biggestFace: AnyObject? = nil
        for face in faces {
            let faceRect = face.bounds
            let area: Double = Double(faceRect.width * faceRect.height)
            if (area > biggestArea) {
                biggestArea = area
                biggestFace = face
            }
        }
        return biggestFace != nil ? biggestFace!.bounds : nil
    }


}
