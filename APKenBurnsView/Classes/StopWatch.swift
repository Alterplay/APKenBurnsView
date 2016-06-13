//
// Created by Nickolay Sheika on 6/13/16.
//

import Foundation
import CoreFoundation

class StopWatch: CustomStringConvertible {

    // MARK: - Public Variables

    private var startTime: Double = 0.0
    private var finishTime: Double = 0.0

    var duration: Double {
        get {
            if (finishTime == 0) {
                return Double(CFAbsoluteTimeGetCurrent() - startTime)
            } else {
                return Double(finishTime - startTime)
            }
        }
    }

    // MARK: - Public

    func start() {
        startTime = CFAbsoluteTimeGetCurrent()
        finishTime = 0.0
    }

    func stop() -> Double {
        if (finishTime == 0) {
            finishTime = CFAbsoluteTimeGetCurrent()
        }
        return Double(finishTime - startTime)
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