//
//  Date+Extensions.swift
//  LoopTimer
//
//  Date formatting utilities
//

import Foundation

extension Date {
    /// Formats date as relative time (e.g., "2 hours ago", "Yesterday")
    func relativeFormatted() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Formats date as short date and time
    func shortFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Formats date as "MMM d, yyyy"
    func mediumFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
