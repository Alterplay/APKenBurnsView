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

public class APKenBurnsView: UIView {

    // MARK: -

    weak var delegate: APKenBurnsViewDelegate?
    weak var dataSource: APKenBurnsViewDataSource?

    // MARK: - Setup
    var repeatInLoop: Bool = true
    var faceRecognition: Bool = false

    // MARK: - Private Variables
    var duration: Double = 0.0
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.redColor()
        imageView.translatesAutoresizingMaskIntoConstraints = false
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

    public func animateWithDataSource(dataSource: APKenBurnsViewDataSource, duration: Double, delay: Double = 0.0) {
        self.dataSource = dataSource
        self.duration = duration

        startAnimatingWithDelay(delay)
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

//    let transform = CGAffineTransformConcat(zoomIn, combo1);

    private func startAnimatingWithDelay(delay: NSTimeInterval) {
        let faceDetector: CIDetector = CIDetector(ofType: CIDetectorTypeFace,
                                                  context: nil,
                                                  options: [CIDetectorAccuracy: CIDetectorAccuracyLow]);

        let image = dataSource?.nextImageForKenBurnsView(self)
        self.imageView.image = image

        var ciImage = image!.CIImage

        if ciImage == nil {
            ciImage = CIImage(CGImage:image!.CGImage!)
        }

        let faces: NSArray = faceDetector.featuresInImage(ciImage!, options: nil);
        let faceRect = faces[0].bounds

        let faceRectCenter = CGPointMake(faceRect.origin.x + faceRect.size.width / 2.0, faceRect.origin.y + faceRect.size.height / 2.0)

        let zoomTransform = CGAffineTransformMakeTranslation(-(self.bounds.size.width / 2.0 - faceRectCenter.x), -(self.bounds.size.height / 2.0 - faceRectCenter.y))

        UIView.animateWithDuration(self.duration,
                                   delay: delay,
                                   options: UIViewAnimationOptions.BeginFromCurrentState,
                                   animations: {
                                       self.imageView.transform = zoomTransform

                                   },
                                   completion: {
                                       finished in

                                   })
    }

}
