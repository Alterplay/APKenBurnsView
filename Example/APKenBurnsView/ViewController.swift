//
//  ViewController.swift
//  APKenBurnsView
//
//  Created by Nickolay Sheika on 04/21/2016.
//  Copyright (c) 2016 Nickolay Sheika. All rights reserved.
//

import UIKit
import APKenBurnsView

class ViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var kenBurnsView: APKenBurnsView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        kenBurnsView.dataSource = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        kenBurnsView.startAnimations()

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

extension ViewController: APKenBurnsViewDataSource {
    func nextImageForKenBurnsView(kenBurnsView: APKenBurnsView) -> UIImage? {
        return UIImage(named: "rinat")!
    }
}
