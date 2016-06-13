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
    case Biggest
    case Group
}


public class APKenBurnsView: UIView {

    // MARK: -
    public weak var dataSource: APKenBurnsViewDataSource?
    public weak var delegate: APKenBurnsViewDelegate?

    // MARK: - Animation Setup
    public var faceRecognitionMode: APKenBurnsViewFaceRecognitionMode = .None

    public var scaleFactorDeviation: Float = 0.5

    public var imageAnimationDuration: Double = 6.0
    public var imageAnimationDurationDeviation: Double = 0.0

    public var transitionAnimationDuration: Double = 2.0
    public var transitionAnimationDurationDeviation: Double = 0.0

    public var showFaceRectangles: Bool = false

    // MARK: - Private Variables

    var firstImageView: UIImageView!
    var secondImageView: UIImageView!

    private var animationDataSource: AnimationDataSource!
    private var facesDrawer: FacesDrawerProtocol!

    private var timer: BlockTimer?

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

    // MARK: - Lifecycle

    public override func didMoveToSuperview() {
        // required to break timer retain cycle
        guard superview == nil else {
            return
        }
        stopTimer()   // TODO consider call of stopAnimations() ??
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



    // MARK: - Timer

    func startTimerWithDelay(delay: Double, callback: () -> ()) {
        stopTimer()

        timer = BlockTimer(interval: delay, callback: callback)
    }

    func stopTimer() {
        timer?.cancel()
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

        runningTimer = RunningTimer()

        let image = dataSource?.nextImageForKenBurnsView(self)
        startTransitionWithImage(image!, imageView: firstImageView, nextImageView: secondImageView)
    }

    var runningTimer: RunningTimer!

    private func startTransitionWithImage(image: UIImage, imageView: UIImageView, nextImageView: UIImageView) {
        guard isValidAnimationDurations() else {
            fatalError("Animation durations setup is invalid!")
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let startTime = self.runningTimer.duration

            var animation = self.animationDataSource.buildAnimationForImage(image, forViewPortSize: self.bounds.size)

            dispatch_async(dispatch_get_main_queue()) {

                let endTime = self.runningTimer.duration
                let animationTimeCompensation = endTime - startTime
//                print(animationTimeCompensation)

                animation = ImageAnimation(startState: animation.startState, endState: animation.endState, duration: animation.duration - animationTimeCompensation)


                imageView.image = image
                imageView.animateWithImageAnimation(animation)

                if self.showFaceRectangles {
                    self.facesDrawer.drawFacesInView(imageView, image: image)
                }

                var durationDeviation = 0.0
                if (self.transitionAnimationDurationDeviation > 0.0) {
                    durationDeviation = Double.random(min: -self.transitionAnimationDurationDeviation, max: self.transitionAnimationDurationDeviation)
                }
                let duration = self.transitionAnimationDuration + durationDeviation
                let delay = animation.duration - duration / 2

                self.startTimerWithDelay(delay) {
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
        }
    }

    private func isValidAnimationDurations() -> Bool {
        return imageAnimationDuration - imageAnimationDurationDeviation -
               (transitionAnimationDuration - transitionAnimationDurationDeviation) / 2 > 0.0
    }

    private func buildDefaultImageView() -> UIImageView {
        let imageView = UIImageView(frame: bounds)
        imageView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        imageView.contentMode = UIViewContentMode.Center
        self.addSubview(imageView)

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


struct RunningTimer: CustomStringConvertible {
    var begin: CFAbsoluteTime
    var end: CFAbsoluteTime

    init() {
        begin = CFAbsoluteTimeGetCurrent()
        end = 0
    }

    mutating func start() {
        begin = CFAbsoluteTimeGetCurrent()
        end = 0
    }

    mutating func stop() -> Double {
        if (end == 0) {
            end = CFAbsoluteTimeGetCurrent()
        }
        return Double(end - begin)
    }
    var duration: CFAbsoluteTime {
        get {
            if (end == 0) {
                return CFAbsoluteTimeGetCurrent() - begin
            } else {
                return end - begin
            }
        }
    }
    var description: String {
        let time = duration
        if (time > 100) {
            return " \(time / 60) min"
        } else if (time < 1e-6) {
            return " \(time * 1e9) ns"
        } else if (time < 1e-3) {
            return " \(time * 1e6) µs"
        } else if (time < 1) {
            return " \(time * 1000) ms"
        } else {
            return " \(time) s"
        }
    }
}