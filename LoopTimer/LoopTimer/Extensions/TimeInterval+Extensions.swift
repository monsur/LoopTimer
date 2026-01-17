//
//  TimeInterval+Extensions.swift
//  LoopTimer
//
//  Time formatting utilities
//

import Foundation

extension TimeInterval {
    /// Formats TimeInterval as HH:MM:SS
    func formattedTime() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Formats TimeInterval as MM:SS for durations under 1 hour
    func formattedTimeShort() -> String {
        if self < 3600 {
            let minutes = Int(self) / 60
            let seconds = Int(self) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
        return formattedTime()
    }
}
