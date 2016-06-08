//
// Created by Nickolay Sheika on 4/25/16.
//

import Foundation
import UIKit
import QuartzCore

public protocol APKenBurnsViewDataSource: class {
    func nextImageForKenBurnsView(kenBurnsView: APKenBurnsView) -> UIImage
}


public protocol APKenBurnsViewDelegate: class {

}

enum KenBurnsTransitionEffect {
    case KenBurnsTransitionEffectCrossFade
}

struct KenBurnsAnimationConfiguration {
    let firstImageTransition: ImageTransition
    let secondImageTransition: ImageTransition

    let transitionEffect: KenBurnsTransitionEffect = .KenBurnsTransitionEffectCrossFade
    let transitionDuration: Double
}

struct ImageTransition {
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

    // MARK: - Private Variables
    var duration: Double = 10.0

    lazy var firstImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.redColor()
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
        imageView.backgroundColor = UIColor.blueColor()
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
//        return Float(lower + Int(arc4random_uniform(UInt32(upper - lower + 1))))
        return (Float(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }

    private func startAnimating() {

        let image = dataSource?.nextImageForKenBurnsView(self)

        self.firstImageView.image = image
        self.secondImageView.image = image

        self.firstImageView.alpha = 1.0
        self.secondImageView.alpha = 0.0

//        let firstImageStartState = ImageState(scale: 1.5, position: CGPointMake(0.0, 0.0))
//        let firstImageEndState = ImageState(scale: 1.6, position: CGPointMake(200.0, 200.0))
//        let firstImageTransition = ImageTransition(startState: firstImageStartState, endState: firstImageEndState, duration: 5.0)
        let firstImageTransition = buildRandomTransitionForImage(image!)
        let secondImageTransition = buildRandomTransitionForImage(image!)

        let animationConfiguration = KenBurnsAnimationConfiguration(firstImageTransition: firstImageTransition,
                                                                    secondImageTransition: secondImageTransition,
                                                                    transitionDuration: 2.0)
//
//        let biggestFaceRect = detectBiggestFaceRectInImage(image!)!
//        let faceRectCenter = CGPointMake(CGRectGetMidX(biggestFaceRect), CGRectGetMidY(biggestFaceRect))
//
//        let translationTransform = CGAffineTransformMakeTranslation(-(self.bounds.size.width / 2.0 - faceRectCenter.x), -(self.bounds.size.height / 2.0 - faceRectCenter.y))
//        let zoomTransform = CGAffineTransformMakeScale(1.9, 1.9)
//        let transform = CGAffineTransformConcat(translationTransform, zoomTransform)
        let firstImageStartTransform = transformForImageState(animationConfiguration.firstImageTransition.startState)
        let firstImageEndTransform = transformForImageState(animationConfiguration.firstImageTransition.endState)

        let secondImageStartTransform = transformForImageState(animationConfiguration.secondImageTransition.startState)
        let secondImageEndTransform = transformForImageState(animationConfiguration.secondImageTransition.endState)

        self.firstImageView.transform = firstImageStartTransform
        self.secondImageView.transform = secondImageStartTransform

        UIView.animateWithDuration(animationConfiguration.firstImageTransition.duration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                       self.firstImageView.transform = firstImageEndTransform
                                   },
                                   completion: {
                                       finished in

                                       print(firstImageTransition)
                                   })
        UIView.animateWithDuration(animationConfiguration.secondImageTransition.duration,
                                   delay: animationConfiguration.firstImageTransition.duration - animationConfiguration.transitionDuration / 2,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                       self.secondImageView.transform = secondImageEndTransform
                                   },
                                   completion: {
                                       finished in

                                       print(secondImageTransition)
                                   })

        let transitionDelay = animationConfiguration.firstImageTransition.duration - animationConfiguration.transitionDuration / 2
        UIView.animateWithDuration(animationConfiguration.transitionDuration,
                                   delay: transitionDelay,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                       self.firstImageView.alpha = 0.0
                                       self.secondImageView.alpha = 1.0
                                   },
                                   completion: {
                                       finished in

                                   })
    }

    private func transformForImageState(imageState: ImageState) -> CGAffineTransform {
        let scaleTransform = CGAffineTransformMakeScale(imageState.scale, imageState.scale)
        let translationTransform = CGAffineTransformMakeTranslation(imageState.position.x, imageState.position.y)
        let transform = CGAffineTransformConcat(scaleTransform, translationTransform)
        return transform
    }

    private func buildRandomTransitionForImage(image: UIImage) -> ImageTransition {
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


        let imageStartState = ImageState(scale: startScale, position: imageStartPosition)
        let imageEndState = ImageState(scale: endScale, position: imageEndPosition)
        let imageTransition = ImageTransition(startState: imageStartState, endState: imageEndState, duration: 5.0)

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
