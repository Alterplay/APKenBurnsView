//
// Created by Nickolay Sheika on 6/11/16.
//

import Foundation

class BlockTimer {

    // MARK: - Private Variables

    private let repeats: Bool
    private var timer: NSTimer?
    private var callback: (() -> ())? // callback is retained, but cancel() will drop it and therefore break retain cycle
    private var timeLeftToFire: NSTimeInterval?

    // MARK: - Init

    init(interval: NSTimeInterval, repeats: Bool = false, callback: () -> ()) {
        self.repeats = repeats
        self.callback = callback

        timer = buildTimerAndScheduleWithTimeInterval(interval, repeats: repeats)
    }

    // MARK: - Public

    func pause() {
        timeLeftToFire = timer?.fireDate.timeIntervalSinceNow

        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard timeLeftToFire != nil else {
            return
        }

        timer = buildTimerAndScheduleWithTimeInterval(timeLeftToFire!, repeats: repeats)
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

    // MARK: - Private

    private func buildTimerAndScheduleWithTimeInterval(timeInterval: NSTimeInterval, repeats: Bool) -> NSTimer {
        let timer = NSTimer(timeInterval: timeInterval,
                            target: self,
                            selector: #selector(timerFired),
                            userInfo: nil,
                            repeats: repeats)

        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)

        return timer
    }
}