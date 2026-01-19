//
//  TimerActivityAttributes.swift
//  LoopTimerWidgetExtension
//
//  Activity attributes for Live Activity
//

import Foundation
import ActivityKit

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var loopEndDate: Date              // Widget calculates countdown to this date
        var isRunning: Bool
        var pausedRemainingTime: TimeInterval?  // For paused state display (nil when running)
    }

    // Static properties that don't change
    let timerDuration: TimeInterval
}
