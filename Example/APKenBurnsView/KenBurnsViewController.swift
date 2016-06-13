//
//  KenBurnsViewController.swift
//  APKenBurnsView
//
//  Created by Nickolay Sheika on 04/21/2016.
//  Copyright (c) 2016 Nickolay Sheika. All rights reserved.
//

import UIKit
import APKenBurnsView

class KenBurnsViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var kenBurnsView: APKenBurnsView!

    // MARK: - Public Variables

    var faceRecoginitionMode: APKenBurnsViewFaceRecognitionMode = .None
    var dataSource: [String]!

    // MARK: - Private Variables

    var index: Int = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBarHidden = true

        kenBurnsView.dataSource = self
//        kenBurnsView.showFaceRectangles = true
        kenBurnsView.faceRecognitionMode = faceRecoginitionMode



//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            let viewController = UIViewController()
//
//            self.presentViewController(viewController, animated: true, completion: nil)
//
//            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
//            dispatch_after(delayTime, dispatch_get_main_queue()) {
//                viewController.dismissViewControllerAnimated(true, completion: nil)
//            }
//        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.kenBurnsView.startAnimations()

//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            self.kenBurnsView.pauseAnimations()
//        }
//
//        let delayTime2 = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime2, dispatch_get_main_queue()) {
//            self.kenBurnsView.resumeAnimations()
//        }
    }
}

extension KenBurnsViewController: APKenBurnsViewDataSource {
    func nextImageForKenBurnsView(kenBurnsView: APKenBurnsView) -> UIImage? {
        let image = UIImage(named: dataSource[index])!
        index = index == dataSource.count - 1 ? 0 : index + 1
        return image
    }
}
