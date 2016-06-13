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
    func kenBurnsViewDidStartTransition(kenBurnsView: APKenBurnsView, toImage: UIImage)
    func kenBurnsViewDidFinishTransition(kenBurnsView: APKenBurnsView)
}

public enum APKenBurnsViewFaceRecognitionMode {
    case None
    case Biggest
    case Group
}


public class APKenBurnsView: UIView {

    // MARK: - DataSource

    public weak var dataSource: APKenBurnsViewDataSource?

    // MARK: - Delegate

    public weak var delegate: APKenBurnsViewDelegate?

    // MARK: - Animation Setup
    public var faceRecognitionMode: APKenBurnsViewFaceRecognitionMode = .None

    public var scaleFactorDeviation: Float = 1.0

    public var imageAnimationDuration: Double = 10.0
    public var imageAnimationDurationDeviation: Double = 0.0

    public var transitionAnimationDuration: Double = 4.0
    public var transitionAnimationDurationDeviation: Double = 0.0

    public var showFaceRectangles: Bool = false

    // MARK: - Private Variables

    private var firstImageView: UIImageView!
    private var secondImageView: UIImageView!

    private var animationDataSource: AnimationDataSource!
    private var facesDrawer: FacesDrawerProtocol!

    private let notificationCenter = NSNotificationCenter.defaultCenter()

    private var timer: BlockTimer?
    private var stopWatch: StopWatch!

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
        guard superview == nil else {
            notificationCenter.addObserver(self,
                                           selector: #selector(applicationWillResignActive),
                                           name: UIApplicationWillResignActiveNotification,
                                           object: nil)
            notificationCenter.addObserver(self,
                                           selector: #selector(applicationDidBecomeActive),
                                           name: UIApplicationDidBecomeActiveNotification,
                                           object: nil)
            return
        }
        notificationCenter.removeObserver(self)

        // required to break timer retain cycle
        stopAnimations()
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    // MARK: - Public

    public func startAnimations() {
        stopAnimations()

        animationDataSource = buildAnimationDataSource()

        firstImageView.alpha = 1.0
        secondImageView.alpha = 0.0

        stopWatch = StopWatch()

        let image = dataSource?.nextImageForKenBurnsView(self)
        startTransitionWithImage(image!, imageView: firstImageView, nextImageView: secondImageView)
    }

    public func pauseAnimations() {
        firstImageView.backupAnimations()
        secondImageView.backupAnimations()

        timer?.pause()
        layer.pauseAnimations()
    }

    public func resumeAnimations() {
        firstImageView.restoreAnimations()
        secondImageView.restoreAnimations()

        timer?.resume()
        layer.resumeAnimations()
    }

    public func stopAnimations() {
        timer?.cancel()
        layer.removeAllAnimations()
    }

    // MARK: - Notifications

    func applicationWillResignActive(notification: NSNotification) {
        pauseAnimations()
    }

    func applicationDidBecomeActive(notification: NSNotification) {
        resumeAnimations()
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


    private func startTransitionWithImage(image: UIImage, imageView: UIImageView, nextImageView: UIImageView) {
        guard isValidAnimationDurations() else {
            fatalError("Animation durations setup is invalid!")
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.stopWatch.start()

            var animation = self.animationDataSource.buildAnimationForImage(image, forViewPortSize: self.bounds.size)

            dispatch_async(dispatch_get_main_queue()) {

                let animationTimeCompensation = self.stopWatch.duration
                animation = ImageAnimation(startState: animation.startState,
                                           endState: animation.endState,
                                           duration: animation.duration - animationTimeCompensation)

                imageView.image = image
                imageView.animateWithImageAnimation(animation)

                if self.showFaceRectangles {
                    self.facesDrawer.drawFacesInView(imageView, image: image)
                }

                let duration = self.buildAnimationDuration()
                let delay = animation.duration - duration / 2

                self.startTimerWithDelay(delay) {

                    self.delegate?.kenBurnsViewDidStartTransition(self, toImage: image)

                    self.animateTransitionWithDuration(duration, imageView: imageView, nextImageView: nextImageView) {
                        self.delegate?.kenBurnsViewDidFinishTransition(self)
                        self.facesDrawer.cleanUpForView(imageView)
                    }

                    var nextImage = self.dataSource?.nextImageForKenBurnsView(self)
                    if nextImage == nil {
                        nextImage = image
                    }

                    self.startTransitionWithImage(nextImage!, imageView: nextImageView, nextImageView: imageView)
                }
            }
        }
    }

    private func animateTransitionWithDuration(duration: Double, imageView: UIImageView, nextImageView: UIImageView, completion: () -> ()) {
        UIView.animateWithDuration(duration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                       imageView.alpha = 0.0
                                       nextImageView.alpha = 1.0
                                   },
                                   completion: {
                                       finished in

                                       completion()
                                   })
    }

    private func buildAnimationDuration() -> Double {
        var durationDeviation = 0.0
        if transitionAnimationDurationDeviation > 0.0 {
            durationDeviation = RandomGenerator().randomDouble(min: -transitionAnimationDurationDeviation,
                                                               max: transitionAnimationDurationDeviation)
        }
        let duration = transitionAnimationDuration + durationDeviation
        return duration
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