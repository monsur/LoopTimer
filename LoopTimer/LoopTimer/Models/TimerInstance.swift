//
//  TimerInstance.swift
//  LoopTimer
//
//  SwiftData model for timer history
//

import Foundation
import SwiftData

@Model
final class TimerInstance {
    var id: UUID
    var duration: TimeInterval
    var startedAt: Date
    var stoppedAt: Date
    var completedLoops: Int
    var chimeName: String

    init(duration: TimeInterval, startedAt: Date, stoppedAt: Date, completedLoops: Int, chimeName: String) {
        self.id = UUID()
        self.duration = duration
        self.startedAt = startedAt
        self.stoppedAt = stoppedAt
        self.completedLoops = completedLoops
        self.chimeName = chimeName
    }

    var totalDuration: TimeInterval {
        stoppedAt.timeIntervalSince(startedAt)
    }

    var durationString: String {
        duration.formattedTime()
    }
}
