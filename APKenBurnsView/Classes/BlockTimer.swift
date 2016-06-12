//
// Created by Nickolay Sheika on 6/11/16.
//

import Foundation

class BlockTimer {
    private let repeats: Bool
    private var timer: NSTimer?
    private var callback: (() -> ())?   // callback is retained, but cancel() will drop it and therefore break retain cycle

    init(interval: NSTimeInterval, repeats: Bool = false, callback: () -> ()) {
        self.repeats = repeats
        self.callback = callback

        let newTimer = NSTimer(timeInterval: interval,
                               target: self,
                               selector: "timerFired:",
                               userInfo: nil,
                               repeats: repeats)

        timer = newTimer

        // Run timer in 'NSRunLoopCommonModes' to make it fire during scrolling
        NSRunLoop.mainRunLoop().addTimer(newTimer, forMode: NSRunLoopCommonModes)
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        callback = nil
    }

    @objc func timerFired(timer: NSTimer) {
        callback?()

        if !repeats {
            cancel()
        }
    }
}