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
        var elapsedTime: TimeInterval
        var isRunning: Bool
        var currentLoop: Int
    }

    // Static properties that don't change
    let timerDuration: TimeInterval
    let startDate: Date
}
