//
// Created by Nickolay Sheika on 6/11/16.
//

import Foundation

class BlockTimer {

    // MARK: - Private Variables

    private let repeats: Bool
    private var timer: Timer?
    private var callback: (() -> ())? // callback is retained, but cancel() will drop it and therefore break retain cycle
    private var timeLeftToFire: TimeInterval?

    // MARK: - Init

    init(interval: TimeInterval, repeats: Bool = false, callback: @escaping () -> ()) {
        self.repeats = repeats
        self.callback = callback

        timer = buildTimerAndScheduleWithTimeInterval(timeInterval: interval, repeats: repeats)
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

        timer = buildTimerAndScheduleWithTimeInterval(timeInterval: timeLeftToFire!, repeats: repeats)
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        callback = nil
    }

    @objc func timerFired(timer: Timer) {
        callback?()

        if !repeats {
            cancel()
        }
    }

    // MARK: - Private

    private func buildTimerAndScheduleWithTimeInterval(timeInterval: TimeInterval, repeats: Bool) -> Timer {
        let timer = Timer(timeInterval: timeInterval,
                            target: self,
                            selector: #selector(timerFired),
                            userInfo: nil,
                            repeats: repeats)

        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)

        return timer
    }
}
