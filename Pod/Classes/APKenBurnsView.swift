//
// Created by Nickolay Sheika on 4/25/16.
//

import Foundation
import UIKit
import QuartzCore


@objc public protocol APKenBurnsViewDataSource {
    /*
        Main data source method. Data source should provide next image.
        If no image provided (data source returns nil) then previous image will be used one more time.
    */
    func nextImageForKenBurnsView(kenBurnsView: APKenBurnsView) -> UIImage?
}


@objc public protocol APKenBurnsViewDelegate {

    /*
        Called when transition starts from one image to another
    */
    @objc optional func kenBurnsViewDidStartTransition(kenBurnsView: APKenBurnsView, toImage: UIImage)

    /*
        Called when transition from one image to another is finished
    */
    @objc optional func kenBurnsViewDidFinishTransition(kenBurnsView: APKenBurnsView)
}


public enum APKenBurnsViewFaceRecognitionMode {
    case None         // no face recognition, simple Ken Burns effect
    case Biggest      // recognizes biggest face in image, if any then transition will start or will finish (chosen randomly) in center of face rect.
    case Group        // recognizes all faces in image, if any then transition will start or will finish (chosen randomly) in center of compound rect of all faces.
}


public class APKenBurnsView: UIView {

    // MARK: - DataSource

    /*
        NOTE: Interface Builder does not support connecting to an outlet in a Swift file when the outlet’s type is a protocol.
        Workaround: Declare the outlet's type as AnyObject or NSObject, connect objects to the outlet using Interface Builder, then change the outlet's type back to the protocol.
    */
    @IBOutlet public weak var dataSource: APKenBurnsViewDataSource?


    // MARK: - Delegate

    /*
        NOTE: Interface Builder does not support connecting to an outlet in a Swift file when the outlet’s type is a protocol.
        Workaround: Declare the outlet's type as AnyObject or NSObject, connect objects to the outlet using Interface Builder, then change the outlet's type back to the protocol.
    */
    @IBOutlet public weak var delegate: APKenBurnsViewDelegate?


    // MARK: - Animation Setup

    /*
        Face recognition mode. See APKenBurnsViewFaceRecognitionMode docs for more information.
    */
    public var faceRecognitionMode: APKenBurnsViewFaceRecognitionMode = .None

    /*
        Allowed deviation of scale factor.

        Example: If scaleFactorDeviation = 0.5 then allowed scale will be from 1.0 to 1.5.
        If scaleFactorDeviation = 0.0 then allowed scale will be from 1.0 to 1.0 - fixed scale factor.
    */
    @IBInspectable public var scaleFactorDeviation: Float = 1.0

    /*
        Animation duration of one image
    */
    @IBInspectable public var imageAnimationDuration: Double = 10.0

    /*
        Allowed deviation of animation duration of one image

        Example: if imageAnimationDuration = 10 seconds and imageAnimationDurationDeviation = 2 seconds then
        resulting image animation duration will be from 8 to 12 seconds
    */
    @IBInspectable public var imageAnimationDurationDeviation: Double = 0.0

    /*
        Duration of transition animation between images
    */
    @IBInspectable public var transitionAnimationDuration: Double = 4.0

    /*
        Allowed deviation of animation duration of one image
    */
    @IBInspectable public var transitionAnimationDurationDeviation: Double = 0.0

    /*
        If set to true then recognized faces will be shown as rectangles. Only applicable for debugging.
    */
    @IBInspectable public var showFaceRectangles: Bool = false


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


    // MARK: - Public

    public func startAnimations() {
        stopAnimations()

        animationDataSource = buildAnimationDataSource()

        firstImageView.alpha = 1.0
        secondImageView.alpha = 0.0

        stopWatch = StopWatch()

        let image = dataSource?.nextImageForKenBurnsView(kenBurnsView: self)
        startTransitionWithImage(image: image!, imageView: firstImageView, nextImageView: secondImageView)
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


    // MARK: - Private Variables

    private var firstImageView: UIImageView!
    private var secondImageView: UIImageView!

    private var animationDataSource: AnimationDataSource!
    private var facesDrawer: FacesDrawerProtocol!

    private let notificationCenter = NotificationCenter.default

    private var timer: BlockTimer?
    private var stopWatch: StopWatch!


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
                                           name: NSNotification.Name.UIApplicationWillResignActive,
                                           object: nil)
            notificationCenter.addObserver(self,
                                           selector: #selector(applicationDidBecomeActive),
                                           name: NSNotification.Name.UIApplicationDidBecomeActive,
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


    // MARK: - Notifications

    @objc private func applicationWillResignActive(notification: NSNotification) {
        pauseAnimations()
    }

    @objc private func applicationDidBecomeActive(notification: NSNotification) {
        resumeAnimations()
    }


    // MARK: - Timer

    private func startTimerWithDelay(delay: Double, callback: @escaping () -> ()) {
        stopTimer()

        timer = BlockTimer(interval: delay, callback: callback)
    }

    private func stopTimer() {
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

           DispatchQueue.main.async {
            self.stopWatch.start()

            var animation = self.animationDataSource.buildAnimationForImage(image: image, forViewPortSize: self.bounds.size)

            DispatchQueue.main.async {
                

                let animationTimeCompensation = self.stopWatch.duration
                animation = ImageAnimation(startState: animation.startState,
                                           endState: animation.endState,
                                           duration: animation.duration - animationTimeCompensation)

                imageView.image = image
                imageView.animateWithImageAnimation(animation: animation)

                if self.showFaceRectangles {
                    self.facesDrawer.drawFacesInView(view: imageView, image: image)
                }

                let duration = self.buildAnimationDuration()
                let delay = animation.duration - duration / 2

                self.startTimerWithDelay(delay: delay) {

                    self.delegate?.kenBurnsViewDidStartTransition?(kenBurnsView: self, toImage: image)

                    self.animateTransitionWithDuration(duration: duration, imageView: imageView, nextImageView: nextImageView) {
                        self.delegate?.kenBurnsViewDidFinishTransition?(kenBurnsView: self)
                        self.facesDrawer.cleanUpForView(view: imageView)
                    }

                    var nextImage = self.dataSource?.nextImageForKenBurnsView(kenBurnsView: self)
                    if nextImage == nil {
                        nextImage = image
                    }

                    self.startTransitionWithImage(image: nextImage!, imageView: nextImageView, nextImageView: imageView)
                }
            }
        }
    }

    private func animateTransitionWithDuration(duration: Double, imageView: UIImageView, nextImageView: UIImageView, completion: @escaping () -> ()) {
        UIView.animate(withDuration: duration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.curveEaseInOut,
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
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        imageView.contentMode = UIViewContentMode.center
        self.addSubview(imageView)

        return imageView
    }
}
