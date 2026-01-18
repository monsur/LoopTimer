//
//  TimeInterval+Extensions.swift
//  LoopTimer
//
//  Time formatting utilities
//

import Foundation

extension TimeInterval {
    /// Formats TimeInterval as MM:SS
    func formattedTime() -> String {
        let totalMinutes = Int(self) / 60
        let seconds = Int(self) % 60

        return String(format: "%02d:%02d", totalMinutes, seconds)
    }
}
